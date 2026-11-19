## MODIFIED Requirements

### Requirement: Plattform und Abhängigkeiten
Das Paket MUST unter macOS ab Version 12 bauen und laufen. Es MUST nur von GPSLoggerKit, eingebunden per Repository-URL und veröffentlichter Version, und den Systembibliotheken abhängen, nicht von GPSLoaderKit, der App oder Paketen von Drittanbietern. GPSLoggerKit MUST umgekehrt nicht von diesem Paket abhängen.

#### Scenario: Bauen mit GPSLoggerKit allein
- **WHEN** dieses Repository frisch geklont und dort gebaut und getestet wird
- **THEN** löst der Swift Package Manager nur GPSLoggerKit in einer veröffentlichten Version auf, und Build und Tests gelingen

#### Scenario: Keine Rückabhängigkeit
- **WHEN** GPSLoggerKit allein gebaut wird
- **THEN** gelingt der Build, ohne dass das GPL-Paket vorhanden ist

### Requirement: Herkunft portierter Formate
Für jedes Format MUST die Herkunftsliste des Pakets die Vorlagen nennen: Projekt, Datei, Version oder Commit, Urheber und Lizenz. Sie MUST auch eigene Ergänzungen, Spezifikationen und Black-Box-Beobachtungen nennen. Jede aus einer Vorlage portierte Quelldatei MUST einen Kopf mit den Urheberhinweisen und der Lizenz der Vorlage und dem Hinweis auf Übersetzung und Veränderung mit Datum tragen; neue Dateien nennen dabei GPSLoggerKitGPL.

#### Scenario: Neues Format
- **WHEN** ein Format zum Katalog des Pakets hinzukommt
- **THEN** führt die Herkunftsliste dieses Format mit seinen Vorlagen auf, und ein Test schlägt fehl, solange der Eintrag fehlt

#### Scenario: Portierte Datei
- **WHEN** eine Quelldatei aus einer Vorlage übersetzt wurde
- **THEN** nennt ihr Kopf die Urheber der Vorlage, deren Lizenz und die Übersetzung und Veränderung mit Datum, bei neuen Dateien „for GPSLoggerKitGPL“
