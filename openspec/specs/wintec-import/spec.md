# wintec-import Specification

## Purpose
Reads the files of the Wintec loggers: TES (WBT-202), BIN memory images (WBT-100/200) and TK1 (WBT-201, G-Rays 2, WSG-1000), ported from gpsbabel 1.7.0. They become tracks and waypoints.

## Requirements

### Requirement: Wintec timestamps
The Wintec formats SHALL read times as a 32-bit value: second (bits 0–5), minute (6–11), hour (12–16), day (17–21), month (22–25) and year from 2000 (26–31), as UTC.

#### Scenario: Timestamp
- **WHEN** a timestamp encodes 2026-11-02 12:30:15 in these bits
- **THEN** the point has the time 2026-11-02T12:30:15Z

### Requirement: TES files
The format `wintec-tes` SHALL read a file as a sequence of 16-byte records (little endian): flags (16 bit), timestamp, latitude and longitude in 10⁻⁷ degrees (signed 32 bit) and altitude in meters (signed 16 bit). Every record SHALL result in a track point, with the flag `0x02` additionally in a waypoint. An incomplete last record SHALL result in a warning.

#### Scenario: Recording of a WBT-202
- **WHEN** a TES file contains three records, the second with the flag `0x02`
- **THEN** a track with three points and a waypoint `POI 1` at the position of the second result

#### Scenario: Truncated TES file
- **WHEN** a TES file ends after two records and 5 more bytes
- **THEN** two points and a warning about the truncated file result

### Requirement: BIN files
The format `wbt-bin` SHALL read records of 12 bytes (timestamp, latitude, longitude in 10⁻⁷ degrees) or 16 bytes (additionally altitude in decimeters). It SHALL choose the first length of which the file size is a multiple and for which all timestamps are valid (year from 2004); if none fits, reading MUST end with an error. A latitude from 100° (or down to −100°) SHALL start a new track; 100° are then subtracted (or added).

#### Scenario: New track in the north
- **WHEN** the third of five records has the latitude 150.0°
- **THEN** two tracks with two and three points result, and the third point lies at 50.0°

#### Scenario: Records with altitude
- **WHEN** a BIN file contains records of 16 bytes with the altitude 1234 (decimeters)
- **THEN** the points have the elevation 123.4 m

#### Scenario: No valid length
- **WHEN** a BIN file is 13 bytes large
- **THEN** reading ends with an error that names the file

### Requirement: TK1 files
The format `wbt-tk1` SHALL read files that start with `WintecLogFormat` and a null byte. From offset `0x400` it SHALL read records of 16 bytes: flags (16 bit), timestamp, latitude, longitude (10⁻⁷ degrees) and altitude in meters (signed, 16 bit). Records of only null bytes SHALL be skipped, the timestamp `0x04000000` SHALL mark the end. The flag `0x01` SHALL start a new track and `0x02` SHALL additionally result in a waypoint.

#### Scenario: Two tracks and one waypoint
- **WHEN** a TK1 file contains five records, the first and fourth with `0x01`, the second with `0x02`, followed by the end marker and more records
- **THEN** two tracks with three and two points and one waypoint result; the records after the end marker are not read

### Requirement: Track names of the Wintec formats
If a file results in one track, it SHALL carry the file name without extension; several tracks SHALL additionally carry their running number in parentheses. Waypoints SHALL be named `POI` followed by their running number in the file.

#### Scenario: Several tracks
- **WHEN** the file `log.tk1` results in two tracks
- **THEN** they are called `log (1)` and `log (2)`

### Requirement: Detection of the Wintec formats
The format detection SHALL recognize `wbt-tk1` by the header `WintecLogFormat`. It SHALL recognize `wbt-bin` if the complete records in the examined range have valid timestamps and longitudes of at most 180° for 12 or 16 bytes. It SHALL recognize `wintec-tes` if at least two 16-byte records in the examined range have flags of at most `0x0007`, valid timestamps, latitudes of at most 90° and longitudes of at most 180°.

#### Scenario: TK1 file
- **WHEN** a file with the header `WintecLogFormat` is checked
- **THEN** the detection suggests `wbt-tk1`

#### Scenario: TES file
- **WHEN** the file `TRK0001.TES` with valid records is checked
- **THEN** the detection suggests `wintec-tes`

#### Scenario: Other images
- **WHEN** a SkyTraq or MTK image is checked
- **THEN** the detection suggests none of the Wintec formats
