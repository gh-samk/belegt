import SwiftUI
import WebKit

/// Hält die WebView, damit Menüs sie neu laden oder die Adresse im Browser öffnen können.
@MainActor
final class WebSteuerung: ObservableObject {
    weak var webView: WKWebView?
    func neuLaden() { webView?.reload() }
    func imBrowserOeffnen() {
        if let adresse = webView?.url { NSWorkspace.shared.open(adresse) }
    }
}

struct WebAnsicht: NSViewRepresentable {
    let adresse: URL
    let steuerung: WebSteuerung

    func makeCoordinator() -> Koordinator { Koordinator(basis: adresse) }

    func makeNSView(context: Context) -> WKWebView {
        let konfiguration = WKWebViewConfiguration()
        konfiguration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: konfiguration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.basis = adresse
        steuerung.webView = webView
        webView.load(URLRequest(url: adresse))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if context.coordinator.basis != adresse {
            context.coordinator.basis = adresse
            webView.load(URLRequest(url: adresse))
        }
    }

    @MainActor
    final class Koordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
        var basis: URL
        private var ziele: [ObjectIdentifier: URL] = [:]
        init(basis: URL) { self.basis = basis }

        // Links auf fremde Seiten öffnen im Standardprogramm, Belegt bleibt in der App.
        func webView(
            _ webView: WKWebView, decidePolicyFor aktion: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let ziel = aktion.request.url else { return decisionHandler(.cancel) }
            if ["about", "blob", "data"].contains(ziel.scheme?.lowercased() ?? "") { return decisionHandler(.allow) }
            if gehoertZuBelegt(ziel, basis: basis) { return decisionHandler(.allow) }
            if ["http", "https", "mailto"].contains(ziel.scheme?.lowercased() ?? "") { NSWorkspace.shared.open(ziel) }
            decisionHandler(.cancel)
        }

        // Anhänge laden herunter statt anzuzeigen.
        func webView(
            _ webView: WKWebView, decidePolicyFor antwort: WKNavigationResponse,
            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
        ) {
            let kopf = (antwort.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Disposition") ?? ""
            decisionHandler(kopf.lowercased().hasPrefix("attachment") || !antwort.canShowMIMEType ? .download : .allow)
        }

        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            download.delegate = self
        }

        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }

        // target="_blank" bleibt im selben Fenster, wenn es Belegt ist, sonst im Browser.
        func webView(
            _ webView: WKWebView, createWebViewWith konfiguration: WKWebViewConfiguration,
            for aktion: WKNavigationAction, windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let ziel = aktion.request.url {
                if gehoertZuBelegt(ziel, basis: basis) { webView.load(aktion.request) } else { NSWorkspace.shared.open(ziel) }
            }
            return nil
        }

        func download(
            _ download: WKDownload, decideDestinationUsing antwort: URLResponse, suggestedFilename: String,
            completionHandler: @escaping (URL?) -> Void
        ) {
            let ordner = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            // Nur der Dateiname, nie ein Pfad, den die Seite vorgibt
            let name = (suggestedFilename as NSString).lastPathComponent.isEmpty ? "Download" : (suggestedFilename as NSString).lastPathComponent
            var ziel = ordner.appendingPathComponent(name)
            var nummer = 1
            while FileManager.default.fileExists(atPath: ziel.path) {
                let stamm = (name as NSString).deletingPathExtension
                let endung = (name as NSString).pathExtension
                ziel = ordner.appendingPathComponent(endung.isEmpty ? "\(stamm) \(nummer)" : "\(stamm) \(nummer).\(endung)")
                nummer += 1
            }
            ziele[ObjectIdentifier(download)] = ziel
            completionHandler(ziel)
        }

        func downloadDidFinish(_ download: WKDownload) {
            if let ziel = ziele.removeValue(forKey: ObjectIdentifier(download)) {
                NSWorkspace.shared.activateFileViewerSelecting([ziel])
            }
        }

        func download(_ download: WKDownload, didFailWithError fehler: Error, resumeData: Data?) {
            ziele.removeValue(forKey: ObjectIdentifier(download))
        }

        // Dateiauswahl für Uploads, auch Ordner (Eingang, Import).
        func webView(
            _ webView: WKWebView, runOpenPanelWith parameter: WKOpenPanelParameters,
            initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void
        ) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = parameter.allowsMultipleSelection
            panel.canChooseDirectories = parameter.allowsDirectories
            panel.canChooseFiles = true
            panel.begin { completionHandler($0 == .OK ? panel.urls : nil) }
        }

        // Kamera für das Abfotografieren von Belegen
        func webView(
            _ webView: WKWebView, requestMediaCapturePermissionFor ursprung: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(gehoertZuBelegt(URL(string: "\(ursprung.protocol)://\(ursprung.host):\(ursprung.port)")!, basis: basis) ? .prompt : .deny)
        }

        func webView(
            _ webView: WKWebView, runJavaScriptAlertPanelWithMessage nachricht: String,
            initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void
        ) {
            let hinweis = NSAlert()
            hinweis.messageText = nachricht
            hinweis.runModal()
            completionHandler()
        }

        func webView(
            _ webView: WKWebView, runJavaScriptConfirmPanelWithMessage nachricht: String,
            initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void
        ) {
            let frage = NSAlert()
            frage.messageText = nachricht
            frage.addButton(withTitle: "OK")
            frage.addButton(withTitle: "Abbrechen")
            completionHandler(frage.runModal() == .alertFirstButtonReturn)
        }
    }
}
