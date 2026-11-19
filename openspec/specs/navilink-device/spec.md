# navilink-device Specification

## Purpose
Reads waypoints and track log of Locosys devices in NAVILINK mode (GT-11, GT-31, BGT-31, NaviGPS) over the serial port, ported from gpsbabel 1.7.0.

## Requirements

### Requirement: Navilink packets
The driver SHALL send and receive packets as `0xA0 0xA2`, length (16 bit, little endian, type plus payload), type, payload, sum of type and payload (15 bit, little endian) and `0xB0 0xB3`. A wrong header, an unexpected type, a wrong checksum or a wrong end MUST end the operation with a protocol error.

#### Scenario: Not in NAVILINK mode
- **WHEN** the device sends NMEA sentences instead of packets
- **THEN** the operation ends with the hint to switch the device to NAVILINK mode

#### Scenario: Checksum error
- **WHEN** a data packet has a wrong checksum
- **THEN** the operation ends with a protocol error

### Requirement: Reading
The driver SHALL synchronize with `SYNC` (0xD6), query the device information (0x20), read the waypoints in groups of 32 (0x28) and the track log from the reported address in groups of 512 points (0x14), acknowledging every group with `ACK` (0x0C). Track points SHALL contain position (10⁻⁷ degrees), altitude (feet), time (UTC), course and speed (2 km/h per unit), waypoints additionally their name.

#### Scenario: Reading
- **WHEN** the device reports 40 waypoints and 600 track points
- **THEN** the driver returns 40 waypoints and one track with 600 points, and it has acknowledged two groups
