# mtk-import Specification

## Purpose
Reads memory images of MTK loggers (mtk-bin) and Holux loggers (m241-bin), ported from gpsbabel 1.7.0. They become tracks and waypoints with position quality.

## Requirements

### Requirement: Header
The import SHALL take the format mask (bytes 2–5, little endian) from the header at the start of the image. If the recording mode (bytes 6–7) is neither `0x0104` nor `0x0106` and the file is larger than 64 KiB, it SHALL use the header of the second block.

#### Scenario: Invalid first header
- **WHEN** the header of the first block has the recording mode `0x0000` and the second block has a valid header
- **THEN** the format mask of the second header applies

### Requirement: Blocks
The import SHALL read the image in blocks of 64 KiB, the records of a block from offset `0x200`. Four bytes `0xFF` or the end of the block SHALL end the block, and reading SHALL continue in the next block at `0x200`.

#### Scenario: Two blocks
- **WHEN** the first block is padded with `0xFF` after three records and the second block contains two more from `0x200`
- **THEN** the image results in five points

### Requirement: Fields of the records
Every record SHALL contain the fields whose bit is set in the format mask, in ascending bit order and little endian. Evaluated are time (UTC, seconds since 1970), validity, latitude, longitude, height, speed (km/h), course, PDOP, HDOP and VDOP (hundredths), used satellites and milliseconds; the other fields SHALL only be skipped. A record without latitude or longitude SHALL NOT result in a point.

#### Scenario: Record of an iBlue 747
- **WHEN** the format mask contains time, validity, latitude, longitude, height and speed and a record encodes 2026-11-02T12:00:00Z, SPS, 50.0°, 8.0°, 100 m and 36 km/h
- **THEN** a point results with these values, the fix type `3d` and the speed 10 m/s

#### Scenario: Milliseconds
- **WHEN** the format mask contains milliseconds and a record has the value 500
- **THEN** the time of the point lies 0.5 s after the full second

### Requirement: Checksum
For MTK loggers a `*` and a checksum SHALL follow the fields, for Holux only the checksum. The checksum SHALL be the XOR of all field bytes. If the `*` is missing for an MTK logger and `0xFF` is there instead, the record SHALL be skipped without a point.

#### Scenario: Wrong checksum
- **WHEN** the checksum of a record is wrong
- **THEN** no point results from it, and a warning counts the record

### Requirement: Satellite data
If the bit for satellite data is set, the record SHALL contain for every satellite in view a block of identifier, use and count and, if set, elevation, azimuth and signal strength. The number of blocks SHALL follow from the first block; with 0 satellites one block without the optional fields SHALL follow. These data SHALL be skipped but included in the checksum.

#### Scenario: Three satellites
- **WHEN** a record contains satellite data for three satellites with elevation, azimuth and signal strength
- **THEN** the following record is read at the right place, and the checksum matches

### Requirement: Fix type
The validity SHALL be taken over like this: `0x0001` gives the fix type `none`, `0x0002` gives `3d`, `0x0004` gives `dgps`; all other values give no fix type. A point without a fix or with an unknown fix type at the position 90° N/0° or 0°/0° SHALL be discarded.

#### Scenario: Nonsensical position
- **WHEN** a record has the validity `0x0001` and the position 0°/0°
- **THEN** no point results from it

### Requirement: Info blocks
A block of seven bytes `0xAA`, a type, four data bytes and four bytes `0xBB` SHALL be read as an info block and SHALL NOT result in a point. Type `0x02` SHALL change the format mask from the following record on.

#### Scenario: New format mask
- **WHEN** an info block of type `0x02` removes the milliseconds from the format mask
- **THEN** the following records are read without this field

### Requirement: Tracks
For MTK loggers an info block of type `0x07` with the value `0x0106` (logger switched on) SHALL start a new track, for Holux a change of interval (type `0x03`) or distance (type `0x04`). An image with one track SHALL carry the file name without extension as track name; several tracks SHALL additionally carry their running number in parentheses.

#### Scenario: Logger switched on twice
- **WHEN** an info block "logger switched on" lies between two groups of records
- **THEN** the recording contains two tracks `log (1)` and `log (2)` for the file `log.bin`

### Requirement: Waypoints
A record whose recording reason contains the bit `0x0008` (button) SHALL additionally result in a waypoint at the same position. For Holux a record after the identifier `HOLUX…WAYPNT` SHALL also result in a waypoint. The waypoints SHALL be named `POI` followed by their running number.

#### Scenario: Button pressed
- **WHEN** a record has the recording reason `0x0008`
- **THEN** a track point and a waypoint `POI 1` result

### Requirement: Holux
The format `m241-bin` SHALL read latitude and longitude as 32-bit floating-point numbers and the height as the upper three bytes of a 32-bit floating-point number and ignore bit 31 of the format mask. Identifiers `HOLUX…` of 16 bytes (followed by four optional spaces) SHALL be skipped. After the identifier `HOLUXGR245` or `HOLUXM1200` the import SHALL read the height from the speed field and the speed in cm/s from the height field.

#### Scenario: Holux M-241
- **WHEN** a Holux image contains a record with 50.0°, 8.0° and 100 m
- **THEN** a point results with this position to the precision of a 32-bit floating-point number and with 100 m elevation

#### Scenario: Holux GPSport 245
- **WHEN** after the identifier `HOLUXGR245LOGGER` a record encodes 500 in the height field and 120 m in the speed field
- **THEN** the point has the speed 5 m/s and the elevation 120 m

### Requirement: Detection of the MTK formats
The format detection SHALL recognize an MTK image by a header with the time bit set in the format mask, a valid recording mode and an info block, a Holux identifier or a record with a valid checksum at `0x200`. If the range from `0x200` contains an identifier `HOLUX` or bit 31 of the format mask is set, it SHALL suggest `m241-bin`, otherwise `mtk-bin`.

#### Scenario: Image of an iBlue 747
- **WHEN** the file `data.bin` of an MTK logger is checked
- **THEN** the detection suggests `mtk-bin`

#### Scenario: Image of a Holux M-241
- **WHEN** an image with the identifier `HOLUXGR241LOGGER` is checked
- **THEN** the detection suggests `m241-bin`

#### Scenario: SkyTraq image
- **WHEN** a SkyTraq image is checked
- **THEN** the detection suggests neither `mtk-bin` nor `m241-bin`
