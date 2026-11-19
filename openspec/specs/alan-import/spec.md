# alan-import Specification

## Purpose
Reads the track log files (`.trl`) of the Alan Map500, ported from gpsbabel 1.7.0. They become up to eight tracks without timestamps.

## Requirements

### Requirement: Structure of the Alan track log file
The format `alantrl` SHALL read a file as four blocks of 0x10000 bytes with two track logs each, followed by the header at offset 0x40000, all values little endian. A track log consists of 2500 coordinate pairs x/y (32 bit each) followed by 2500 pairs of speed and altitude (16 bit each). If the file is too short or the header does not carry the identifier `0x38CB1200`, reading MUST end with the hint that it is not an Alan file.

#### Scenario: Wrong identifier
- **WHEN** a file of 0x40170 bytes carries another identifier at offset 0x40000
- **THEN** reading ends with the error that the file is not an Alan track log file

#### Scenario: File too short
- **WHEN** the file is shorter than 0x40170 bytes
- **THEN** reading ends with the same error

### Requirement: Tracks and points
For each of the eight track headers with the occupied field set, the format SHALL build a track. The name is the name field without trailing spaces and null bytes. It contains the first `totalpt` points of the corresponding track log. Latitude SHALL be −y/36000 degrees, longitude x/36000 degrees, altitude value/5 meters, speed value/720 m/s; a negative speed is dropped. Points have no time.

#### Scenario: Two occupied tracks
- **WHEN** the headers 0 and 3 are occupied, with 100 and 2500 points
- **THEN** two tracks result in this order, with 100 and 2500 points and the names from the headers

#### Scenario: Conversion
- **WHEN** a point has x = 288000, y = −1800000, altitude 500 and speed 7200
- **THEN** it lies at 50° N, 8° E, 100 m altitude, with 10 m/s and without a time

#### Scenario: Too many points
- **WHEN** a header reports more than 2500 points
- **THEN** the format reads 2500 points and emits a warning

### Requirement: Detection of Alan files
The format SHALL recognize a file if its first 4096 bytes are present and all 512 coordinate pairs in them are plausible (|x| ≤ 180 · 36000, |y| ≤ 90 · 36000). It MUST state the extension `trl`.

#### Scenario: Text file with extension trl
- **WHEN** a text file with the extension `.trl` is chosen
- **THEN** the format does not recognize it as an Alan file
