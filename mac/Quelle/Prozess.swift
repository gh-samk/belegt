import Foundation

// Kleine Hilfen, um docker aufzurufen. Programme aus dem Dock bekommen nur einen knappen PATH.

let suchpfad = "/usr/local/bin:/opt/homebrew/bin:/Applications/Docker.app/Contents/Resources/bin:/usr/bin:/bin"

func dockerPfad() -> String? {
    [
        "/usr/local/bin/docker", "/opt/homebrew/bin/docker",
        "/Applications/Docker.app/Contents/Resources/bin/docker",
    ].first { FileManager.default.isExecutableFile(atPath: $0) }
}

struct Ergebnis {
    let status: Int32
    let ausgabe: String
}

/// Startet ein Programm und meldet jede neue Ausgabezeile an `zeile`. Bricht die Aufgabe ab, endet das Programm.
func fuehreAus(
    _ programm: String, _ argumente: [String], ordner: URL? = nil,
    zeile: (@Sendable (String) -> Void)? = nil
) async -> Ergebnis {
    let prozess = Process()
    prozess.executableURL = URL(fileURLWithPath: programm)
    prozess.arguments = argumente
    prozess.currentDirectoryURL = ordner
    var umgebung = ProcessInfo.processInfo.environment
    umgebung["PATH"] = suchpfad
    prozess.environment = umgebung
    let rohr = Pipe()
    prozess.standardOutput = rohr
    prozess.standardError = rohr
    prozess.standardInput = FileHandle.nullDevice

    let gesammelt = Gesammelt()
    rohr.fileHandleForReading.readabilityHandler = { handle in
        let daten = handle.availableData
        guard !daten.isEmpty, let text = String(data: daten, encoding: .utf8) else { return }
        gesammelt.anhaengen(text)
        // Docker schreibt Fortschritt mit Wagenrücklauf; auch das zählt als Zeile
        if let letzte = letzteZeile(text.replacingOccurrences(of: "\r", with: "\n")) { zeile?(letzte) }
    }

    return await withTaskCancellationHandler {
        await withCheckedContinuation { fortsetzung in
            prozess.terminationHandler = { beendet in
                rohr.fileHandleForReading.readabilityHandler = nil
                fortsetzung.resume(returning: Ergebnis(status: beendet.terminationStatus, ausgabe: gesammelt.text))
            }
            do {
                try prozess.run()
            } catch {
                rohr.fileHandleForReading.readabilityHandler = nil
                fortsetzung.resume(returning: Ergebnis(status: 127, ausgabe: error.localizedDescription))
            }
        }
    } onCancel: {
        if prozess.isRunning { prozess.terminate() }
    }
}

/// Sammelt die Ausgabe eines Prozesses aus mehreren Threads.
final class Gesammelt: @unchecked Sendable {
    private let sperre = NSLock()
    private var inhalt = ""
    func anhaengen(_ text: String) {
        sperre.lock()
        inhalt += text
        sperre.unlock()
    }
    var text: String {
        sperre.lock()
        defer { sperre.unlock() }
        return inhalt
    }
}
