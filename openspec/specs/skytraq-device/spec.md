# skytraq-device Specification

## Purpose
Reads and erases loggers with a SkyTraq Venus chipset (Canmore, MiniHomer and others) over the serial port, ported from gpsbabel 1.7.0, with automatic search of the baud rate.

## Requirements

### Requirement: Message frame
The driver SHALL send and receive messages as `0xA0 0xA1`, length (16 bit, big endian), payload, XOR checksum of the payload and `0x0D 0x0A`. Before sending it SHALL discard unread input. A message SHALL be sent up to three times until the device acknowledges it with `0x83` and its identifier; `0x84` counts as a refusal. An acknowledgment with identifier 0 SHALL be skipped. A wrong checksum MUST end the operation with a protocol error.

#### Scenario: Checksum error
- **WHEN** the device's acknowledgment has a wrong checksum
- **THEN** the operation ends with a protocol error

### Requirement: Find the baud rate
The driver SHALL find the baud rate of the device by setting 9600, 230400, 115200, 57600, 4800, 19200 and 38400 baud in turn and querying the software version (`0x02 0x01`, answer `0x80`). If an initial rate is set for the device, it SHALL try only this one. If the device answers on no rate, the operation MUST end with a protocol error.

#### Scenario: Known baud rate
- **WHEN** 38400 baud is set for the device
- **THEN** the driver sets only 38400 baud

#### Scenario: No logger
- **WHEN** no device answers at the port
- **THEN** the operation ends with the hint that no SkyTraq logger was found

### Requirement: Reading
The driver SHALL switch to the download rate of the device (command `0x05`), query the log status (`0x17`, answer `0x94`) and read the used sectors plus one. It SHALL request up to 255 sectors at once (`0x1D`), fewer after an error, and single sectors after a refusal (`0x1B`). An empty sector SHALL end reading. Then it SHALL restore the original baud rate and restart the device.

#### Scenario: Reading
- **WHEN** a logger at 38400 baud reports two used sectors
- **THEN** the driver reads at 230400 baud, then sets 38400 baud again, restarts the device and returns the points of the sectors

#### Scenario: Single sectors
- **WHEN** the device refuses reading several sectors
- **THEN** the driver reads the sectors one by one and returns the same points

### Requirement: Decoding the download
The sectors read SHALL be decoded like a memory image (`skytraq-import`), except that only an empty sector ends the image.

#### Scenario: Partly filled sector
- **WHEN** a partly filled sector is followed by another one with data that still belongs to the sectors read
- **THEN** its points are taken over too, as with gpsbabel

### Requirement: Erase the memory
The driver SHALL erase the memory with the command `0x19` and restart the device afterwards.

#### Scenario: Erase the memory
- **WHEN** the user confirms erasing
- **THEN** the driver sends the erase command, and the device is restarted
