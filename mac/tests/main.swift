import Foundation

// Tests der reinen Logik: mac/testen.sh kompiliert diese Datei mit Quelle/Logik.swift und führt sie aus.

var fehler = 0
func pruefe(_ bedingung: Bool, _ beschreibung: String, zeile: Int = #line) {
    if !bedingung {
        fehler += 1
        print("FEHLER (Zeile \(zeile)): \(beschreibung)")
    }
}

// Serveradresse
pruefe(serverAdresse("https://belegt.example.de") != nil, "https mit Rechnername ist erlaubt")
pruefe(serverAdresse("  https://belegt.example.de/  ") != nil, "Leerzeichen am Rand werden ignoriert")
pruefe(serverAdresse("http://localhost:3400") != nil, "http für localhost ist erlaubt")
pruefe(serverAdresse("http://127.0.0.1:3400") != nil, "http für 127.0.0.1 ist erlaubt")
pruefe(serverAdresse("http://belegt.example.de") == nil, "http im Netz ist verboten")
pruefe(serverAdresse("ftp://belegt.example.de") == nil, "andere Schemata sind verboten")
pruefe(serverAdresse("https://") == nil, "ohne Rechnername ungültig")
pruefe(serverAdresse("belegt.example.de") == nil, "ohne Schema ungültig")
pruefe(serverAdresse("https://name:geheim@belegt.example.de") == nil, "Zugangsdaten in der Adresse sind verboten")
pruefe(serverAdresse("javascript:alert(1)") == nil, "javascript: ist verboten")
pruefe(serverAdresse("") == nil, "leere Eingabe ungültig")

// Herkunft
let basis = URL(string: "http://localhost:3400")!
pruefe(gehoertZuBelegt(URL(string: "http://localhost:3400/dokumente/1")!, basis: basis), "gleiche Herkunft bleibt")
pruefe(!gehoertZuBelegt(URL(string: "http://localhost:3000")!, basis: basis), "anderer Port geht ins Standardprogramm")
pruefe(!gehoertZuBelegt(URL(string: "https://localhost:3400")!, basis: basis), "anderes Schema geht ins Standardprogramm")
pruefe(!gehoertZuBelegt(URL(string: "https://example.org")!, basis: basis), "fremder Rechner geht ins Standardprogramm")
pruefe(
    gehoertZuBelegt(URL(string: "https://belegt.example.de:443/x")!, basis: URL(string: "https://belegt.example.de")!),
    "Port 443 ist bei https der Standard")

// Port aus der Umgebungsdatei
pruefe(portAusUmgebung("A=1\nBELEGT_PORT=127.0.0.1:3500\n") == 3500, "Port mit Adresse")
pruefe(portAusUmgebung("BELEGT_PORT=3600") == 3600, "Port ohne Adresse")
pruefe(portAusUmgebung("# BELEGT_PORT=3700\n") == nil, "Kommentar zählt nicht")
pruefe(portAusUmgebung("BELEGT_PORT=0") == nil, "Port 0 ist ungültig")
pruefe(portAusUmgebung("BELEGT_PORT=70000") == nil, "Port über 65535 ist ungültig")
pruefe(portAusUmgebung("") == nil, "leere Datei")

// Neue Umgebung
var zaehler: UInt8 = 0
let umgebung = neueUmgebung(port: 3400) { n in
    (0..<n).map { _ in zaehler &+= 1; return zaehler }
}
pruefe(portAusUmgebung(umgebung) == 3400, "die neue Umgebung enthält den Port")
pruefe(umgebung.contains("BELEGT_URL=http://localhost:3400"), "die Adresse passt zum Port")
pruefe(umgebung.contains("BELEGT_PORT=127.0.0.1:3400"), "der Port ist nur lokal offen")
let werte = Dictionary(
    uniqueKeysWithValues: umgebung.split(separator: "\n").filter { !$0.hasPrefix("#") && $0.contains("=") }
        .map { zeile -> (String, String) in
            let teile = zeile.split(separator: "=", maxSplits: 1).map(String.init)
            return (teile[0], teile[1])
        })
pruefe(werte["POSTGRES_PASSWORD"]?.count == 48, "Postgres-Passwort hat 48 Hexzeichen")
pruefe(werte["APP_DB_PASSWORD"]?.count == 48, "App-Passwort hat 48 Hexzeichen")
pruefe(werte["POSTGRES_PASSWORD"] != werte["APP_DB_PASSWORD"], "beide Passwörter unterscheiden sich")
pruefe(werte["BETTER_AUTH_SECRET"]?.count == 64, "Sitzungsschlüssel hat mindestens 32 Zeichen")
pruefe(Data(base64Encoded: werte["BELEGT_SCHLUESSEL"] ?? "")?.count == 32, "BELEGT_SCHLUESSEL sind 32 Bytes base64")
pruefe(
    werte["DATABASE_URL"] == "postgres://belegt_app:\(werte["APP_DB_PASSWORD"] ?? "")@postgres:5432/belegt",
    "die App arbeitet als belegt_app")
pruefe(
    werte["MIGRATION_DATABASE_URL"] == "postgres://belegt:\(werte["POSTGRES_PASSWORD"] ?? "")@postgres:5432/belegt",
    "Migrationen laufen als Eigentümer")

// Statuszeile
pruefe(letzteZeile("a\n\n  b  \n\n") == "b", "letzte nicht leere Zeile")
pruefe(letzteZeile("\n \n") == nil, "nur leere Zeilen")

if fehler > 0 {
    print("\(fehler) Fehler")
    exit(1)
}
print("Alle Tests der Mac-App-Logik bestanden")
