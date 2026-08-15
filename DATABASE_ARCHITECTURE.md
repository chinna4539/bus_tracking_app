# Vizag Bus Tracker — Firestore Database Architecture

## Overview

This document defines the production-ready Firestore data model for the Vizag Bus Tracking System. It is designed for scalability, real-time updates, and clear separation between static transit data and dynamic live operations.

---

## Collections

### 1. users
**Purpose:** Passenger profiles and preferences linked to Firebase Auth.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| uid | string | Yes | Firebase Auth UID |
| name | string | Yes | Display name |
| email | string | Yes | Contact email |
| phone | string | No | Contact phone |
| photoUrl | string | No | Profile photo URL |
| role | string | Yes | Enum: `passenger`, `driver`, `admin` |
| createdAt | timestamp | Yes | Server timestamp |
| updatedAt | timestamp | Yes | Server timestamp |

**Document ID:** Firebase Auth UID

---

### 2. buses
**Purpose:** Static bus metadata. One document per physical bus.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| busNumber | string | Yes | e.g., `"540"` |
| routeId | string | Yes | Reference to `routes/{routeId}` |
| busType | string | Yes | Enum: `standard`, `express`, `ac` |
| capacity | integer | Yes | Total seats |
| driverId | string | No | Reference to `drivers/{driverId}` |
| isActive | boolean | Yes | Whether bus is in service |
| createdAt | timestamp | Yes | |
| updatedAt | timestamp | Yes | |

**Document ID:** Auto-generated or bus number if globally unique

**Indexes:** `routeId` + `isActive`

---

### 3. routes
**Purpose:** Static route definitions. One document per route variant.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| routeNumber | string | Yes | e.g., `"540"` |
| title | string | Yes | e.g., `"Maddilapalem → Simhachalam"` |
| startingPoint | string | Yes | Origin stop name |
| destination | string | Yes | Destination stop name |
| distance | string | Yes | e.g., `"22 km"` |
| duration | string | Yes | e.g., `"55 min"` |
| firstBus | string | Yes | e.g., `"05:10 AM"` |
| lastBus | string | Yes | e.g., `"10:45 PM"` |
| frequency | string | Yes | e.g., `"15-20 min"` |
| description | string | Yes | Route description |
| category | string | Yes | Enum: `express`, `city`, `night`, `general` |
| stopIds | array | Yes | Ordered list of stop document IDs |
| isActive | boolean | Yes | |
| createdAt | timestamp | Yes | |
| updatedAt | timestamp | Yes | |

**Document ID:** Route number or auto-generated

**Indexes:** `category` + `isActive`

---

### 4. stops
**Purpose:** Master stop registry with coordinates.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | Yes | Stop name |
| displayName | string | No | Friendly display name |
| latitude | double | Yes | WGS84 latitude |
| longitude | double | Yes | WGS84 longitude |
| zone | string | No | e.g., `"North Visakhapatnam"` |
| isActive | boolean | Yes | |
| createdAt | timestamp | Yes | |
| updatedAt | timestamp | Yes | |

**Document ID:** Auto-generated or stop code

---

### 5. route_stops
**Purpose:** Junction collection preserving ordered stop-to-route relationships.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| routeId | string | Yes | Reference to `routes/{routeId}` |
| stopId | string | Yes | Reference to `stops/{stopId}` |
| sequence | integer | Yes | 0-based order |
| estimatedArrivalOffset | string | No | e.g., `"+15 min"` from route start |
| createdAt | timestamp | Yes | |

**Document ID:** Auto-generated or composite `routeId_stopId`

**Why separate?** Avoids giant route documents and supports routes with many stops or multiple directions.

---

### 6. trips
**Purpose:** Active or recent trip instances. Separates a bus journey from static route data.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| busId | string | Yes | Reference to `buses/{busId}` |
| routeId | string | Yes | Reference to `routes/{routeId}` |
| driverId | string | No | Reference to `drivers/{driverId}` |
| status | string | Yes | Enum: `scheduled`, `active`, `completed`, `cancelled` |
| direction | string | Yes | Enum: `outbound`, `return` |
| currentStopIndex | integer | No | Current position in route stop list |
| startedAt | timestamp | No | Trip start time |
| completedAt | timestamp | No | Trip end time |
| createdAt | timestamp | Yes | |

**Document ID:** Auto-generated

**Indexes:** `busId` + `status`

---

### 7. drivers
**Purpose:** Driver registry.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | Yes | Full name |
| phone | string | Yes | Contact number |
| licenseNumber | string | Yes | Driving license number |
| busId | string | No | Currently assigned bus |
| status | string | Yes | Enum: `active`, `on_leave`, `off_duty` |
| userId | string | No | Linked to `users/{uid}` if driver uses app |
| createdAt | timestamp | Yes | |
| updatedAt | timestamp | Yes | |

**Document ID:** Auto-generated or driver code

**Indexes:** `busId` + `status`

---

### 8. live_locations
**Purpose:** Current live location per active bus/trip. Designed for efficient real-time updates.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| busId | string | Yes | Reference to `buses/{busId}` |
| tripId | string | No | Active trip reference |
| driverId | string | No | Current driver |
| latitude | double | Yes | Current latitude |
| longitude | double | Yes | Current longitude |
| speed | double | No | km/h |
| heading | double | No | Degrees |
| accuracy | double | No | GPS accuracy in meters |
| currentStopIndex | integer | No | Current stop in route |
| lastUpdated | timestamp | Yes | Last GPS update |

**Document ID:** Auto-generated or `bus_{busId}_{timestamp}`

**Indexes:** `busId` + `lastUpdated` (descending)

**TTL Recommendation:** Enable Firestore TTL on `lastUpdated` to auto-delete stale locations after 24 hours.

---

### 9. notifications
**Purpose:** Passenger and system notifications.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| userId | string | Yes | Recipient UID or `"global"` |
| title | string | Yes | Notification title |
| message | string | Yes | Notification body |
| type | string | Yes | Enum: `delay`, `traffic`, `diverted`, `cancelled`, `arriving_soon` |
| read | boolean | Yes | Read status |
| createdAt | timestamp | Yes | |

**Document ID:** Auto-generated

**Indexes:** `userId` + `createdAt` (descending)

---

### 10. favorites
**Purpose:** User-specific saved buses, routes, and stops.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| userId | string | Yes | Owner user UID |
| itemType | string | Yes | Enum: `bus`, `route`, `stop` |
| itemId | string | Yes | Document ID of referenced item |
| createdAt | timestamp | Yes | |

**Document ID:** Composite: `{userId}_{itemType}_{itemId}`

**Indexes:** `userId` + `itemType`

---

### 11. reports
**Purpose:** User-reported issues for admin review.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| userId | string | Yes | Reporter UID |
| type | string | Yes | e.g., `incorrect_stop`, `missing_bus` |
| description | string | Yes | Issue details |
| status | string | Yes | Enum: `open`, `in_progress`, `resolved` |
| createdAt | timestamp | Yes | |

**Document ID:** Auto-generated

---

## Relationships

```
users (1) ──< favorites (N)
users (1) ──< reports (N)
users (1) ──< notifications (N)

buses (1) ──< trips (N)
buses (1) ──< live_locations (1)
buses (N) ──> routes (1) via routeId
buses (N) ──> drivers (1) via driverId

routes (1) ──< route_stops (N) ──> stops (1)
routes (1) ──< trips (N)

drivers (1) ──< buses (N) via busId
drivers (1) ──< trips (N) via driverId
```

---

## Static vs Dynamic Data

| Data | Collection | Update Frequency |
|------|------------|------------------|
| Bus metadata | `buses` | Rarely |
| Route definitions | `routes` | Infrequently |
| Stop master data | `stops` | Rarely |
| Route-stop ordering | `route_stops` | Infrequently |
| Driver registry | `drivers` | Occasionally |
| Current bus location | `live_locations` | Every few seconds |
| Trip status | `trips` | Per journey |
| Notifications | `notifications` | As needed |
| User favorites | `favorites` | As needed |
| User profile | `users` | As needed |

---

## Security Model

| Role | Read | Write |
|------|------|-------|
| Passenger | Public transit data, own profile, own favorites | Own profile, own favorites, reports |
| Driver | Assigned bus/route/trip, own driver profile | Own live location, own trip status |
| Admin | All collections | All collections except `users` (limited) |

**Rules file:** `firestore.rules`

**Role assignment:** Via Firebase Auth custom claims (`request.auth.token.role`).

---

## Required Indexes

| Collection | Fields | Purpose |
|------------|--------|---------|
| `live_locations` | `busId` + `lastUpdated` desc | Latest location per bus |
| `favorites` | `userId` + `itemType` | User favorites by type |
| `notifications` | `userId` + `createdAt` desc | User notification feed |
| `buses` | `routeId` + `isActive` | Active buses on route |
| `routes` | `category` + `isActive` | Category filtering |
| `trips` | `busId` + `status` | Active trip lookup |
| `drivers` | `busId` + `status` | Driver assignment lookup |

**Indexes file:** `firestore.indexes.json`

---

## Live Location Strategy

- One document per active bus in `live_locations`
- Updated every 5-10 seconds from driver app
- TTL policy auto-deletes documents older than 24 hours
- Historical GPS data, if needed later, should go to a separate `location_history` collection with daily partitions

---

## Data Import Strategy

```
Source dataset (CSV/GTFS/JSON)
       ↓
Validation
  - Required fields present
  - Valid coordinates
  - No duplicates
       ↓
Cleaning
  - Normalize names
  - Trim whitespace
  - Standardize times
       ↓
Deduplication
  - Match existing stops by name + coordinates
  - Match existing routes by routeNumber
       ↓
Transformation
  - Map to Firestore schema
  - Generate route_stops junction docs
       ↓
Firebase Import
  - Batch write: stops → routes → route_stops → buses
  - Composite indexes
       ↓
Verification
  - Count documents
  - Spot-check ordering
  - Validate references
```

**Do not import existing local data automatically.** Review and clean first.

---

## Flutter Service Layer

```
UI
↓
Provider / Controller
↓
Repository
↓
FirestoreService
↓
Cloud Firestore
```

**Repositories created:**
- `bus_repository.dart`
- `route_repository.dart`
- `stop_repository.dart`
- `trip_repository.dart`
- `driver_repository.dart`
- `location_repository.dart`
- `favorite_repository.dart`
- `notification_repository.dart`
- `report_repository.dart`
- `user_repository.dart`

**Existing local data is preserved** in `BusDataService` as fallback.

---

## Current Firebase Status

### Already Configured
- **Firebase Project:** `visakhapatnam-bus-tracking` (Android)
- **Android:** `android/app/google-services.json` present and valid
- **Dependencies:** `firebase_core`, `cloud_firestore`, `firebase_auth` in `pubspec.yaml`
- **Initialization:** `Firebase.initializeApp()` called in `lib/main.dart` before app startup
- **Local Fallback:** `BusDataService` preserves existing local bus/route/stop data. The app works even if Firestore is empty.

### Not Yet Configured
- **iOS:** `GoogleService-Info.plist` not yet added
- **Firestore Rules:** Created locally in `firestore.rules` but not yet deployed to Firebase Console
- **Firestore Indexes:** Created locally in `firestore.indexes.json` but not yet deployed to Firebase Console
- **Auth Custom Claims:** `passenger`, `driver`, `admin`, `operator` roles not yet created in Firebase Console
- **Verified Data Import:** No real Vizag transportation data has been imported yet

---

## Implementation Status

### Completed Now
- Firestore database architecture design
- Security rules (`firestore.rules`)
- Composite index definitions (`firestore.indexes.json`)
- Dart model updates with Firestore serialization/deserialization
- Repository/service layer foundation (10 repositories)
- Database architecture documentation (`DATABASE_ARCHITECTURE.md`)
- Android build verification

### Intentionally NOT Implemented Yet
- **Real Vizag bus/route/stop data import** — no verified APSRTC dataset has been loaded
- **GPS tracking system** — no driver location streaming, no ETA calculations
- **Driver accounts and driver app** — no driver authentication or trip management UI
- **Admin panel** — no administrative interface for managing transit data
- **Firebase Auth custom claims** — roles defined in rules but not yet assigned
- **iOS configuration** — `GoogleService-Info.plist` not yet added
- **Firestore rules/indexes deployment** — created locally, pending Firebase Console deployment
- **Historical location tracking** — `location_history` collection planned but not created
- **Push notifications** — notification models exist but no FCM integration
- **Offline caching configuration** — not yet explicitly configured

---

## Data Preservation Notice

**Existing local data is preserved.** The static test data in `lib/services/bus_data_service.dart` (12 buses, 12 routes, 20 stops, 5 alerts) remains intact and serves as the development fallback when Firestore is empty. No local data has been deleted or replaced.

---

## Critical Warnings

1. **DO NOT import unverified bus data.** Only import data from official APSRTC sources after verification.
2. **DO NOT enable GPS tracking without driver authentication.** The `live_locations` collection allows driver writes, but driver accounts and custom claims must be implemented first.
3. **DO NOT deploy the app to production without deploying `firestore.rules` and `firestore.indexes.json` to Firebase Console.**
4. **DO NOT assume public data is safe to expose indefinitely.** Review security rules before production launch.
5. **Real-time GPS updates have NOT been implemented yet.** The `live_locations` document structure supports it, but no driver app or streaming logic exists.

---

## Next Steps

1. Review and approve this architecture.
2. Deploy `firestore.rules` and `firestore.indexes.json` to Firebase Console.
3. Add iOS `GoogleService-Info.plist` if iOS support is needed.
4. Create Firebase Auth custom claims for `passenger`, `driver`, `admin`, `operator` roles.
5. Obtain and verify official Vizag APSRTC transit data.
6. Build a one-time verified data importer for Vizag APSRTC data.
7. Wire repositories into existing providers with real-time listeners.
8. Implement driver authentication and GPS streaming.
9. Build admin panel for transit data management.
10. Test with a small verified dataset before full production import.
