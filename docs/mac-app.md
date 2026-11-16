---
title: "Mac-App"
description: >-
  Belegt als App im Dock: baut den Stand des Quellcodes in Docker, startet ihn und zeigt ihn in einem eigenen Fenster.
---

# Mac-App

`Belegt.app` öffnet Belegt in einem eigenen Fenster, ohne Browser und ohne Terminal. Sie liegt in `mac/` und ist ein
dünner Rahmen aus Swift und einer WebView. Belegt selbst läuft in Docker Desktop.

## Installieren

```sh
bun run mac:bauen
```

Das legt `~/Applications/Belegt.app` an. Dann die App im Finder in den Dock ziehen. Neu bauen muss man nur, wenn sich
etwas in `mac/` ändert; den Stand von Belegt holt sich die App bei jedem Öffnen selbst.

Voraussetzungen: macOS 14, Xcode oder die Command Line Tools (für `swiftc`), Docker Desktop.

## Was beim Öffnen passiert

1. Ist Docker Desktop aus, startet die App es und wartet.
2. `docker compose up -d --build` baut Belegt aus dem Ordner mit der `compose.yml` neu und startet Postgres, Server und
   Worker. Hat sich nichts geändert, geht das in Sekunden.
3. Sobald `/healthz` antwortet, zeigt das Fenster Belegt unter `http://localhost:3400`.

„Aktuellste Version“ heißt also: der Stand, der im Ordner ausgecheckt ist. Wer einen anderen Branch will, wechselt ihn
dort und öffnet die App neu (oder wählt im Menü Ansicht › Neu bauen und starten).

Beim ersten Start legt die App `~/Library/Application Support/Belegt/belegt.env` an (nur für dich lesbar) mit
zufälligen Passwörtern, Sitzungsschlüssel und `BELEGT_SCHLUESSEL`, dazu die getrennten Datenbankrollen wie in
[Installation und Betrieb](betrieb.md). Die Datei wird nie überschrieben. **Sie gehört ins Backup:** Ohne
`BELEGT_SCHLUESSEL` sind gespeicherte Postfach-Passwörter nicht mehr lesbar. Die `.env` im Quellcode benutzt die App
nicht, deshalb stört sie die Entwicklung nicht.

Der Port ist 3400 und nur auf diesem Mac offen, weil Haben auf 3000 läuft. Wer ihn ändert, setzt `BELEGT_PORT` und
`BELEGT_URL` in `belegt.env` und öffnet die App neu.

## Beenden

- **Belegt beenden** (⌘Q) schließt nur das Fenster. Die Dienste laufen weiter, damit der Worker Postfächer und den
  Eingangsordner weiter abruft und der nächste Start schnell geht.
- **Dienste beenden und schließen** (⌥⌘Q) stoppt die Container. Die Daten bleiben in den Docker-Volumes.

## Einstellungen

⌘, öffnet die Einstellungen:

- **Lokal:** der Ordner mit der `compose.yml`. Vorgabe ist der Ordner, aus dem die App gebaut wurde.
- **Server:** die HTTPS-Adresse eines Servers im Netz; `http://` gilt nur für localhost. Dann braucht der Mac kein Docker.

## Verhalten des Fensters

Links auf andere Seiten öffnen im Standardbrowser, nur Belegt selbst bleibt im Fenster. Anhänge laden nach
`~/Downloads`. Uploads (auch Ordner), Drag and drop und die Kamera für Belege funktionieren; die Kamera fragt beim
ersten Mal um Erlaubnis. Ansicht › Im Browser öffnen zeigt die aktuelle Seite im Standardbrowser.

## Entwickeln

```sh
bun run mac:test    # Logik (Adressen, Port, Zugangsdaten) in mac/Quelle/Logik.swift
bun run mac:bauen   # bauen und nach ~/Applications legen
mac/bauen.sh --nur-bauen   # nur nach mac/.bau bauen
```

Alles, was sich ohne Oberfläche prüfen lässt, steht in `Logik.swift`; Docker, WebView und Fenster prüft man von Hand.
Die CI baut die App nicht, sie läuft auf Linux.
