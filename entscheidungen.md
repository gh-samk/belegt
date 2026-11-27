# Entscheidungen zum Design-System

Grundlage für den späteren Pull Request zu `DESIGN.md`. Die Seite `index.html` zeigt jede Zeile mit Beispiel, hell und dunkel.
„heute“ ist der Stand von `main` (`DESIGN.md`, `src/styles.css`, `src/components/`). „bleibt“ heißt: gilt schon, wird nur Regel.

## Raster und Abstände

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Grundeinheit | keine genannt, Tailwind-Stufen frei | 4 px, Rhythmus 8 px | Jede Zahl folgt aus einem Raster; Tailwind rechnet ohnehin in 4 px. |
| Erlaubte Abstände | `gap-0.5`, `gap-2.5`, `px-2.5` usw. | nur `1, 2, 3, 4, 6, 8, 12, 16` (4, 8, 12, 16, 24, 32, 48, 64 px) | Zwischenstufen machen aus Rhythmus Zufall. |
| Abstandsregel | nicht geregelt | 8 in der Gruppe, 16 zwischen Feldern, 24 zwischen Gruppen und Karten, 48 zwischen Seitenblöcken; außen immer größer als innen | Gestalt-Gesetz der Nähe. |
| Spalten | nicht geregelt | 4 (Handy), 8 (Tablet), 12 (Desktop) | Müller-Brockmann: ein Raster je Breite. |
| Rinne | nicht geregelt | 16 px überall | Eine Zahl statt drei; bei 1440 px sind Spalten genau 80 px breit. |
| Seitenrand | `px-4 sm:px-8` | 16 px Handy, 24 px ab 768 px | 1136 + 2 × 24 + 256 = 1440: Die Rechnung geht auf. |
| Inhaltsbreite | frei | höchstens 1136 px, mittig | 12 × 80 + 11 × 16. |
| Seitenleiste | `w-64` ab `md` (768 px) | 256 px über die volle Seitenhöhe, der Inhalt klebt oben (`sticky`, `100dvh`); dauerhaft erst ab `lg` (1024 px); darunter „Menü“ | Bei 768 px blieben 512 px für den Inhalt. |
| Zweispalter Detailseite | nicht geregelt | 5 + 7 Spalten ab `xl` (1280 px), sonst eine | Bei 1024 px hätte die Einordnung nur 289 px. |
| Fließtext | `max-w-prose` empfohlen | `65ch`, bleibt | Lesbarkeit. |
| Formularbreite | nicht geregelt | einspaltig höchstens `36rem`; zweispaltig ab 768 px, 6 + 6 Spalten | Weniger Augenwege. |

## Typografie

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Stufen | 12, 14, 16, 18, 24 (Vorschlag); `text-[15px]` einmal | 12, 14, 16, 18, 24; nichts anderes | Bleibt, die Ausnahme in der Seitenleiste entfällt. |
| Zeilenhöhen | Tailwind-Vorgabe (`text-lg` = 28) | fest: 16, 20, 24, 24, 32; Tailwind `text-lg/6` | Alles liegt auf dem 4-px-Raster. |
| Gewichte | 400, 500, 600 gemischt, auch `font-bold` möglich | genau 400, 500, 600 | Hierarchie aus Größe, Gewicht und Abstand. |
| Rollen | nicht benannt | Titel 24/32/600, Kopf 18/24/600, Unterkopf 16/24/600, Lesen 16/24, Text 14/20, Beschriftung 14/20/500, Hilfe 14/20 muted, Nebenangabe 12/16 muted, Prüfwert mono | Jede Stelle hat eine Rolle statt einer Zahl. |
| Seitentitel | DESIGN.md: 24 px; Code: 18 px in der Kopfleiste | zwei Orte: 18/24 in der Kopfleiste, 24/32 im Inhalt (Dokument, Meldungsseiten); nie beide | Der Widerspruch zwischen Doku und Code wird zur Regel. |
| Schrift auf Touch | 16 px nur unter 640 px (`text-base sm:text-sm`) | 16 px bei `pointer: coarse` | iOS zoomt auch auf dem iPad unter 16 px. |
| Zahlen | `tabular-nums` in Tabellen | bleibt; Kennzahl-Kacheln proportional | Spalten stehen sauber untereinander. |
| Umbruch | `[overflow-wrap:anywhere]`, `break-all` bei Prüfwerten | bleibt | Messung aus Issue 3. |
| Versalien | verboten | bleibt, Gruppennamen im Menü in Satzschreibung | Ruhe. |

## Farben

| Token | heute | neu | Begründung |
| --- | --- | --- | --- |
| `--bg --side --subtle --fg --muted --border --primary --onprimary` | vorhanden | unverändert | Kontrast gerechnet: alle Textpaare mindestens 4,5 : 1. |
| `--field-border` | Vorschlag `#85858e` / `#71717a` | übernommen, Rand aller Bedienelemente | WCAG 1.4.11: 3,66 : 1 hell, 4,12 : 1 dunkel. |
| `--danger` | Token vorhanden, Fehlertext als `text-red-700 dark:text-red-400` | **ist Token** für Text, Rand, Symbol auf `--bg` und `--subtle` | Gleiche Werte wie red-700 und red-400; als Token nie ohne Dunkelmodus. 6,47 / 5,89 : 1 hell, 7,19 / 6,40 : 1 dunkel. |
| `--warn` | Token vorhanden, Hinweiskasten mit `border-amber-600` und `bg-amber-50` | **ist Token** für Symbol und Titel; Kasten bleibt `--subtle` | 5,02 / 4,57 : 1 hell, 11,92 / 10,61 : 1 dunkel. |
| `--ok` | Token vorhanden | unverändert, nur Symbol und Text | 5,02 / 4,56 : 1 hell. |
| Gefahrknopf | `bg-red-700 text-white` an 6 Stellen | auslösender Knopf: Rand und Schrift `--danger`; gefüllt nur der bestätigende Knopf im Dialog (`bg-danger text-onprimary`, 6,2 : 1 / 6,4 : 1) | Gefährliches ist auf der Seite leise, im Dialog klar. |
| Info | nicht geregelt | keine Farbe, Symbol in `--muted` | `--c-blue` bleibt allein dem Punkt „Pflicht“. |
| `--scrim` | `bg-black/50` | Token `rgb(9 9 11 / .5)` hell, `rgb(0 0 0 / .6)` dunkel | Kein Magic Number im Markup. |
| `--shadow-float`, `--shadow-dialog` | nicht vorhanden | neue Tokens | Schatten nur für Schwebendes. |
| Gesperrt | `opacity-60` und `opacity-50` gemischt | `opacity-50`, Grund immer als Text | Gesperrtes ist vom Kontrast ausgenommen, der Grund nicht. |
| Tag-Punkt | hell die Schriftfarbe, dunkel die Hintergrundfarbe der Palette | Mitteltöne `punkt: { hell, dunkel }`, mindestens 3 : 1 (Tabelle unten) | Die neun Farben sind trennbar und lesbar. |

## Linien, Rundungen, Ebenen

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Mittel | Rand und Fläche zugleich (Siegel, Einmalwert, Einordnung) | Abstand, dann Linie, dann Fläche; nie Linie und Fläche an einem Element | Zwei Signale für eine Sache. |
| Linienstärken | 1 px, 2 px Fokus und Reiter | 1 px `--border`, 1 px `--field-border`, 2 px `--fg` | Bleibt, benannt. |
| Rundungen | `rounded`, `-md`, `-lg`, `-full` gemischt | 0, 4 (Teile), 6 (Bedienelemente), 8 (Behälter), voll nur Radio und Punkt | Faustregel „Behälter 8, Bedienelement 6, Teil 4“. |
| Pillen | Zähler in der Seitenleiste, Siegel-Etikett (`rounded-full`) | `rounded-md` | Keine Pillen überall. |
| Kopfleiste | `bg-bg/85 backdrop-blur` | deckend `--bg` | Kein Glas, kein durchscheinender Inhalt. |
| Schatten | Dialog nur Scrim; Auswahlleiste ohne | nur Popover, Auswahlleiste, Menü-Fläche (`--shadow-float`) und Dialog (`--shadow-dialog`) | Ein Schatten sagt „liegt oben“. |
| Z-Index | `z-20` frei | 10 Tabellenkopf, 20 Leisten, 30 Auswahlleiste, 40 Popover und Menü-Fläche, 50 Dialog, 60 Sprunglink | Eine feste Folge. |

## Bewegung

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Grundsatz | „kaum Animation“ | bleibt; nur Farbe, Deckkraft, Skalierung | Ruhe. |
| Dauern | nicht geregelt | 100 ms (Farbe, Druck), 160 ms (Popover), 200 ms (Dialog, Menü); Aus etwa zwei Drittel | Doherty: Rückmeldung unter 400 ms. |
| Kurve | `ease` | `cubic-bezier(.23, 1, .32, 1)` für Erscheinen, `ease` für Farbe | Spürbar schneller bei gleicher Dauer. |
| Druck | nicht geregelt | Knopf skaliert auf 0,97 | Der Knopf hört zu. |
| Hover | immer | nur `@media (hover: hover)` | Kein klebender Hover auf Touch. |
| Tastatur | nicht geregelt | nie animiert | Wiederholte Handlungen sollen unmittelbar sein. |
| Laden | „Lädt …“, kein Skeleton-Standard | Skeleton nach 400 ms, ohne Schimmern; Knopf „Läuft …“ mit kleinem Dreher | Ausnahme von „nie Endlosbewegung“, siehe Fragen. |
| Reduziert | `motion-reduce:transition-none` | alles bei `prefers-reduced-motion` aus, Dreher steht | Bleibt, ausgeweitet. |

## Symbole

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Set | Lucide, 16 px, Strich 2 | bleibt; Größen 16 und 20 | Zwei Größen statt beliebiger. |
| Ausrichtung | Versatz (`mt-0.5`) | Symbol in einer Box so hoch wie die Zeile (`h-5` oder `h-6`) | Keine Versatzzahlen. |
| Textzeichen | `☰ ✕ ×` und `?` im Kreis, handgezeichnetes Schild | Lucide `menu`, `x`, `circle-question-mark`, `shield-check`, `shield-alert`, `shield-x` | Textzeichen sitzen schief; nie selbst gezeichnet. |
| Meldungen | nicht geregelt | `circle-x`, `triangle-alert`, `circle-check`, `info` | Ein Symbol je Art. |

## Zielgrößen und Felder

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| `--control-h` | Vorschlag 40 / 44 px | übernommen; auch Reiter, Menüeinträge, Auswahlleiste, Nur-Symbol-Knöpfe | Eine Höhe; `h-8` (41 Stellen) und `h-9` entfallen. |
| Nur-Symbol | uneinheitlich (`size-6`, `size-10`) | 40 × 40, Touch 44 × 44, `aria-label`; Tag-× 24 × 24 | WCAG 2.5.8. |
| Checkbox, Radio | 16 px, Rand `--primary`; DESIGN.md nennt auch `--field-border` | **entschieden:** 20 px, Rand `--field-border`, gewählt `--primary`; Fläche des Labels `--control-h` | Ein Rand für alles Bedienbare (3 : 1). |
| Pflichtfelder | uneinheitlich | „(optional)“ am seltenen Feld, ein Satz oben im Formular | Weniger Zeichen. |
| Hilfetext | teils im Kasten | unter dem Feld, 14 px `--muted`, ohne Kasten | Maintainer-Vorgabe. |
| Feldfehler | Text unter dem Feld | bleibt: `--danger`, Symbol, `role="alert"`, `aria-invalid` | Nicht nur Farbe. |
| Gesperrt, nur lesen | nur Gesperrt | Gesperrt: `--subtle`, Rand `--border`, Schrift `--muted`; Nur lesen: `--subtle`, normaler Rand | Zwei Zustände, zwei Looks. |
| Suchfeld | Rahmen mit Symbol | Symbol links, Löschknopf rechts (`--control-h`), kein Browser-Kreuz | Einheitlich. |

## Knöpfe

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Hauptaktion | `bg-primary`, eine je Karte | genau eine je Bereich (Seite, Karte, Dialog), letzter Knopf rechts | Maintainer-Vorgabe, bleibt. |
| Reihenfolge | Vorschlag | bleibt; Gefahr ganz links, Handy gestapelt mit Hauptaktion unten | Fitts: der Daumen erreicht unten am leichtesten. |
| Knopftext | Verb mit Objekt; `Einordnen & weiter`, `+ Postfach` | „und“ statt „&“, „Postfach anlegen“ ohne Plus | Maintainer-Vorgabe. |
| Gesperrt | Grund sichtbar (Regel) | Grund als 12-px-Text, `aria-describedby` | Nie stumm grau. |
| Lädt | `disabled` ohne Anzeige | „Läuft …“ und Dreher, `aria-busy`, bleibt fokussierbar | Doherty. |
| Link-Knopf | nicht definiert | Unterstrichen, ohne Rand, `--control-h` hoch | Für Dritt- und Textaktionen. |
| Segment (Darstellung, Seite, Breite) | nicht definiert | Rand `--field-border`, gewählt `--primary` | Aktiver Filter bleibt `--primary`. |

## Behälter, Tabellen, Listen

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Karte in Karte | `Ausklappbar` öffnet Kasten mit Rand und `bg-subtle/50` in der Karte; Einordnung mit vier Kästen | nie Kasten im Kasten, nie Karte in der Karte; Ausklappbar öffnet ohne Kasten, 1 px Linie oben | Maintainer-Vorgabe (Issues 57 bis 59). |
| Hinweis, Vorschau | `rounded-md border bg-subtle p-2`, mehrfach | **ein** Kasten auf `--subtle`, ohne Rand, 8 px Rundung, Innenabstand 16 | Maintainer-Vorgabe. |
| Abschnitt | nicht definiert | Überschrift, 1 px Linie oben, 24 px Abstand | Für Seiten ohne Karten. |
| Kartentitel | `text-base` | 18/24/600 | Hierarchie. |
| Karteninnenabstand | `gap-3` | `gap-4` | Auf dem 8-px-Rhythmus. |
| Tabellenzeile | `py-3` | `--row-h` 44 px (12 + 20 + 12); „Kompakt“ 36 px als Einstellung unter „Konto“, nur bei `pointer: fine` | Touch braucht 44; Dichte ist eine Einstellung. |
| Tabellenkopf | ohne Fläche | `--subtle`, 40 px, `--muted` 500 | Der Kopf hebt sich ab. |
| Sortierung | `↑ ↓` als Text, halbe Deckkraft | Lucide `chevrons-up-down`, `arrow-up`, `arrow-down`, `aria-sort` | Einheitlich. |
| Auswahlspalte | 40 px | 48 px, ganze Zelle ist das Label | Fitts. |
| Handy | Mindestbreite 720 px, seitlich scrollen | Tabelle wird Liste: Titel, Aufbewahrung, Datum | Kein seitliches Scrollen. |
| Leerzustand | Rahmen mit Symbolfläche (`rounded-lg border`) | ohne Rahmen; Symbol auf 44-px-Fläche `--subtle`; ein Satz, ein Knopf | Keine Kästen im Kasten. |
| Liste | nicht definiert | Zeilen mindestens 56 px, 1 px Linie, Aktionen rechts | Einheitlich. |

## Navigation

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Menü | eine Liste mit elf Einträgen | drei Gruppen: Dokumente (Start, Eingang, Archiv), Ordnen und prüfen (Ordnung, Fristen, Prüfung), Einrichten (Quellen, Workflows, Verfahrensdokumentation, Zugänge, Benachrichtigungen) | Miller und Hick; Namen noch zu bestätigen. |
| Zähler | Pille mit Zahl bei gespeicherten Ansichten | nur am Eingang, gefüllt `--primary`, 6 px Rundung; Ansichten schlichter Text | Von Restorff: die einzige Marke. |
| Eintrag | 36 px, Text `--fg/80` | `--control-h`, inaktiv `--muted`, aktuell `--fg`, 600, `--subtle` | Fläche allein trägt nicht (1,1 : 1). |
| Kopfleiste | 56 px, Linie, Glas | 56 px, Linie, deckend | Siehe Linien. |
| Seitenkopf | Satz klein, Hauptaktion rechts | Satz 16/24 `--muted`, Hauptaktion rechts, am Handy darunter | Lesbarkeit. |
| Handy-Menü | „Menü“ mit `☰ ✕` | bleibt: Knopf „Menü“ (`aria-expanded`, Lucide `menu`/`x`), Fläche über dem Inhalt (`z-40`), Escape schließt; neu daneben Lupen-Knopf „Suchen“ mit eigener Fläche, nie beide offen | Maintainer-Vorgabe; jetzt auch unter 1024 px. |

## Meldungen, Dialoge, Bausteine

| Bereich | heute | neu | Begründung |
| --- | --- | --- | --- |
| Meldung | drei Teile (`Meldung.tsx`, Seitenmeldung) | bleibt; zusätzlich eingebettet als ein Kasten auf `--subtle`; Titel in `--danger` (Fehler) oder `--warn` (Warnung), Erfolg und Info nur im Symbol | Von Restorff; Farbe nie allein. |
| Rollen | Fehler `alert`, Erfolg `status` | bleibt; Erfolg bleibt stehen, kein Toast | WCAG 2.2.1. |
| Dialog | `p-5`, Satz 14 px, `border-red-700`-Knopf `bg-red-700` | `p-6`, Folgesatz 16/24, `--shadow-dialog`, `--scrim`, gefüllter Knopf `bg-danger`; Handy gestapelt | Der Satz, der Endgültiges sagt, ist der wichtigste. |
| Stufe 2 | Häkchen, Grund daneben | Grund darunter (`Löschung bestätigen geht erst nach dem Häkchen.`) | Passt in 400 px Breite. |
| Einmalwert | Rand und Fläche | ein Kasten auf `--subtle`, Innenabstand 16 | Eine Ebene. |
| „Was ist das?“ | `?` im Kreis, 40 px | Lucide `circle-question-mark`, 40/44 px, Satz 16/24 | Einheitliche Symbole. |
| Siegel-Zeile | Rand + Fläche, eigenes Schild | Fläche, Lucide `shield-*`; Etikett als Badge | Eine Ebene. |
| Fristvorschau | `border bg-subtle p-2`, mehrere | ein Kasten, Definitionsliste, `aria-live="polite"` | Maintainer-Vorgabe. |
| Auswahlleiste | 48 px, `fixed` über dem Inhalt | 48 px, `sticky bottom-4` als letztes Kind des Inhalts; Rand `--border`, 8 px, `--shadow-float` | Sie verdeckt nie die Pagination. |
| Tooltip | nicht vorhanden | nur für Nur-Symbol-Knöpfe, Wiederholung des `aria-label`; 500 ms, nur Deckkraft | Hover bleibt nie Träger einer Erklärung. |
| Pagination | `Zurück`/`Weiter` mit Seitenzahl | „Vorherige Seite“, „Nächste Seite“; Anzeige „… Seite 1 von 39“ | Verb mit Objekt. |
| Fortschritt | nicht vorhanden | Satz „Schritt 2 von 5: …“ plus fünf Segmente | Text trägt die Aussage. |

## Nachprüfung (Design-Test): zusätzliche Regeln

| Bereich | neu | Begründung |
| --- | --- | --- |
| Tag-Auswahl (ARIA) | Auslöser `aria-haspopup="menu"`; Liste `role="menu"`; Einträge `role="menuitemcheckbox"` mit `aria-checked="true|false|mixed"`; „einige“ zusätzlich sr-only „bei einigen gewählt“. `role="option"` mit `aria-selected="mixed"` ist verboten. | axe: `mixed` ist bei `aria-selected` ungültig. |
| Tag-× und Tag als Link | sichtbar 24 px, Trefferfläche 44 × 44 am Touch (`after:absolute after:-inset-2.5`, beim Link mit Rand `-inset-[11px]`) | WCAG 2.5.8 mit Komfort am Daumen. |
| Touch-Ziele | Sortierknöpfe, Nur-Symbol-Knöpfe, Segment, Auswahlleiste, Sprunglink: 44 × 44 (`min-w-(--control-h)`); Titel-Link in der Tabelle mindestens 24 px hoch | Fitts; geprüft mit `quelle/ziele.mjs` bei 390 px. |
| Lädt | Status in voller Farbe (kein `opacity-50`), `aria-busy`, nicht `aria-disabled`. Das Gesperrt-Aussehen gilt nur für wirklich gesperrt. | „Läuft …“ muss lesbar bleiben (4,5 : 1), auch beim Gefahrknopf. |
| Gesperrte Knöpfe | Jeder Grund hat eine eigene `id`, der Knopf verweist per `aria-describedby` darauf | Gültige Verweise. |
| Gefahr gefüllt, gedrückt | Mischung 85 % statt 80 % | 4,90 : 1 hell, 4,80 : 1 dunkel (80 % hätte 4,49 und 4,34). |
| Seitenüberschrift am Handy | Unter 1024 px ist die Kopfleiste weg; der Titel steht dann als sichtbare `h1` (18/24) am Anfang des Inhalts. Auf der Dokumentseite ist der Dokumentname die `h1`. Nie zwei `h1` zugleich sichtbar. | Jede Seite hat eine `h1`. |
| Abstände außerhalb der Skala | Erlaubt sind nur Formeln aus Skala und Zielgröße: Mitte in der Zeile `(--control-h − 20) / 2` (10 oder 12 px) und `(--control-h − 16) / 2`; Innenabstand eines Feldes mit Symbol 12 + 16 + 8 = 36 px links, `--control-h` rechts; Segment ohne Innenabstand, Knöpfe `--control-h`; Trefferfläche `inset: -10px` | Optisch begründet, aber jede Zahl hat eine Formel. |
| Tab-Reihenfolge Dokumentseite | spaltenweise: Kopf, linke Spalte ganz (Einordnung), dann rechte Spalte (Vorschau, Prüfwerte, Löschung) | Wer das Formular ausfüllt, springt nicht zwischen Spalten; gleich dem Markup. |
| Archivliste 768 px | Typ und Größe entfallen unter 1024 px; Name mindestens `14rem` | Der Name bricht nicht mitten im Wort. |
| Filterzeile am Handy | Unter 768 px: Suche in eigener Zeile, Art und Tags darunter, je halbe Breite | Das Suchfeld ist lesbar. |
| Beispielrahmen am Handy | Unter 768 px keine Vorschau im Rahmen, stattdessen Links zu den Seiten | Der verkleinerte Rahmen ist unlesbar. |
| Doku-Seite | Demos erzeugen keine eigenen `h1`, `h2` oder Landmarken (Überschriften der Demos ab `h4`, Karten als `role="group"`, Navigation mit eigenem Namen) | Gültige Überschriftenfolge, eindeutige Landmarken. |

## Entschieden (alle Fragen beantwortet, nichts offen)

| Frage | Entscheidung | Begründung |
| --- | --- | --- |
| Menüwort | „Verfahrensdokumentation“ ausgeschrieben, Menüwort und Seitentitel gleich | Freigabe durch Tristan; ein Wort, eine Bedeutung. |
| Menügruppen | Dokumente / Ordnen und prüfen / Einrichten, Zähler am Eingang | Miller und Hick; bestätigt. |
| Marke | Unterzeile „Belegt ist, was du beweisen kannst.“ bleibt | Steht als `app_claim` in `messages/de.json` und im heutigen `Sidebar.tsx`. |
| Rand von Checkbox und Radio | `--field-border` (Bedienelement, 3 : 1); gewählt `--primary` | Ein Rand für alles Bedienbare. |
| 1 Tablet | Unter 1024 px wird die Seitenleiste zum Knopf „Menü“ | Bei 768 px blieben neben 256 px Leiste nur 512 px für den Inhalt. |
| 2 Ladeknopf | Der Dreher bleibt, bei reduzierter Bewegung steht er still, der Text bleibt | Ein Fortschrittszeichen muss sich bewegen, sonst wirkt der Knopf eingefroren. |
| 3 Pflichtfelder | „(optional)“ am seltenen Feld plus ein Satz oben im Formular | Weniger Zeichen auf der Seite. |
| 4 Dichte | „Kompakt (36 px)“ ist eine Einstellung unter „Konto“, vorgegeben „Normal (44 px)“ (siehe Regel unten) | Der Daumen braucht 44 px; mit der Maus darf es dichter sein. Eine Einstellung statt eines Standards (Hick). |
| 5 Titelgrößen | 18/24 in der Kopfleiste, 24/32 im Inhalt, nie beide zugleich | Zwei Orte, je eine Regel. |
| 6 Tag-Farben | Mitteltöne als Punkt je Modus, neues Feld `punkt: { hell, dunkel }` in `shared/ordnung.ts` (Tabelle unten) | Heute ist der Punkt hell fast schwarz und dunkel pastell: Rot, Orange, Gelb lassen sich kaum trennen. |
| 7 Monospace | System-Monospace für Prüfwerte, keine neue Abhängigkeit | Kein zusätzlicher Download. |
| 8 Tooltip | Erlaubt, nur als Wiederholung des `aria-label` bei Nur-Symbol-Knöpfen; mittig über dem Knopf | Touch zeigt ihn nie, darum trägt er nie eine Erklärung. |
| 9 Suche am Handy | Lupen-Knopf neben „Menü“, öffnet die globale Suche als Fläche (siehe Regel unten) | Unter 1024 px entfällt die Kopfleiste und damit die Suche. |

### Regel Dichte der Tabellen

- Token `--row-h`: `44px`; Kompakt `36px`. Der Root trägt `data-dichte="kompakt"`, die Einstellung steht unter „Konto“ als Segment „Normal (44 px) / Kompakt (36 px)“ und wird pro Konto gespeichert.
- `@media (pointer: fine) { html[data-dichte="kompakt"] { --row-h: 36px } }`: Kompakt gilt **nur mit der Maus**. Am Touch bleibt es immer 44 px; der Text bei der Einstellung sagt das.
- Zeilenpolster `(--row-h − 20) / 2` (12 oder 8 px) plus die 1-px-Trennlinie. Knöpfe, Felder, Reiter, Menüeinträge, Auswahlspalte und Kopfzeile der Tabelle bleiben `--control-h`.
- Im Mockup: `beispiel-konto.html` (Einstellung mit Vorschau) und ein Umschalter über der Archivliste (nur zum Ausprobieren).

### Regel Suche am Handy (ersetzt den Satz aus `DESIGN.md` „Suche und Inhalt kommen sofort darunter“)

- Unter 1024 px steht neben „Menü“ ein Lupen-Knopf: 44 × 44, `aria-label="Suchen"`, `aria-expanded`, `aria-controls`.
- Er öffnet die globale Suche als Fläche über dem Inhalt (wie das Menü, `z-40`, `--shadow-float`): Der Fokus geht ins Suchfeld, Escape schließt, der Fokus kehrt zum Knopf zurück, das Symbol wird zum ✕.
- Menü und Suche sind nie gleichzeitig offen: Öffnet das eine, schließt das andere.

### Tag-Farben: Punkt-Ton je Modus

Vorschlag für `shared/ordnung.ts`: je Farbe `punkt: { hell, dunkel }` neben `hintergrund` und `schrift`. Alle Werte sind gegen `--bg` und `--subtle` des jeweiligen Modus gerechnet und erreichen mindestens 3 : 1 (knappster Wert: Orange hell auf `--subtle` mit 3,24 : 1). Rot, Orange und Gelb liegen in Farbton und Helligkeit auseinander; der Name des Tags steht immer daneben.

| Farbe | Hell | auf `--bg` | auf `--subtle` | Dunkel | auf `--bg` | auf `--subtle` |
| --- | --- | --- | --- | --- | --- | --- |
| Grau (`grau`) | `#71717a` | 4,83 : 1 | 4,40 : 1 | `#a1a1aa` | 7,76 : 1 | 6,91 : 1 |
| Rot (`rot`) | `#dc2626` | 4,83 : 1 | 4,39 : 1 | `#f87171` | 7,19 : 1 | 6,40 : 1 |
| Orange (`orange`) | `#ea580c` | 3,56 : 1 | 3,24 : 1 | `#fb923c` | 8,79 : 1 | 7,83 : 1 |
| Gelb (`gelb`) | `#a16207` | 4,92 : 1 | 4,48 : 1 | `#facc15` | 12,99 : 1 | 11,57 : 1 |
| Grün (`gruen`) | `#159a45` | 3,66 : 1 | 3,33 : 1 | `#4ade80` | 11,42 : 1 | 10,17 : 1 |
| Türkis (`tuerkis`) | `#0d9488` | 3,74 : 1 | 3,41 : 1 | `#2dd4bf` | 10,69 : 1 | 9,52 : 1 |
| Blau (`blau`) | `#2563eb` | 5,17 : 1 | 4,70 : 1 | `#60a5fa` | 7,83 : 1 | 6,97 : 1 |
| Violett (`violett`) | `#7c3aed` | 5,70 : 1 | 5,18 : 1 | `#a78bfa` | 7,31 : 1 | 6,51 : 1 |
| Rosa (`rosa`) | `#db2777` | 4,60 : 1 | 4,18 : 1 | `#f472b6` | 7,51 : 1 | 6,69 : 1 |


## Abweichungen von den Skills (Projekt gewinnt)

- `design-taste-frontend` rät von Lucide ab; Belegt nutzt Lucide, das bleibt.
- Mockup liest die Lucide-Pfade aus `lucide-react` 1.73 eines anderen Projekts, weil im Hauptordner von Belegt kein `lucide-react` installiert ist (die Symbole sind identisch, ISC).
