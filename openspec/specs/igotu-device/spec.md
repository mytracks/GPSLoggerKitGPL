# igotu-device Specification

## Purpose
Reads i-GotU loggers: GT-800/Pro over the serial port, GT-100/120/200/200e/600 over USB HID, after the developer's own myTracks code and igotu2gpx 0.3.0. Erasing is marked as experimental.

## Requirements

### Requirement: Commands
The driver SHALL start commands with `0x93`, pad them to 16 bytes and set the last byte so that the sum of all bytes is zero. For the GT-800 it SHALL send the command in one piece, for USB models in two pieces of 8 bytes, the first of which is acknowledged with an empty answer. Every answer SHALL start with `0x93` and a signed length (16 bit, big endian); it SHALL discard bytes before that. A negative length SHALL be repeated up to three times as a device error.

#### Scenario: Device error
- **WHEN** the device answers a command once with `93 FF FE`
- **THEN** the driver repeats the command and then reads all points

### Requirement: Reading
The driver SHALL switch the device to configuration mode (`93 01 01 03`), query the number of records (`93 0B 03 00 1D`; for the GT-800 with two additional bits), read the records from address `0x1000` in blocks of 4 KiB (`93 05 07`) and switch the device back to NMEA mode afterwards.

#### Scenario: Read a GT-800
- **WHEN** a GT-800 reports 150 records
- **THEN** the driver reads two blocks and returns the valid points

#### Scenario: Read a USB model
- **WHEN** a GT-200 reports 150 records over USB HID
- **THEN** the driver returns the same points as with the GT-800

### Requirement: Records
A record SHALL be 32 bytes long (big endian): flags (`0x04` waypoint, `0x10` invalid, `0x40` track start, `0xF1` debug text), year modulo 16 and month, day, hour, minute, milliseconds of the minute, latitude and longitude in 10⁻⁷ degrees and GPS altitude in centimeters. The year SHALL be the last matching year up to the current one. A record SHALL be valid without the invalid flag, for the GT-800 with more than four used satellites, for USB models with at least one.

#### Scenario: Year modulo 16
- **WHEN** in November 2026 a record contains the year modulo 16 = 11
- **THEN** the point lies in the year 2011

#### Scenario: Few satellites
- **WHEN** a record reports three used satellites
- **THEN** the driver takes it over only for USB models

### Requirement: Erase the memory (experimental)
The driver SHALL offer erasing as experimental: it SHALL search downwards from the end of the memory for the first used block and from there erase every block with the undocumented write commands, for the GT-800 out of 0x700 blocks, for the GT-100 out of 0x80, for the GT-120 out of 0x200 and for the GT-200 out of 0x100. For other USB models erasing MUST end with a protocol error.

#### Scenario: Erase the memory (experimental)
- **WHEN** the user confirms the warning and two blocks are used
- **THEN** the driver erases the blocks 2 and 1

#### Scenario: Model without erasing
- **WHEN** a GT-200e is to be erased
- **THEN** the operation ends with the hint that erasing is not supported for this model
