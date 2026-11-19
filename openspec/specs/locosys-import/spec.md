# locosys-import Specification

## Purpose
Reads the data logger files (SBP) and SiRF binary files (SBN) of the Locosys loggers GT-11, GT-31 and BGT-31, ported from gpsbabel 1.7.0. They become tracks.

## Requirements

### Requirement: SBP header
The format `sbp` SHALL skip the first 64 bytes of a file as the header. A file below 64 bytes MUST end with an error that names the file.

#### Scenario: File too short
- **WHEN** an SBP file is 40 bytes large
- **THEN** reading ends with an error

### Requirement: SBP records
After the header the format `sbp` SHALL read records of 32 bytes (little endian): HDOP in fifths (byte 0), satellites (byte 1), milliseconds (bytes 2–3, modulo 1000), packed time (bytes 4–7), latitude and longitude in 10⁻⁷ degrees (bytes 12–19), altitude in centimeters (bytes 20–23), speed in cm/s (bytes 24–25) and course in hundredths of a degree (bytes 26–27). All records SHALL result in one track named after the file; an incomplete last record SHALL result in a warning.

#### Scenario: Record of a GT-31
- **WHEN** a record encodes 2026-11-02T12:00:00.250Z, 50.0°, 8.0°, 123.45 m, 250 cm/s, 9000 (90°), 7 satellites and HDOP 5
- **THEN** a point results with these values, the speed 2.5 m/s, the course 90° and HDOP 1.0

### Requirement: Packed SBP time
The packed time SHALL consist of second (bits 0–5), minute (6–11), hour (12–16), day (17–21) and `year × 12 + month` (bits 22–31, year from 2000), as UTC. A value whose remainder modulo 12 is zero SHALL denote December of the previous year.

#### Scenario: December
- **WHEN** the month bits contain `26 × 12 + 12`
- **THEN** the point lies in December 2026

### Requirement: SBN packets
The format `sbn` SHALL read a file as a sequence of SiRF packets: `0xA0 0xA2`, length (16 bit, big endian), payload, checksum (sum of the payload, 15 bit, big endian) and `0xB0 0xB3`. The first packet MUST be of type 253 (device information), otherwise reading ends with an error. Packets of type 13 (satellite list) SHALL be skipped.

#### Scenario: Not an SBN file
- **WHEN** the first packet is of type 41
- **THEN** reading ends with an error that names the file

### Requirement: Damaged SBN packets
A packet with a wrong checksum SHALL be discarded and counted. A damaged packet frame SHALL end reading with a warning about the truncated file.

#### Scenario: Wrong checksum
- **WHEN** the second of three navigation packets has a wrong checksum
- **THEN** two points and a warning result

### Requirement: SBN navigation data
A packet of type 41 SHALL result in a track point (big endian, offsets in the payload without the type byte): validity (bytes 0–1), mode (byte 3), year, month, day, hour, minute and milliseconds of the minute (bytes 10–17), latitude and longitude in 10⁻⁷ degrees (bytes 22–29), altitude in centimeters (bytes 34–37), speed in cm/s (bytes 39–40), course in hundredths of a degree (bytes 41–42), satellites (byte 87) and HDOP in fifths (byte 88).

#### Scenario: Navigation packet
- **WHEN** a navigation packet encodes 2026-11-02T12:00:01.500Z, 50.0°, 8.0° and 100 m
- **THEN** a point results with these values

### Requirement: SBN fix type
With validity 0 the mode (bits 0–2) SHALL give the fix type: 3 and 5 `2d`, 4 and 6 `3d` (with bit 7 set `dgps`), otherwise `none`. With another validity the fix type SHALL be `none`.

#### Scenario: Valid 3D fix with DGPS
- **WHEN** a navigation packet has the validity 0 and the mode `0x84`
- **THEN** the point has the fix type `dgps`

#### Scenario: Invalid solution
- **WHEN** a navigation packet has the validity `0x0001`
- **THEN** the point has the fix type `none`

### Requirement: Detection of the Locosys formats
The format detection SHALL recognize `sbn` by a first SiRF packet of type 253 with a valid checksum and a valid frame. It SHALL recognize `sbp` if the header contains from byte 7 a comma-separated device information of printable ASCII characters or byte 6 has the value `0xFD`, and the first record has a valid time (year from 2004), a latitude of at most 90° and a longitude of at most 180°.

#### Scenario: SBN file
- **WHEN** a file with an information packet at the start is checked
- **THEN** the detection suggests `sbn`

#### Scenario: SBP file
- **WHEN** a file with a Locosys header and a valid first record is checked
- **THEN** the detection suggests `sbp`

#### Scenario: Other files
- **WHEN** a SkyTraq, MTK or Wintec file is checked
- **THEN** the detection suggests neither `sbp` nor `sbn`
