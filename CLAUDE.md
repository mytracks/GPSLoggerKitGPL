# GPSLoggerKitGPL

Swift-Paket (GPL-3.0-or-later, nur macOS 12+) für Dateiformate und Geräteprotokolle von GPS-Loggern, die aus GPL- oder
damit vereinbaren Quellen portiert sind. Baut auf GPSLoggerKit (MIT, `mytracks/GPSLoggerKit`) auf und wird von
myTracks Loader (`mytracks/gpsloader`) per Paket-URL und Version eingebunden.

## Arbeitsweise

- Spec-getrieben mit **OpenSpec** (`openspec/`). Vor neuen Features einen Change anlegen (`/opsx:propose`).
- Verbindlich sind Kontext und Regeln in `openspec/config.yaml`; „noch nicht bestätigt“ heißt: vorher mit dem
  Entwickler klären.
- Kommunikation und OpenSpec-Artefakte auf Deutsch. Code, Bezeichner, Kommentare, README und PROVENANCE auf Englisch.
- Ein Change ändert nur dieses Repository. Braucht eine Portierung etwas in GPSLoggerKit, ist das ein eigener Change
  dort (allgemein, ohne Code aus der Vorlage); die App übernimmt neue Versionen mit eigenen Changes.
- Die Planungshistorie bis 2026-11-19 liegt in `mytracks/gpsloader` unter `openspec/changes/archive/`.

## Portierungen (wichtig)

- GPL-Quelltext nur in einem Change lesen, dessen Proposal die Familie diesem Paket zuordnet, und nur für diese Familie.
  Ist eine Familie portiert, bleibt sie hier.
- Nur Vorlagen mit GPL-3.0-vereinbarer Lizenz; jede portierte Datei trägt die Urheberhinweise der Vorlage und
  `SPDX-License-Identifier: GPL-3.0-or-later`. `PROVENANCE.md` und `GPLFileFormats.credits` pflegen.
- gpsbabel-Vorlagen vom Tag `gpsbabel_1_7_0`, nur in einem temporären Ordner, nie im Repository. Das
  gpsbabel-Binary nur zur Black-Box-Gegenprüfung, als Prozess mit Argument-Array, nie über eine Shell.

## Wichtige Orte

- `Sources/GPSLoggerKitGPL/`: je Familie ein Ordner (Formate und Geräteprotokolle), `Support/` für Hilfsfunktionen.
- `Tests/GPSLoggerKitGPLTests/`: Tests mit Fixtures und simulierten Geräten; keine echten Ortsdaten.
- Alt-Quellen nur lesen, im Nachbar-Checkout: `../gpsloader/input/mytracks4mac/`, Analyse
  `../gpsloader/docs/legacy-analysis.md`.

## Technik

- macOS 12+, Swift 6 Language Mode, Strict Concurrency; einzige Abhängigkeit GPSLoggerKit.
- Tests: `swift test`. Lokal gegen einen ausgecheckten GPSLoggerKit-Stand: `swift package edit GPSLoggerKit --path ../GPSLoggerKit`.
- Releases: `Scripts/release.sh <Version>` (Tag und GitHub-Release, nur nach Freigabe des Entwicklers).
