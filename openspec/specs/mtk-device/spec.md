# mtk-device Specification

## Purpose
Reads and erases MTK loggers (iBlue 747, Qstarz and others) and Holux M-241 and GPSport 245 over the serial port, ported from gpsbabel 1.7.0. Logging is switched on again after reading.

## Requirements

### Requirement: Commands
The driver SHALL send commands as NMEA-like sentences with an XOR checksum and read answer lines until a line with the expected identifier arrives or the waiting time expires. It SHALL skip other lines, in particular running NMEA output. An acknowledgment `$PMTK001` for the same command with the result 0, 1 or 2 SHALL count as a refusal.

#### Scenario: NMEA output in between
- **WHEN** the device sends a `$GPGGA` sentence before every answer
- **THEN** the driver still reads the answers correctly

### Requirement: Detect the device
The driver SHALL query the model with `$PMTK605` (answer `$PMTK705`). If the device does not answer, the operation MUST end with a protocol error. If it reports "GR-245", the driver SHALL send the Holux handshake before and after the operation.

#### Scenario: Not an MTK logger
- **WHEN** the device does not answer the model query
- **THEN** the operation ends with the hint that it is not an MTK logger

### Requirement: Reading
The driver SHALL query the log status, pause logging, query the flash usage and read the memory in blocks of 1 KiB from address 0 until the used size (rounded up to 64 KiB) is reached or a block contains only `0xFF`. Then it SHALL switch logging on again if it was on and decode the image like a `mtk-bin` or `m241-bin` file.

#### Scenario: Reading
- **WHEN** an MTK logger has two used 64 KiB blocks
- **THEN** the driver returns the same points as the memory image, and logging is on again afterwards

### Requirement: Special cases while reading
If the usage is unknown, the driver SHALL look for the end by reading at the start of every 64 KiB block. It SHALL request refused or unanswered blocks up to three times.

#### Scenario: Usage unknown
- **WHEN** the device does not report the flash usage
- **THEN** the driver finds the end of the data and returns the same points

#### Scenario: Refused block
- **WHEN** the device refuses the first read request
- **THEN** the driver requests the block again

#### Scenario: Holux M-241
- **WHEN** a Holux M-241 is read
- **THEN** the driver works with 38400 baud and decodes the image in the Holux format

### Requirement: Erase the memory
The driver SHALL pause logging, erase the memory with `$PMTK182,6,1`, wait up to 30 seconds for the confirmation and switch logging on again afterwards if it was on.

#### Scenario: Erase the memory
- **WHEN** the user confirms erasing
- **THEN** the memory is erased, and logging is on again afterwards
