# logger-kit-gpl Specification

## Purpose
GPSLoggerKitGPL is the Swift package (GPL-3.0-or-later) for file formats and logger protocols ported from source code under the GPL or a license compatible with it. It complements the MIT-licensed GPSLoggerKit without touching its clean-room rule.

## Requirements

### Requirement: License of the package
The package MUST be licensed under the GNU GPL version 3 or later (GPL-3.0-or-later) and contain the complete license text as a license file. The README of the package SHALL name the license and explain that every app that uses the package is covered by the GPL as a whole.

#### Scenario: License file
- **WHEN** the folder of the package is examined
- **THEN** it contains a license file with the text of the GPL version 3, and the README names GPL-3.0-or-later

### Requirement: Platform and dependencies
The package MUST build and run on macOS 12 and later. It MUST depend only on GPSLoggerKit, used by repository URL and published version, and on the system libraries, not on GPSLoaderKit, the app or third-party packages. Conversely, GPSLoggerKit MUST NOT depend on this package.

#### Scenario: Build with GPSLoggerKit alone
- **WHEN** this repository is freshly cloned and built and tested there
- **THEN** the Swift Package Manager resolves only GPSLoggerKit in a published version, and build and tests succeed

#### Scenario: No reverse dependency
- **WHEN** GPSLoggerKit is built alone
- **THEN** the build succeeds without the GPL package being present

### Requirement: Format catalog of the package
The package SHALL provide a catalog of its formats of its own that can be combined with the catalog of GPSLoggerKit. Every format SHALL have a fixed identifier, a localized name in German and English and the typical file extensions. An identifier MUST differ from all identifiers in GPSLoggerKit. The catalog may be empty.

#### Scenario: Empty catalog
- **WHEN** the package contains no format yet and an app combines its catalog with that of GPSLoggerKit
- **THEN** the result contains exactly the formats of GPSLoggerKit

#### Scenario: Unique identifiers
- **WHEN** the tests of the package run
- **THEN** a test checks that no identifier of the package also occurs in GPSLoggerKit

### Requirement: Permitted sources
Ported code MUST come from sources whose license is compatible with GPL-3.0-or-later. These include GPL version 2 or later, GPL version 3, LGPL version 2.1 or later, CC BY-SA 4.0 and permissive licenses such as MIT, BSD, Apache 2.0 and public domain. Sources under GPL version 2 only, under CC BY-SA up to version 3.0, under licenses of their own or without a recognizable license MUST NOT be used as long as the authors grant no compatible license.

#### Scenario: Source under GPLv2 only
- **WHEN** a template is licensed exclusively under the GPL version 2
- **THEN** it is not ported, and the design of the family names the reason

#### Scenario: License of its own
- **WHEN** a template has a license of its own that does not explicitly grant a compatible license
- **THEN** it is not ported, and the family is implemented from black-box observation

### Requirement: Provenance of ported formats
For every format the provenance list of the package MUST name the templates: project, file, version or commit, authors and license. It MUST also name own additions, specifications and black-box observations. Every source file ported from a template MUST carry a header with the copyright notices and the license of the template and the note on translation and modification with the date; new files name GPSLoggerKitGPL there.

#### Scenario: New format
- **WHEN** a format is added to the catalog of the package
- **THEN** the provenance list lists this format with its templates, and a test fails as long as the entry is missing

#### Scenario: Ported file
- **WHEN** a source file was translated from a template
- **THEN** its header names the authors of the template, its license and the translation and modification with the date, for new files "for GPSLoggerKitGPL"

### Requirement: Separation from GPSLoggerKit
A logger family SHALL be implemented either in GPSLoggerKit (clean-room) or in this package (port), not in both. If source code under a copyleft license was read for a family, it MUST stay in this package. The assignment of every family MUST be recorded in the project context.

#### Scenario: Family with GPL source code read
- **WHEN** gpsbabel source code was read for a family
- **THEN** there is no code for this family in GPSLoggerKit, and the project context assigns it to GPSLoggerKitGPL

### Requirement: Catalog of ported formats
The catalog of the package SHALL contain every ported format exactly once, in the order in which the formats were added. For every template `credits` SHALL contain an entry with project, authors, license and the source of the code of the version used.

#### Scenario: SkyTraq in the catalog
- **WHEN** an app queries the catalog of the package
- **THEN** it contains the format `skytraq-bin` (extension `bin`), and `credits` names gpsbabel with the license GPL-2.0-or-later and the address of the tag `gpsbabel_1_7_0`

### Requirement: MTK in the catalog
The catalog of the package SHALL contain the formats `mtk-bin` and `m241-bin` (extension `bin`). The entry for gpsbabel in `credits` SHALL also name the authors of the template `mtk_logger.cc`.

#### Scenario: Query the MTK formats
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `mtk-bin` and `m241-bin`, and the gpsbabel entry in `credits` names Per Borgentun

### Requirement: Wintec in the catalog
The catalog of the package SHALL contain the formats `wintec-tes` (extension `tes`), `wbt-bin` (extension `bin`) and `wbt-tk1` (extension `tk1`). The entry for gpsbabel in `credits` SHALL also name Robert Lipe as the author of the template `wintec_tes.cc`.

#### Scenario: Query the Wintec formats
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `wintec-tes`, `wbt-bin` and `wbt-tk1`, and the gpsbabel entry names Robert Lipe

### Requirement: Locosys in the catalog
The catalog of the package SHALL contain the formats `sbp` (extension `sbp`) and `sbn` (extension `sbn`). The entry for gpsbabel in `credits` SHALL also name Rodney Lorrimar and Tom Hughes.

#### Scenario: Query the Locosys formats
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `sbp` and `sbn`, and the gpsbabel entry names Rodney Lorrimar

### Requirement: GoPal in the catalog
The catalog of the package SHALL contain the format `gopal` (extension `trk`). The entry for gpsbabel in `credits` SHALL also name Jürgen Neumann.

#### Scenario: Query GoPal
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `gopal`, and the gpsbabel entry names Jürgen Neumann

### Requirement: Device protocols
The device protocols of the package SHALL use the device interface from GPSLoggerKit (connection: write, read with a time limit, read up to a terminator, discard input, change the baud rate; driver contract: read, erase, progress). The package SHALL NOT provide an interface of its own anymore. It SHALL depend on nothing but GPSLoggerKit for this. Every driver SHALL be testable without hardware against a simulated device.

#### Scenario: Simulated device
- **WHEN** a test runs a driver with a simulated connection
- **THEN** it runs without a serial port and returns the recording of the simulated device

#### Scenario: Shared interface
- **WHEN** an app uses drivers from GPSLoggerKit and from GPSLoggerKitGPL
- **THEN** both fulfil the same driver contract from GPSLoggerKit

### Requirement: igotu2gpx in the credits
`credits` SHALL name igotu2gpx with Michael Hofmann, the license GPL-3.0-or-later and the address of version 0.3.0.

#### Scenario: Credits with igotu2gpx
- **WHEN** the About window lists the ported formats and protocols
- **THEN** GPSBabel and igotu2gpx appear

### Requirement: Magellan in the catalog
The catalog of the package SHALL contain the format `magellan` with the extensions `log`, `upt` and `rte`.

#### Scenario: Query the Magellan format
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `magellan` with the extensions `log`, `upt` and `rte`

### Requirement: Alan Map500 in the catalog
The catalog of the package SHALL contain the format `alantrl` (extension `trl`). The entry for gpsbabel in `credits` SHALL also name Gunar Megger.

#### Scenario: Query the Alan format
- **WHEN** an app queries the catalog of the package
- **THEN** it contains `alantrl`, and the gpsbabel entry names Gunar Megger
