import SwiftUI

struct EinstellungenAnsicht: View {
    @ObservedObject var modell: StartModell
    @State private var meldung: String?

    var body: some View {
        Form {
            Picker("Betriebsart", selection: $modell.betriebsartRoh) {
                Text("Lokal (Docker auf diesem Mac)").tag(Betriebsart.lokal.rawValue)
                Text("Server (Adresse im Netz)").tag(Betriebsart.server.rawValue)
            }
            .pickerStyle(.radioGroup)

            if modell.betriebsart == .lokal {
                LabeledContent("Ordner von Belegt") {
                    HStack {
                        Text(modell.composeOrdner.path)
                            .truncationMode(.middle).lineLimit(1).textSelection(.enabled)
                        Button("Wählen …", action: ordnerWaehlen)
                    }
                }
                Text("Dort liegt die compose.yml. Beim Öffnen baut die App Belegt aus dem Stand dieses Ordners neu und startet die Dienste in Docker Desktop.")
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                TextField("Server", text: $modell.server, prompt: Text("https://belegt.example.de"))
                Text("Die HTTPS-Adresse deines Servers. http:// ist nur für localhost erlaubt.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            if let meldung { Text(meldung).foregroundStyle(.red) }

            HStack {
                Spacer()
                Button("Übernehmen und neu starten") {
                    if modell.betriebsart == .server && serverAdresse(modell.server) == nil {
                        meldung = "Ungültige Adresse. Erlaubt ist https:// mit Rechnername, http:// nur für localhost."
                    } else {
                        meldung = nil
                        modell.starten()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520)
    }

    private func ordnerWaehlen() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.directoryURL = modell.composeOrdner
        panel.message = "Wähle den Ordner mit der compose.yml von Belegt."
        if panel.runModal() == .OK, let url = panel.url { modell.ordner = url.path }
    }
}
