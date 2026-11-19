# itracku-device Specification

## Purpose
Reads the memory of the XAiOX iTrackU over the serial port or Bluetooth, ported from gpsbabel 1.7.0. It becomes one track.

## Requirements

### Requirement: Detect the iTrackU
The driver SHALL send `WP AP-Exit` at 4800 baud, discard the input and send `W'P Camera Detect`, both with a trailing null byte. If the answer does not end within 1 second with the null-terminated identifier `WP GPS+BT`, the operation MUST end with a protocol error that reports that no iTrackU was found.

#### Scenario: Device answers
- **WHEN** the device reports `WP GPS+BT` on the detection
- **THEN** the driver starts reading the memory

#### Scenario: Other device
- **WHEN** a device at the port sends only NMEA sentences
- **THEN** the operation ends after 1 second at the latest with the protocol error that no iTrackU was found

### Requirement: Read the memory
The driver SHALL send the bytes `60 B5 00 00 00 00 00` and read the following data stream up to the end marker `WP Update Over`. It SHALL evaluate all complete 16-byte records before the end marker. If no data arrives for 1 second, it MUST end the operation with a timeout. This does not apply when the end marker has already been received.

#### Scenario: Memory with end marker
- **WHEN** the device sends 300 records and then the end marker, the last 40 records in the same block as the marker
- **THEN** the driver returns a track "iTrackU" with 300 points

#### Scenario: Device falls silent
- **WHEN** the device falls silent after 100 records without an end marker
- **THEN** the operation ends with a timeout

### Requirement: Decode records
A record SHALL contain longitude, latitude and time as 32 bit, the altitude in meters as 16 bit (all little endian), the speed in knots and a flag byte. Coordinates SHALL count as degrees · 10⁶ plus minutes · 10⁴, values above 0x80000000 negative. The time (UTC) SHALL carry second, minute, hour, day, month and year since 2000 in 6, 6, 5, 5, 4 and 6 bits. A record with the longitude 0xFFFFFFFF MUST be dropped.

#### Scenario: Conversion
- **WHEN** a record contains latitude 50300000, longitude 0x80000000 + 8150000, altitude 123, 10 knots and the time 2026-11-02 12:34:56
- **THEN** the point lies at 50.5° N and 8.25° W, 123 m high, with 5.144 m/s and the time 2026-11-02T12:34:56Z

#### Scenario: Empty memory slot
- **WHEN** a record consists only of 0xFF
- **THEN** no point results from it
