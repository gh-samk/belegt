import Foundation

// Reine Logik ohne Oberfläche und ohne Prozesse, damit mac/tests sie prüfen kann.

/// Betriebsart: Belegt läuft in Docker auf diesem Mac oder auf einem Server im Netz.
enum Betriebsart: String {
    case lokal
    case server
}

/// Standardport der lokalen Installation. Haben belegt 3000, Belegt bekommt einen eigenen.
let standardPort = 3400

/// Prüft die Adresse eines Servers: https mit Rechnername, http nur für diesen Mac. Alles andere liefert nil.
func serverAdresse(_ eingabe: String) -> URL? {
    let text = eingabe.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let adresse = URL(string: text),
        let schema = adresse.scheme?.lowercased(),
        let rechner = adresse.host(percentEncoded: false)?.lowercased(), !rechner.isEmpty,
        adresse.user == nil, adresse.password == nil
    else { return nil }
    let dieserMac = ["localhost", "127.0.0.1", "::1"].contains(rechner) || rechner.hasSuffix(".localhost")
    switch schema {
    case "https": return adresse
    case "http": return dieserMac ? adresse : nil
    default: return nil
    }
}

/// Darf eine Adresse in der App bleiben? Gleiche Herkunft wie Belegt (Schema, Rechner, Port), sonst ins Standardprogramm.
func gehoertZuBelegt(_ adresse: URL, basis: URL) -> Bool {
    adresse.scheme?.lowercased() == basis.scheme?.lowercased()
        && adresse.host(percentEncoded: false)?.lowercased() == basis.host(percentEncoded: false)?.lowercased()
        && (adresse.port ?? standardPortFuer(adresse)) == (basis.port ?? standardPortFuer(basis))
}

private func standardPortFuer(_ adresse: URL) -> Int {
    adresse.scheme?.lowercased() == "https" ? 443 : 80
}

/// Liest `BELEGT_PORT` aus der Umgebungsdatei; erlaubt sind `3400` und `127.0.0.1:3400`.
func portAusUmgebung(_ inhalt: String) -> Int? {
    for zeile in inhalt.split(separator: "\n") {
        let teile = zeile.trimmingCharacters(in: .whitespaces)
        guard teile.hasPrefix("BELEGT_PORT=") else { continue }
        let wert = teile.dropFirst("BELEGT_PORT=".count).split(separator: ":").last.map(String.init) ?? ""
        if let port = Int(wert), (1...65535).contains(port) { return port }
    }
    return nil
}

/// Zufallsbytes als Hex, nur Buchstaben und Ziffern (die Passwörter stehen in Datenbankadressen).
func hex(_ bytes: [UInt8]) -> String {
    bytes.map { String(format: "%02x", $0) }.joined()
}

/// Umgebungsdatei für die lokale Installation. `zufall(n)` liefert n Zufallsbytes.
/// Getrennte Datenbankrollen wie in deploy/compose.env.example: Belegt arbeitet als `belegt_app`,
/// nur die Migrationen laufen als Eigentümer.
func neueUmgebung(port: Int, zufall: (Int) -> [UInt8]) -> String {
    let datenbank = hex(zufall(24))
    let appRolle = hex(zufall(24))
    return """
        # Von der Mac-App angelegt (docs/mac-app.md). Nie ändern oder löschen, wenn Dokumente drinliegen:
        # ohne BELEGT_SCHLUESSEL sind die gespeicherten Postfach-Passwörter nicht mehr lesbar.
        POSTGRES_PASSWORD=\(datenbank)
        APP_DB_PASSWORD=\(appRolle)
        DATABASE_URL=postgres://belegt_app:\(appRolle)@postgres:5432/belegt
        MIGRATION_DATABASE_URL=postgres://belegt:\(datenbank)@postgres:5432/belegt
        BETTER_AUTH_SECRET=\(hex(zufall(32)))
        BELEGT_SCHLUESSEL=\(Data(zufall(32)).base64EncodedString())
        BELEGT_URL=http://localhost:\(port)
        BELEGT_PORT=127.0.0.1:\(port)

        """
}

/// Letzte nicht leere Zeile einer Ausgabe, für die Statusanzeige beim Bauen.
func letzteZeile(_ ausgabe: String) -> String? {
    ausgabe.split(whereSeparator: \.isNewline)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .last { !$0.isEmpty }
}
