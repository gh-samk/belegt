import SwiftUI

@main
struct BelegtApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var modell = StartModell()
    @StateObject private var web = WebSteuerung()

    var body: some Scene {
        WindowGroup("Belegt", id: "haupt") {
            HauptAnsicht(modell: modell, web: web)
                .frame(minWidth: 900, minHeight: 600)
                .task { modell.starten() }
        }
        .defaultSize(width: 1360, height: 880)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .toolbar) {
                Button("Neu laden") { web.neuLaden() }.keyboardShortcut("r")
                Button("Neu bauen und starten") { modell.starten() }.keyboardShortcut("r", modifiers: [.command, .option])
                Button("Im Browser öffnen") { web.imBrowserOeffnen() }.keyboardShortcut("o", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .appTermination) {
                Button("Belegt beenden") { NSApp.terminate(nil) }.keyboardShortcut("q")
                Button("Dienste beenden und schließen") { modell.dienstebeenden() }
                    .keyboardShortcut("q", modifiers: [.command, .option])
            }
        }
        Settings { EinstellungenAnsicht(modell: modell) }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

struct HauptAnsicht: View {
    @ObservedObject var modell: StartModell
    @ObservedObject var web: WebSteuerung

    var body: some View {
        switch modell.zustand {
        case .bereit(let adresse):
            WebAnsicht(adresse: adresse, steuerung: web)
        case .vorbereiten(let text):
            VStack(spacing: 16) {
                ProgressView()
                Text(text).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.center)
                Button("Abbrechen") { modell.abbrechen() }
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .fehler(let text):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.orange)
                Text(text).textSelection(.enabled).multilineTextAlignment(.center).frame(maxWidth: 560)
                HStack {
                    Button("Erneut versuchen") { modell.starten() }.keyboardShortcut(.defaultAction)
                    SettingsLink { Text("Einstellungen …") }
                }
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
