import AppKit
import Foundation
import SwiftUI

/// Was die Hauptansicht gerade zeigt.
enum Zustand: Equatable {
    case vorbereiten(String)
    case bereit(URL)
    case fehler(String)
}

/// Startet Belegt (Docker oder Server) und hält fest, was die Oberfläche zeigen soll.
@MainActor
final class StartModell: ObservableObject {
    @Published var zustand: Zustand = .vorbereiten("Belegt wird vorbereitet …")
    @AppStorage("betriebsart") var betriebsartRoh = Betriebsart.lokal.rawValue
    @AppStorage("ordner") var ordner = ""
    @AppStorage("server") var server = ""

    private var aufgabe: Task<Void, Never>?

    var betriebsart: Betriebsart { Betriebsart(rawValue: betriebsartRoh) ?? .lokal }

    /// Der Ordner mit der compose.yml: gewählt, sonst der, aus dem die App gebaut wurde.
    var composeOrdner: URL {
        let gewaehlt = ordner.trimmingCharacters(in: .whitespaces)
        if !gewaehlt.isEmpty { return URL(fileURLWithPath: gewaehlt) }
        let standard = Bundle.main.object(forInfoDictionaryKey: "BelegtStandardOrdner") as? String ?? ""
        return URL(fileURLWithPath: standard)
    }

    /// Umgebungsdatei mit den Geheimnissen: außerhalb des Quellcodes, damit nichts davon eingecheckt wird.
    static var umgebungsDatei: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Belegt", isDirectory: true)
            .appendingPathComponent("belegt.env")
    }

    func starten(neuBauen: Bool = true) {
        aufgabe?.cancel()
        zustand = .vorbereiten("Belegt wird vorbereitet …")
        aufgabe = Task { [weak self] in
            guard let self else { return }
            switch betriebsart {
            case .server: await serverOeffnen()
            case .lokal: await lokalStarten(neuBauen: neuBauen)
            }
        }
    }

    func abbrechen() {
        aufgabe?.cancel()
        zustand = .fehler("Abgebrochen.")
    }

    private func status(_ text: String) {
        if !Task.isCancelled { zustand = .vorbereiten(text) }
    }

    private func fehler(_ text: String) {
        if !Task.isCancelled { zustand = .fehler(text) }
    }

    // MARK: Server im Netz

    private func serverOeffnen() async {
        guard let adresse = serverAdresse(server) else {
            fehler("Die Serveradresse fehlt oder ist ungültig. Erlaubt ist https:// mit Rechnername, http:// nur für localhost.")
            return
        }
        zustand = .bereit(adresse)
    }

    // MARK: Docker auf diesem Mac

    private func lokalStarten(neuBauen: Bool) async {
        guard let docker = dockerPfad() else {
            fehler("Docker Desktop ist nicht installiert. Installiere es von docker.com oder wechsle in den Einstellungen auf einen Server.")
            return
        }
        let ordner = composeOrdner
        let compose = ordner.appendingPathComponent("compose.yml")
        guard FileManager.default.fileExists(atPath: compose.path) else {
            fehler("Im Ordner \(ordner.path) liegt keine compose.yml. Wähle in den Einstellungen den Ordner von Belegt.")
            return
        }
        guard await dockerBereit(docker) else { return }

        let umgebung: URL
        do { umgebung = try umgebungAnlegen() } catch {
            fehler("Die Zugangsdaten konnten nicht angelegt werden: \(error.localizedDescription)")
            return
        }

        status("Belegt wird gebaut und gestartet …")
        var argumente = ["compose", "--env-file", umgebung.path, "-f", compose.path, "up", "-d"]
        if neuBauen { argumente.append("--build") }
        let gebaut = await fuehreAus(docker, argumente, ordner: ordner) { [weak self] zeile in
            Task { @MainActor in self?.status(zeile) }
        }
        if Task.isCancelled { return }
        guard gebaut.status == 0 else {
            let letzte = gebaut.ausgabe.split(whereSeparator: \.isNewline).suffix(6).joined(separator: "\n")
            fehler("Belegt konnte nicht gestartet werden.\n\n\(letzte)")
            return
        }

        let inhalt = (try? String(contentsOf: umgebung, encoding: .utf8)) ?? ""
        let port = portAusUmgebung(inhalt) ?? standardPort
        let adresse = URL(string: "http://localhost:\(port)")!
        status("Belegt startet …")
        for _ in 0..<120 {
            if Task.isCancelled { return }
            if await antwortet(adresse.appendingPathComponent("healthz")) {
                zustand = .bereit(adresse)
                return
            }
            try? await Task.sleep(for: .seconds(2))
        }
        fehler("Belegt antwortet nicht unter \(adresse.absoluteString). Prüfe in Docker Desktop, ob die Container laufen.")
    }

    /// Wartet, bis Docker Desktop antwortet, und startet es bei Bedarf.
    private func dockerBereit(_ docker: String) async -> Bool {
        if await fuehreAus(docker, ["info"]).status == 0 { return true }
        status("Docker Desktop wird gestartet …")
        if let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.docker.docker") {
            let konfiguration = NSWorkspace.OpenConfiguration()
            konfiguration.activates = false
            _ = try? await NSWorkspace.shared.openApplication(at: app, configuration: konfiguration)
        }
        for _ in 0..<60 {
            if Task.isCancelled { return false }
            try? await Task.sleep(for: .seconds(2))
            if await fuehreAus(docker, ["info"]).status == 0 { return true }
        }
        fehler("Docker Desktop ist nicht bereit geworden. Starte es von Hand und versuche es erneut.")
        return false
    }

    /// Legt die Umgebungsdatei beim ersten Start an und überschreibt sie nie.
    private func umgebungAnlegen() throws -> URL {
        let datei = Self.umgebungsDatei
        if FileManager.default.fileExists(atPath: datei.path) { return datei }
        try FileManager.default.createDirectory(
            at: datei.deletingLastPathComponent(), withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700])
        let inhalt = neueUmgebung(port: standardPort) { anzahl in
            var bytes = [UInt8](repeating: 0, count: anzahl)
            _ = SecRandomCopyBytes(kSecRandomDefault, anzahl, &bytes)
            return bytes
        }
        try Data(inhalt.utf8).write(to: datei, options: .withoutOverwriting)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: datei.path)
        return datei
    }

    private func antwortet(_ adresse: URL) async -> Bool {
        var anfrage = URLRequest(url: adresse)
        anfrage.timeoutInterval = 3
        guard let (_, antwort) = try? await URLSession.shared.data(for: anfrage) else { return false }
        return (antwort as? HTTPURLResponse)?.statusCode == 200
    }

    // MARK: Beenden

    /// Stoppt die Container (Daten bleiben) und schließt die App.
    func dienstebeenden() {
        guard betriebsart == .lokal, let docker = dockerPfad() else {
            NSApp.terminate(nil)
            return
        }
        let ordner = composeOrdner
        zustand = .vorbereiten("Dienste werden beendet …")
        Task {
            _ = await fuehreAus(
                docker,
                [
                    "compose", "--env-file", Self.umgebungsDatei.path,
                    "-f", ordner.appendingPathComponent("compose.yml").path, "stop",
                ], ordner: ordner)
            NSApp.terminate(nil)
        }
    }
}
