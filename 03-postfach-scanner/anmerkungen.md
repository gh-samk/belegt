# Anmerkungen: Postfach und Scanner anbinden

Mockups zu Issue 3, Abschnitt E (Postfach geführt anbinden, Scanner in der Oberfläche). Aufbau passend zu PR 47
(Postfach ändern und entfernen): gleiche Listeneinträge, Feldnamen, Knopfreihenfolge. Statisch, kein Produktivcode.
Öffnen: `index.html`; alle Ansichten (Desktop 1280 px, Handy 390 px, hell und dunkel): `ansichten.html`
(`?theme=light|dark` steuert die Darstellung).

## Entscheidungen

- **Assistent im Karteninneren.** Er sitzt dort, wo heute „Postfach hinzufügen“ ausklappt (Kasten `bg-subtle` mit Rand
  in der Karte `verwaltungsKarte`), nicht auf einer eigenen Seite. Schritt 1 „Welchen Mail-Dienst nutzt du?“, Schritt 2
  Felder. Die Schrittanzeige hat Text („Schritt 2 von 2“), nicht nur Balken.
- **Eine Wahl führt weiter.** Die drei Dienste sind große Karten (mind. 112 px hoch, ganz klickbar), kein „Weiter“.
  Google und Microsoft 365 nur, wenn der Server sie anbietet; sonst entfällt Schritt 1.
- **Felder:** Name, Server, Benutzer, Passwort, Ordner sichtbar; Art, Port, TLS unter „Erweitert“ (Standard IMAP, 993,
  TLS an). Jedes Feld hat Beschriftung, Platzhalter und einen Hilfetext darunter. Alle Felder sind Pflicht, das steht
  einmal im Text, statt Sternchen an fünf Feldern.
- **Passwort:** leer, `type=password`, `autocomplete=new-password`, nie angezeigt. Bewusst **kein** „Anzeigen“-Knopf
  (weicht von der allgemeinen Empfehlung ab, Projektregel „nie in der Oberfläche“ gewinnt).
- **Knopfzeile:** „Abbrechen“ vor der Hauptaktion rechts, wie in DESIGN.md und PR 47. „Zurück“ ist ein Link oberhalb
  der Felder („Anderen Dienst wählen“), damit die Knopfzeile bei zwei Knöpfen bleibt.
- **Hauptaktion mit Verb und Objekt:** „Verbindung testen und Postfach anlegen“; nach einem Fehler „Verbindung erneut
  testen“. Während des Tests ist der Knopf gesperrt und sagt „Verbindung wird getestet …“ (Grund steht im Knopf).
- **Meldung in drei Teilen:** was passiert ist (fett, mit Symbol), was sicher bleibt, was du tun kannst. Rohtext des
  Servers eingeklappt unter „Details“, ohne Zugangsdaten. Fehler: `role="alert"`; Erfolg: `role="status"`.
- **Fehler am Feld:** `aria-invalid="true"` und `aria-describedby` (Hilfe- und Fehlertext) am Passwortfeld, roter Rand
  plus Symbol plus Text. Der Fehlertext am Feld hat kein eigenes `role="alert"`, damit er nicht doppelt vorgelesen wird;
  die Meldung darüber trägt es. Der Fokus steht auf dem Feld; „Passwort neu eingeben“ springt dorthin.
- **Leerzustand:** ein Satz („Noch kein Postfach.“), ein Zweck-Satz, genau ein Knopf „Postfach anbinden“.
- **Scanner:** neue Karte „Scanner anbinden“ vor der unveränderten Karte „Scannen“ (Trennblatt-Download). Drei Schritte
  mit Zustand als Wort plus Symbol (Haken „Erledigt“, Kreis „Offen“). Warnung „Nur im eigenen Netz“ steht vor den
  Schritten, mit Symbol und Wort, nicht nur Farbe. In der Oberfläche nur die Namen `FTP_BENUTZER`, `FTP_PASSWORT`,
  `FTP_PASV_ADRESSE`, nie Werte.
- **Abweichung vom Projekt (eine Zeile):** Die Seitenleiste im Mockup hat keine Lucide-Symbole (Ponytail). Zielgrößen
  folgen dem Vorschlag `--control-h` 40/44 px und `--field-border`; beides steht noch nicht im Code.
- **Neue Tokens:** keine außer den Vorschlägen `--field-border` und `--control-h` aus DESIGN.md.

## Offene Fragen an den Maintainer

1. **Testet der Server beim Anlegen?** Heute legt `POST /api/quellen` nur an. Das Mockup nimmt an: Test und Anlegen in
   einem Schritt, bei Misserfolg wird nichts gespeichert. Alternative: erst „Verbindung testen“, dann „Postfach
   speichern“ (ein Klick mehr, aber ehrlicher, falls der Test lange dauert oder nur teilweise geht). Beides braucht
   eine Route.
2. **Woher kennt Belegt den Zustand der Scanner-Schritte?** Schritt 1 (Eingangsordner gesetzt) und Schritt 3 (erstes
   Dokument aus dem Eingangsordner, steht schon auf der Startseite) sind ableitbar, Schritt 2 liegt im FTP-Container.
   Sonst: Schritt 2 bleibt „Offen“, bis Schritt 3 erledigt ist, oder jeder Schritt hat ein Häkchen „Erledigt“, das nur
   im Browser gemerkt wird.
3. **OAuth-Variante:** Heute nimmt `/api/oauth/<anbieter>/start?name=…` nur den Namen. Der Ordner gilt dann als INBOX
   und lässt sich über „Ändern“ (PR 47) anpassen. Recht so, oder soll der Ordner schon im Assistenten stehen?
4. **Erste Abholung:** Soll „Jetzt abrufen“ nach dem Anlegen die Hauptaktion sein (so im Mockup) oder startet Belegt
   den ersten Abruf selbst?
5. **Kartenreihenfolge unter „Scannen“:** Neue Karte „Scanner anbinden“ oben, Trennblatt darunter. Oder umgekehrt, weil
   das Trennblatt für alle gilt, die schon einen Scanner haben?
6. **Links in die Doku:** Die Mockups zeigen auf GitHub (`…/blob/main/docs/…`). Gilt die veröffentlichte Doku-Adresse
   (wie bei „Was ist das?“ mit Glossar), ersetzt sie diese Adressen, Anker wie `#brother` und `#ftp-einrichten` gibt es.
   Für „App-Passwort anlegen“ fehlt in `docs/eingang.md` ein eigener Abschnitt.

## Angewendete UX-Gesetze

- **Hick:** Schritt 1 hat genau drei Karten; Schritt 2 zeigt fünf Felder, die drei Technikfelder stecken unter „Erweitert“.
- **Fitts:** Dienstkarten sind ganz klickbar (mind. 112 px hoch), alle Knöpfe und Felder mind. 44 px am Handy, Hauptaktion
  steht als letzter Knopf rechts, der Gefahrknopf „Entfernen“ im Listeneintrag liegt weit von „Jetzt abrufen“.
- **Miller:** Höchstens fünf sichtbare Felder je Schritt und drei Scannerschritte; die Schritte sind getrennte Blöcke.
- **Jakob:** Gewohnte Assistenten-Muster (Schritt x von y, Zurück, Hauptaktion rechts), Beschriftung über dem Feld,
  Details-Aufklapper, „Mit Google anmelden“ wie überall.
- **Postel:** Server und Benutzer nehmen Eingaben so, wie Anbieter sie nennen; Platzhalter zeigen die Form
  (`imap.example.de`), Port folgt der Art, ohne dass man ihn kennen muss.
- **Tesler:** Belegt trägt die Komplexität: Test und Anlegen in einem Klick, Standardwerte für Art, Port, TLS, Ordner;
  der Mensch muss kein Protokoll kennen.
- **Doherty:** Nach dem Klick sofort Rückmeldung am Knopf („Verbindung wird getestet …“), Knopf gesperrt, Erfolg oder Fehler
  danach in drei Teilen.
- **Zeigarnik:** Die Schrittanzeige und der Zustand je Scannerschritt (Offen/Erledigt) zeigen, was noch fehlt.
- **Peak-End:** Das Ende des Assistenten ist ein klarer Erfolgssatz („Verbunden. 128 Nachrichten …“) mit „Was bleibt
  sicher?“ und dem nächsten Schritt; ein Fehler endet mit einer konkreten Handlung statt Ratlosigkeit.
- **Proximity:** Hilfetext direkt unter dem Feld, Fehlertext direkt am Feld, Knöpfe am Ende der Gruppe, Hinweis „Nur im eigenen
  Netz“ unmittelbar vor den Schritten, in denen er gilt.
- **Aesthetic-Usability:** Ruhige Karten, ein Stil (Rahmen statt Schatten), eine Hauptaktion je Karte; wirkt vertrauenswürdig,
  ersetzt aber keine verständlichen Texte.
- **Serial Position:** „Andere“ steht als Auffangkarte zuletzt, die zwei Wege ohne Passwort zuerst; Warnung am Anfang der
  Scannerkarte, Testscan als letzter Schritt.
