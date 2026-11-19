# magellan-device Specification

## Purpose
Reads track and waypoints of Magellan Meridian and SporTrak over the serial port, ported from gpsbabel 1.7.0.

## Requirements

### Requirement: Send and receive Magellan sentences
The driver SHALL send commands as `$<content>*<XX>` with CR LF. XX is the XOR of all characters of the content in hex. It SHALL read lines up to LF, discard CR and wait at most 2 seconds for every line. If a line does not arrive, the operation MUST end with a timeout.

#### Scenario: Checksum of a command
- **WHEN** the driver sends `PMGNCMD,VERSION`
- **THEN** it sends `$PMGNCMD,VERSION*` with the XOR of the characters as two hex digits and CR LF

#### Scenario: Device falls silent
- **WHEN** the device sends no line for 2 seconds during the track
- **THEN** the operation ends with a timeout

### Requirement: Connect
The driver SHALL send `PMGNCMD,HANDOFF` and `PMGNCMD,VERSION` at 4800 baud and wait at most 6 seconds for `$PMGNVER`. If it does not know the product number, the operation MUST end with a protocol error. A wrong checksum before `$PMGNVER` MUST end the operation with the hint to a wrong baud rate. Except for GPS 315/320 and Map 410 it SHALL send `PMGNCMD,NMEAOFF` and accept a refusal.

#### Scenario: Meridian answers
- **WHEN** the device sends `$PMGNVER,33,…`
- **THEN** the driver sends `PMGNCMD,NMEAOFF` and then reads track and waypoints

#### Scenario: Unknown device
- **WHEN** the device reports the product number 99
- **THEN** the operation ends with a protocol error that names the number

#### Scenario: Wrong baud rate
- **WHEN** a sentence with a wrong checksum arrives before `$PMGNVER`
- **THEN** the operation ends with the hint to check the baud rate

### Requirement: Read track and waypoints
The driver SHALL send `PMGNCMD,TRACK,2` and read track sentences up to `$PMGNCMD,END`, then `PMGNCMD,WAYPOINT` and waypoint sentences up to `$PMGNCMD,END`. It decodes the sentences as in the spec `magellan-import`. If the device answers `$PMGNCMD,UNABLE`, this part SHALL stay empty, and the driver SHALL report that as a step. At the end it SHALL send `PMGNCMD,HANDOFF`. It sends no acknowledgments while reading.

#### Scenario: Reading
- **WHEN** the device returns 500 track sentences and 20 waypoint sentences
- **THEN** the driver returns a track "Magellan" with 500 points and 20 waypoints

#### Scenario: No waypoints
- **WHEN** the device answers `PMGNCMD,WAYPOINT` with `$PMGNCMD,UNABLE`
- **THEN** the driver returns the track without waypoints and reports the step "device sends no waypoints"
