# GPSLoggerKitGPL

Swift package (GPL-3.0-or-later, macOS 12+ only) for file formats and device protocols of GPS loggers that are ported
from GPL or compatible sources. Builds on GPSLoggerKit (MIT, `mytracks/GPSLoggerKit`) and is used by myTracks Loader
(`mytracks/gpsloader`) by package URL and version.

## Way of working

- Spec-driven with **OpenSpec** (`openspec/`). Before new features, create a change (`/opsx:propose`).
- The context and rules in `openspec/config.yaml` are binding; "not yet confirmed" means: clarify with the developer
  first.
- Language (decided on 2026-11-19): everything in this repository is English, including OpenSpec artifacts. The
  conversation with the developer is in German. Localized format names exist in German and English.
- A change modifies only this repository. If a port needs something in GPSLoggerKit, that is a change of its own there
  (generic, without code from the template); the app takes over new versions with changes of its own.
- The planning history up to 2026-11-19 is in `mytracks/gpsloader` under `openspec/changes/archive/` (in German).

## Ports (important)

- Read GPL source code only in a change whose proposal assigns the family to this package, and only for this family.
  Once a family is ported, it stays here.
- Only templates with a license compatible with GPL-3.0; every ported file carries the notices of the template and
  `SPDX-License-Identifier: GPL-3.0-or-later`. Keep `PROVENANCE.md` and `GPLFileFormats.credits` up to date.
- gpsbabel templates from the tag `gpsbabel_1_7_0`, only in a temporary folder, never in the repository. The gpsbabel
  binary only for black-box cross-checks, as a process with an argument array, never through a shell.

## Important places

- `Sources/GPSLoggerKitGPL/`: one folder per family (formats and device protocols), `Support/` for helpers.
- `Tests/GPSLoggerKitGPLTests/`: tests with fixtures and simulated devices; no real location data.
- Old sources, read only, in the neighboring checkout: `../gpsloader/input/mytracks4mac/`, analysis
  `../gpsloader/docs/legacy-analysis.md`.

## Technology

- macOS 12+, Swift 6 language mode, strict concurrency; the only dependency is GPSLoggerKit.
- Tests: `swift test`. Locally against a checked-out GPSLoggerKit: `swift package edit GPSLoggerKit --path ../GPSLoggerKit`.
- Releases: `Scripts/release.sh <version>` (tag and GitHub release, only after the developer's approval).
