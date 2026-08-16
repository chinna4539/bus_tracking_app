# Data Gaps and Issues

## Generated from APSRTC GTFS feed

Source: https://github.com/Neo2308/apsrtc-gtfs/raw/refs/heads/main/gtfs/gtfs.zip


## Summary

- Total routes generated: 520
- Total stops generated: 465
- Total buses generated: 520

## Route Classification

- City/local routes: 1
- Region routes: 15
- Intercity routes: 504

## Stops

- Stops with coordinates: 465
- Stops missing coordinates: 0

## Trips and Shapes

- Total directions/trips: 520
- Total unique shapes: 520

## Missing Information

- Distance/duration: N/A (not in GTFS)
- First/last bus times: N/A (not in GTFS)
- Frequency: N/A (not in GTFS)
- Bus type: defaulted to "standard"
- Driver name: defaulted to "TBD"
- Live location: defaulted to 0.0, 0.0
- ETA, speed, available seats: defaulted

## Classification Notes

- City/local: routes entirely within Vizag city bounds
- Region: routes connecting Vizag to nearby regions
- Intercity: routes connecting Vizag to distant cities

## Known Issues

- Route 540/541 not found in GTFS feed
- Simhachalam and Kothavalasa stops not present in GTFS
- Some stop names may have duplicates in different locations
- Direction information preserved where available
- Shape data exists but not exported to JSON (app doesn't use shapes yet)

## Cross-check Sources

- OpenStreetMap: https://wiki.openstreetmap.org/wiki/Visakhapatnam_APSRTC_Bus_Routes
- Discrepancies: route numbers may not match OSM exactly due to GTFS padding
- Note: This GTFS feed may not contain all APSRTC routes or may use different numbering