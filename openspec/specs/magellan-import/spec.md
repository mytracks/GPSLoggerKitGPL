# magellan-import Specification

## Purpose
Reads the SD files of Magellan Meridian and eXplorist, ported from gpsbabel 1.7.0. They become one track and, from waypoint files, waypoints.

## Requirements

### Requirement: Decode Magellan sentences
A track sentence `$PMGNTRK` SHALL provide latitude (ddmm.mmm, N/S), longitude (dddmm.mmm, E/W), altitude in meters, unit, time (hhmmss.ss, UTC), a fixed field, an optional name and the date (ddmmyy, year from 2000). A waypoint sentence `$PMGNWPL` SHALL provide latitude, longitude, altitude, unit, name, comment and symbol. In the comment a sequence of ESC (0x1B) and two hex digits MUST count as the character it denotes.

#### Scenario: Track sentence
- **WHEN** the sentence `$PMGNTRK,5030.000,N,00815.000,W,00100,M,123456.50,A,,021126` with a checksum is read
- **THEN** a point results at 50.5° N and 8.25° W, 100 m high, with the time 2026-11-02T12:34:56.5Z

#### Scenario: Waypoint with a comma in the comment
- **WHEN** a waypoint sentence contains the name `HOME` and the comment `A<ESC>2CB`
- **THEN** a waypoint `HOME` with the comment `A,B` results

### Requirement: Read Magellan SD files
The format `magellan` SHALL read the files of Meridian and eXplorist line by line. Track sentences result in one track with the file name without extension. Waypoint sentences result in waypoints, but only in files with the extension `.upt`, as in the template. `$PMGNCMD,END` ends the file. A wrong checksum MUST result in a warning; the sentence counts anyway. The format MUST skip lines that do not start with `$` with a warning.

#### Scenario: Track log file
- **WHEN** the file `TRACK01.LOG` contains 50 track sentences and 2 waypoint sentences
- **THEN** a track `TRACK01` with 50 points results and no waypoint

#### Scenario: Waypoint file
- **WHEN** the file `POI.UPT` contains 3 waypoint sentences
- **THEN** 3 waypoints result

#### Scenario: Wrong checksum
- **WHEN** a track sentence carries a wrong checksum
- **THEN** the track contains the point, and the result contains a warning with the line number

### Requirement: Detection of Magellan files
The format SHALL recognize a file if the first 4096 bytes contain a sentence `$PMGNTRK`, `$PMGNWPL` or `$PMGNRTE` with a valid checksum. It SHALL state the extensions `log`, `upt` and `rte`.

#### Scenario: NMEA file
- **WHEN** a file contains only `$GPRMC` and `$GPGGA` sentences
- **THEN** the format does not recognize it
