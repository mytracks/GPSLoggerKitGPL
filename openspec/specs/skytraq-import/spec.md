# skytraq-import Specification

## Purpose
Reads memory images of SkyTraq Venus loggers (skytraq-bin), ported from gpsbabel 1.7.0. Full, compressed and high-rate entries become tracks, markers become waypoints.

## Requirements

### Requirement: Sectors
The import SHALL read a SkyTraq memory image in sectors of 4096 bytes; a shorter last sector SHALL be read as well. In every sector it SHALL read entries until the sector ends or a byte `0xFF` marks the rest as empty. If a sector ends this way more than 18 bytes before its end, the import SHALL end the image there; following sectors count as empty.

#### Scenario: Empty sector ends the image
- **WHEN** the second sector contains only `0xFF` and the third contains entries again
- **THEN** all points come from the first sector

#### Scenario: Full sector
- **WHEN** a sector is filled with entries to less than 18 bytes from its end
- **THEN** the import also reads the following sector

### Requirement: Full entries
An entry of type `0x4` (upper nibble of the first byte) SHALL be read as a full position record of 18 bytes: speed in km/h from the lower 4 bits of the first and the second byte, then time and the ECEF coordinates X, Y and Z in meters as signed 32-bit values in the byte order of the template. The GPS week (lower 10 bits) and the second of the week (bits from 12) SHALL follow from the time.

#### Scenario: Time of a full entry
- **WHEN** the time field of a full entry contains the week 380 and the second 302,400
- **THEN** the point has the GPS week 380 and the second 302,400 of the week

### Requirement: Conversion from ECEF
The ECEF coordinates of full and compressed entries SHALL be converted according to WGS 84 to latitude, longitude and height above the ellipsoid.

#### Scenario: Position from ECEF
- **WHEN** a full entry contains the ECEF coordinates of a position at 50.0° north, 8.0° east and 100 m height
- **THEN** a point results with this position to 0.00001° and 1 m and with the speed of the entry in m/s

### Requirement: Compressed entries
An entry of type `0x8` SHALL be read as a compressed record of 8 bytes: speed as with the full entry, a time difference in seconds (16 bit, big endian) and three position changes of 10 bits each. Values above 511 SHALL count as negative (511 minus value). Time and ECEF coordinates SHALL be continued from the previous entry.

#### Scenario: Continued position
- **WHEN** a full entry is followed by a compressed one with time difference 5 and the changes +3, −2 and +1 m
- **THEN** the second point lies 5 seconds after the first, at the ECEF position shifted by these values

### Requirement: High-rate entries
An entry of type `0x2` SHALL be read as a record of 20 bytes: GPS week from the lower 2 bits of the first and the second byte, speed in km/h (16 bit), time in milliseconds of the week (lower 30 bits), latitude and longitude in units of 2⁻²⁰ degrees and height in units of 2⁻⁷ m. The milliseconds SHALL be kept.

#### Scenario: Ten points per second
- **WHEN** two high-rate entries lie 100 ms apart
- **THEN** the times of the two points differ by 0.1 s

### Requirement: Markers
Entries of type `0x6` (like full) and `0xC` (like high rate) SHALL be read as markers (POI): they SHALL result in a track point and additionally in a waypoint with position, time and elevation of the point. The waypoints SHALL be named `POI` followed by their running number in the image.

#### Scenario: Button pressed
- **WHEN** the image contains an entry of type `0x6` after two full entries
- **THEN** three track points and a waypoint `POI 1` at the position of the third result

### Requirement: Time
The time of a point SHALL be computed from GPS week and second of the week from 6 January 1980 and converted to UTC with the leap seconds up to and including 2017 (GPS minus UTC = 18 s). Because the week has only 10 bits, the import SHALL choose the week cycle that puts the time into the 1024 weeks up to the time of reading.

#### Scenario: Current week cycle
- **WHEN** an entry contains the GPS week 380 and the second 302,400 and the image is read in November 2026
- **THEN** the point has the time 2026-07-22T11:59:42Z (GPS week 2428)

### Requirement: Faulty images
An entry with an unknown type or an entry that reaches beyond the end of the sector SHALL end reading the image at this place. The points read until then SHALL be kept, and a warning SHALL report the truncated image. A compressed entry without a previous full entry SHALL be discarded and counted as a warning.

#### Scenario: Unknown entry
- **WHEN** three valid entries are followed by a byte with the type `0x1`
- **THEN** the track contains three points, and a warning reports the truncated image

#### Scenario: Compressed entry at the start
- **WHEN** the image starts with a compressed entry
- **THEN** no point results from it, and a warning counts the discarded record

### Requirement: Track
Every image SHALL result in one track with one segment, named after the file without extension. Several images SHALL result in several tracks in the order in which they were passed.

#### Scenario: Image from gpsbabel
- **WHEN** the file `venus.bin` is read
- **THEN** the track is called `venus`

### Requirement: Detection
The format detection SHALL recognize a SkyTraq image by the entries at the start of the first sector having valid types, following each other without gaps up to the first `0xFF` or the end of the examined range, at least one full entry being among them and its ECEF position lying between 6,300 km and 6,450 km from the center of the earth.

#### Scenario: Image with extension .bin
- **WHEN** a file `log.bin` with a valid first sector is checked
- **THEN** the detection suggests `skytraq-bin`

#### Scenario: Other binary file
- **WHEN** a file with random bytes or a FIT file is checked
- **THEN** the detection does not suggest `skytraq-bin`
