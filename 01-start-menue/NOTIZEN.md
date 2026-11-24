# Notizen: Start und Menü (Issue 3, Abschnitt A)

Seitentyp: Dashboard/App + Navigation + Mobile. Tokens aus `src/styles.css` (hell und dunkel), `--field-border` aus DESIGN.md.

## Gesetze, wo angewendet

- **Hick:** Die Startseite zeigt eine Aufgabe und einen Hauptknopf. Im leeren Archiv bleiben von vier Wegen einer plus drei Textlinks. Das Menü hat drei Gruppen statt einer Liste mit elf Einträgen.
- **Miller:** Gruppen mit 3, 5 und 3 Einträgen. Der Überblick ist ein Streifen mit vier Werten statt vier Kacheln mit Diagrammen. Im leeren Archiv entfällt er ganz.
- **Proximity:** Gruppenüberschrift 4 px über ihren Einträgen, 20 px zwischen den Gruppen, keine Trennlinien. Konto, Darstellung und Abmelden getrennt unten.
- **Jakob:** Seitenleiste links, Menü-Knopf oben rechts am Handy, Suche und Glocke in der Kopfleiste bleiben. Gruppen als `nav` mit Überschrift.
- **Von Restorff:** Zwei Dinge sind hervorgehoben: die Karte „Nächster Schritt“ (Rand `--fg`, einziger Hauptknopf) und der Zähler am Eingang (invertierte Pille). Die Zähler der gespeicherten Ansichten sind bewusst leise (`--subtle`).
- **Serial Position:** Start und Eingang stehen vorn, Archiv am Ende der ersten Gruppe. Konto und Abmelden stehen am Ende. Die Aufgabenkarte steht ganz oben, der Zustand unten.
- **Fitts:** 44 px Ziele am Handy (Menü-Knopf, Einträge, Knöpfe, eigenständige Links), 40 px Einträge, Darstellungs-Tasten und Knöpfe am Desktop. Der Hauptknopf der Karte ist am Handy so breit wie die Karte.
- **Doherty:** Zähler und Aufgabe sind sofort sichtbar, ohne Menü öffnen. Knöpfe schrumpfen beim Drücken (`scale(.97)`, 160 ms), Hover-Wechsel 120 ms. Nichts animiert endlos, `prefers-reduced-motion` schaltet alles ab.
- **Tesler:** Belegt wählt die nächste Aufgabe, nicht die Person. Der Knopf „Jetzt einordnen“ nimmt ihr das Suchen im Eingang ab.

## Zielkonflikte, entschieden

1. **Von Restorff gegen „keine Akzentfarbe“:** Hervorhebung nur durch Kontrast (`--fg`-Rand, invertierte Pille), nicht durch Farbe. `--ok` nur beim Siegel.
2. **Hick gegen Auffindbarkeit:** Im leeren Archiv stehen die drei anderen Wege eingeklappt unter „Andere Wege“. Der Leerzustand ist ein Satz und ein Knopf, die Wege sind einen Klick entfernt.
3. **Miller gegen Vollständigkeit:** Im leeren Archiv nur „Betrieb“ (Sicherung fehlt), weil das der Inhaber jetzt tun sollte. Siegel, Fristen, Quellen und Zahlen wären lauter Nullen ohne Aussage.
4. **Fitts gegen Dichte:** Menüeinträge 40 px statt 36 px wie heute. Die Seitenleiste scrollt bei niedrigen Fenstern in sich selbst (Höhe 100 vh), bei 900 px passt sie knapp.
5. **„Alles erledigt“ ruhig:** Symbol plus Wort, Rand `--border`, kein Hauptknopf, kein Grün. Das Siegel bleibt das einzige `--ok`.
6. **Mobil, Seitenname in der Leiste:** Nein, bleibt „Belegt“. Die Kopfleiste direkt darunter zeigt den Seitentitel schon, doppelt wäre Rauschen. Neu ist nur der Zähler am Menü-Knopf.
7. **Mobil, offenes Menü:** ein `<details>` in der Leiste, das Menü liegt als Fläche unter der Leiste über dem Inhalt (heute schiebt es ihn nach unten). Es funktioniert ohne JS; der Knopf ist das `<summary>`, daher kein `aria-expanded`/`aria-controls` von Hand, der Browser meldet den Zustand. Abweichung von der echten App, die einen Knopf mit `aria-expanded` hat. So bleiben Abmelden und Darstellung ohne langes Scrollen erreichbar. Ein Linkklick schließt es wie heute.
8. **Namen:** „Verfahrensdoku“ wird „Verfahrensdokumentation“ (der Seitentitel heißt schon so, GoBD-Begriff, keine Abkürzung für Leute mit wenig IT-Erfahrung; passt mit 168 px in 186 px Platz). „Quellen“ ist Menüwort und Titel, „und Schnittstellen“ ist heute der Seitentitel und wird zum Reiter. In der Kopfleiste steht „Start“ statt „Überblick“.
9. **Schrift:** `h1` 24 px, Kartentitel 18 px. Der Titel der Aufgabenkarte bleibt 18 px: Gewicht bekommt die Karte durch den `--fg`-Rand und den Hauptknopf, 24 px würden mit dem `h1` darüber konkurrieren. Beschriftungen und Hilfetexte 14 px; 12 px nur für Zähler, Datum und Version.
10. **Aktiver Menüeintrag:** Fläche `--subtle`, Fettdruck und 2-px-Balken links in `--fg`, damit der Zustand nicht an der Fläche allein hängt.

## Technisches

- Jede Datei steht allein, Tokens inline, ohne Netz. Hell/Dunkel per `prefers-color-scheme` und `data-theme`; der Schalter „Darstellung“ im Menü stellt um (JS). Das Menü am Handy geht ohne JS.
- Schrift: nur `system-ui`, Geist ist weggelassen (Mockup ohne Netz und ohne Schriftdatei).
- Umschaltung unter 768 px per Media-Query wie `md` in der App.
- Hash-Hilfen für die iframes: `#iframe` (Mock-Leiste aus), `-menue` (Menü offen), `-hell`, `-dunkel`.
- Die Lucide-Pfade sind aus dem Gedächtnis nachgezeichnet und können minimal vom Original abweichen.
- Nicht nachgezeichnet: Mini-Diagramme der Kennzahlen, Dateisymbole und Tags der Ansichtszeilen, Passwort-/Konto-Seiten.
