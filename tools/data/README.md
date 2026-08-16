# Firestore Import Data Format

Place your real bus, route, and stop data in the JSON files below.
Then run the import tool:

```
dart tools/firestore_import.dart --service-account <path-to-service-account.json>
```

Use `--dry-run` to validate without writing:

```
dart tools/firestore_import.dart --dry-run --service-account <path-to-service-account.json>
```

---

## `buses.json`

Array of bus documents. Each object must have an `id` field (used as the Firestore document ID).

```json
[
  {
    "id": "540",
    "busNumber": "540",
    "routeNumber": "540",
    "routeId": "540",
    "routeName": "Maddilapalem → Simhachalam",
    "startingPoint": "Maddilapalem",
    "destination": "Simhachalam",
    "stops": [
      "Maddilapalem",
      "RTC Complex",
      "Dwaraka Bus Station",
      "HB Colony",
      "MVP Colony",
      "Seethammadhara",
      "NAD Junction",
      "Gopalapatnam",
      "Simhachalam"
    ],
    "currentStop": "HB Colony",
    "nextStop": "MVP Colony",
    "eta": "5 min",
    "status": "onTime",
    "busType": "standard",
    "driverName": "Raghav",
    "driverId": "DRV-001",
    "capacity": 52,
    "availableSeats": 18,
    "speed": 42.5,
    "lastUpdated": "2 min ago",
    "distanceRemaining": "13 km",
    "estimatedJourneyTime": "32 min",
    "isActive": true,
    "latitude": 0.0,
    "longitude": 0.0
  }
]
```

**Required fields:** `id`, `busNumber`, `routeNumber`, `routeName`, `startingPoint`, `destination`, `stops`, `currentStop`, `nextStop`, `eta`, `status`, `busType`, `driverName`, `capacity`, `availableSeats`, `speed`, `lastUpdated`, `distanceRemaining`, `estimatedJourneyTime`, `isActive`, `latitude`, `longitude`

**Optional fields:** `routeId`, `driverId`

**Enum values:**
- `status`: `onTime`, `delayed`, `diverted`, `cancelled`, `arrivingSoon`
- `busType`: `standard`, `express`, `ac`

---

## `routes.json`

Array of route documents. Each object must have an `id` field (used as the Firestore document ID).

```json
[
  {
    "id": "540",
    "routeNumber": "540",
    "title": "Maddilapalem → Simhachalam",
    "startingPoint": "Maddilapalem",
    "destination": "Simhachalam",
    "stops": [
      "Maddilapalem",
      "RTC Complex",
      "Dwaraka Bus Station",
      "HB Colony",
      "MVP Colony",
      "Seethammadhara",
      "NAD Junction",
      "Gopalapatnam",
      "Simhachalam"
    ],
    "distance": "22 km",
    "duration": "55 min",
    "totalStops": 9,
    "firstBus": "05:10 AM",
    "lastBus": "10:45 PM",
    "frequency": "15-20 min",
    "description": "APSRTC route 540 connects central Visakhapatnam with Simhachalam temple via major city stops."
  }
]
```

**Required fields:** `id`, `routeNumber`, `title`, `startingPoint`, `destination`, `stops`, `distance`, `duration`, `totalStops`, `firstBus`, `lastBus`, `frequency`, `description`

---

## `stops.json`

Array of stop documents. Each object must have an `id` field (used as the Firestore document ID).

```json
[
  {
    "id": "rtc-complex",
    "name": "RTC Complex",
    "latitude": 17.6868,
    "longitude": 83.2185,
    "zone": "Central",
    "isActive": true
  }
]
```

**Required fields:** `id`, `name`

**Optional fields:** `latitude`, `longitude`, `zone`, `isActive`
