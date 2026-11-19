# gopal-import Specification

## Purpose
Reads the track logs (`.trk`) of Medion GoPal navigation devices, ported from gpsbabel 1.7.0. They become one track; the date comes from the file name, faulty points are discarded.

## Requirements

### Requirement: GoPal lines
The format `gopal` SHALL read lines with 9 or 12 comma-separated fields; it SHALL skip other lines without a warning. The fields SHALL be: time counter in microseconds, time `hhmmss` (UTC), longitude, latitude, altitude (m), speed (km/h), fix type (0 gives `none`, 2 gives `2d`), HDOP, satellites and, with 12 fields, additionally the date `YYYYMMDD`. The milliseconds of the time SHALL follow from the time counter (microseconds modulo 1,000,000, rounded to milliseconds).

#### Scenario: Line with date
- **WHEN** a line is `3801444, 080558, 8.0, 50.0, 295.28, 36.0, 2, 2.9, 3, 20261102, 0, 0`
- **THEN** a point results at 50.0° north and 8.0° east with the time 2026-11-02T08:05:58.801Z, the elevation 295.28 m, the speed 10 m/s, the fix type `2d`, HDOP 2.9 and 3 satellites

### Requirement: Date from the file name
If the lines have no date, the import SHALL take it from the file name `trackYYYYMMDD_hhmmss.trk` or `A_YYYYMMDD_hhmmss.trk` and advance it by one day when a time is smaller than the previous one. Without a date in the file name it SHALL take over the points without a time and produce a warning.

#### Scenario: Date in the file name
- **WHEN** the file `track20261102_093000.trk` contains lines with 9 fields and the time `083000`
- **THEN** the points have the date 2 November 2026

#### Scenario: Over midnight
- **WHEN** a line with `235959` is followed by one with `000001`
- **THEN** the second point lies on the following day

#### Scenario: No date
- **WHEN** the file `log.trk` contains lines with 9 fields
- **THEN** the points have no time, and a warning names their number

### Requirement: Faulty points
The import SHALL discard points whose longitude or latitude is 0 or outside the valid range, and points that would be reached faster than 200 km/h from the last point taken over (great-circle distance divided by the time difference in seconds). The reference of the first check SHALL be the first point with a fix and a valid position. Discarded points SHALL be dropped without a warning, as in the template.

#### Scenario: Jump in the data
- **WHEN** between two points 1 s apart a point lies 100 km away
- **THEN** this point is dropped, and the other two are kept

### Requirement: GoPal track
Every file SHALL result in one track named after the file without extension. Waypoints SHALL NOT result.

#### Scenario: Track instead of route
- **WHEN** a GoPal file with three valid lines is read
- **THEN** the recording contains one track with three points and no waypoints

### Requirement: Detection of GoPal
The format detection SHALL recognize a GoPal file by its first non-empty line and more than half of its first five non-empty lines being GoPal lines: 9 or 12 fields, the first an integer, the second a time `hhmmss`, longitude and latitude numbers.

#### Scenario: GoPal file
- **WHEN** a `.trk` file with GoPal lines is checked
- **THEN** the detection suggests `gopal`

#### Scenario: Other CSV file
- **WHEN** a V-900 or iBlue CSV file is checked
- **THEN** the detection does not suggest `gopal`
