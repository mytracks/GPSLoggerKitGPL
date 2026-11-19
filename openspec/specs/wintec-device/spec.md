# wintec-device Specification

## Purpose
Reads and erases Wintec WBT-100/200/201, G-Rays 2 and WSG-1000 over the serial port, ported from gpsbabel 1.7.0, with detection of the device type.

## Requirements

### Requirement: Detect the device type
The driver SHALL determine the device type in up to five rounds: WBT-200 if `$PFST` comes back on `$PFST,NORMAL` at 9600 baud; WBT-201 if `@AL` comes back on `@AL` at 57600 baud; WSG-1000 if the answer to `@AL,2,3` is `@AL,2,3,OK`. If none answers, the operation MUST end with a protocol error.

#### Scenario: No Wintec device
- **WHEN** no device answers at the port
- **THEN** the operation ends with the hint that the device type cannot be determined

### Requirement: Reading WBT-100/200
For the WBT-200 the driver SHALL read, after `$PFST,READLOGGER`, a header of 6 bytes with the number of points (bytes 2–3 plus 1) and then the records, first as 12-byte, otherwise as 16-byte records, depending on for which length all timestamps are valid. The records SHALL be decoded like a `wbt-bin` file.

#### Scenario: WBT-200
- **WHEN** a WBT-200 returns five records of 16 bytes, among them a track start
- **THEN** two tracks with two and three points and elevations result

### Requirement: Reading WBT-201 and WSG-1000
For the WBT-201 and WSG-1000 the driver SHALL query start and end of the recording and of the memory area (`@AL,5,1`, `5,2`, `5,9`, `5,10`), read the area in chunks of up to 4 KiB (`@AL,5,3,<position>`) and check every chunk by its XOR checksum (`@AL,CS,…`). It SHALL request faulty chunks again; after ten errors the operation MUST end. If the end lies before the start, it SHALL read up to the end of the area and then from the start of the area.

#### Scenario: WBT-201 with checksum
- **WHEN** the first chunk arrives with a wrong checksum
- **THEN** the driver requests it again and returns all points

#### Scenario: Overwritten ring buffer
- **WHEN** the recording continued beyond the end of the memory area
- **THEN** the driver returns the points in the order of recording

### Requirement: Erase the memory
For the WBT-200 the driver SHALL remove the files 27 to 31 and free the areas 0 to 3, for the WBT-201 and WSG-1000 it SHALL send `@AL,5,6`.

#### Scenario: Erase the memory
- **WHEN** the user confirms erasing
- **THEN** the driver sends the erase commands of the detected device type
