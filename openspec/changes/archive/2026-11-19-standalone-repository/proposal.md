# Proposal: GPSLoggerKitGPL als eigenständiges Repository

## Why

GPSLoggerKitGPL ist am 2026-11-19 aus `mytracks/gpsloader` in dieses Repository umgezogen (Change `split-repositories`
dort) und bindet GPSLoggerKit jetzt per URL und Version ein. Zwei Anforderungen beschreiben noch den alten Ort:
- „Plattform und Abhängigkeiten“ prüft, ob die Ordner `Packages/GPSLoggerKitGPL` und `Packages/GPSLoggerKit` gemeinsam
  herausgelöst bauen.
- „Herkunft portierter Formate“ verlangt im Dateikopf den Hinweis, die Datei sei „für gpsloader“ übersetzt worden.

## What Changes

- „Plattform und Abhängigkeiten“ verlangt den Build aus einem frischen Checkout, mit GPSLoggerKit per URL in einer
  veröffentlichten Version.
- „Herkunft portierter Formate“: Neue portierte Dateien nennen „GPSLoggerKitGPL“. Bestehende Dateiköpfe mit
  „for gpsloader“ bleiben, weil sie den Stand ihrer Übersetzung korrekt beschreiben.
- README: Die Vorlage für den Dateikopf nennt „GPSLoggerKitGPL“.

## Betroffene Geräte und Treiberfamilien

Keine Änderung am Verhalten der Familien.

## Kompatibilität

Keine Änderung für die App; erste Version ist 0.1.0.

## Nicht im Umfang

- Release-Skript und Release-Notes (eigene Schritte des Umzugs).
- Änderungen an Formaten oder Protokollen.
- Umschreiben bestehender Dateiköpfe.

## Capabilities

### New Capabilities

(keine)

### Modified Capabilities

- `logger-kit-gpl`: „Plattform und Abhängigkeiten“ und „Herkunft portierter Formate“.

## Impact

`openspec/specs/logger-kit-gpl/spec.md` und die Kopfvorlage im README.
