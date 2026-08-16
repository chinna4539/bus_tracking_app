import 'dart:convert';
import 'dart:io';

const _gtfsDir = 'tools/data/gtfs';
const _outputDir = 'tools/data';

void main() {
  print('Reading GTFS files...');
  final routes = _readCsv('$_gtfsDir/routes.txt');
  final trips = _readCsv('$_gtfsDir/trips.txt');
  final stopTimes = _readCsv('$_gtfsDir/stop_times.txt');
  final stops = _readCsv('$_gtfsDir/stops.txt');
  final shapes = _readCsv('$_gtfsDir/shapes.txt');

  print('Routes: ${routes.length - 1}');
  print('Trips: ${trips.length - 1}');
  print('Stop times: ${stopTimes.length - 1}');
  print('Stops: ${stops.length - 1}');
  print('Shapes: ${shapes.length - 1}');

  // Build lookup maps
  final stopMap = <String, Map<String, String>>{};
  for (var i = 1; i < stops.length; i++) {
    final row = stops[i];
    stopMap[row['stop_id']!] = {
      'stop_id': row['stop_id']!,
      'stop_name': row['stop_name']!,
      'stop_lat': row['stop_lat']!,
      'stop_lon': row['stop_lon']!,
    };
  }

  final tripToRoute = <String, String>{};
  final tripToDirection = <String, String>{};
  final tripToShape = <String, String>{};
  for (var i = 1; i < trips.length; i++) {
    final row = trips[i];
    tripToRoute[row['trip_id']!] = row['route_id']!;
    tripToDirection[row['trip_id']!] = row['direction_id'] ?? '0';
    tripToShape[row['trip_id']!] = row['shape_id'] ?? '';
  }

  // Identify Vizag area stops by coordinates
  // Vizag city proper: lat 17.65-17.85, lon 83.10-83.40
  final vizagCityStopIds = <String>{};
  // Vizag region: lat 17.40-18.00, lon 82.50-83.60
  final vizagRegionStopIds = <String>{};

  for (final stop in stopMap.values) {
    final lat = double.tryParse(stop['stop_lat']!) ?? 0.0;
    final lon = double.tryParse(stop['stop_lon']!) ?? 0.0;

    if (lat >= 17.65 && lat <= 17.85 && lon >= 83.10 && lon <= 83.40) {
      vizagCityStopIds.add(stop['stop_id']!);
    } else if (lat >= 17.40 && lat <= 18.00 && lon >= 82.50 && lon <= 83.60) {
      vizagRegionStopIds.add(stop['stop_id']!);
    }
  }

  print('Vizag city stops: ${vizagCityStopIds.length}');
  print('Vizag region stops: ${vizagRegionStopIds.length}');

  // Group stop times by trip
  final tripStops = <String, List<Map<String, String>>>{};
  for (var i = 1; i < stopTimes.length; i++) {
    final row = stopTimes[i];
    final tripId = row['trip_id']!;
    final stopId = row['stop_id']!;
    final sequence = int.parse(row['stop_sequence'] ?? '0');
    final stop = stopMap[stopId];
    if (stop == null) continue;
    tripStops.putIfAbsent(tripId, () => []).add({
      'stop_id': stopId,
      'stop_name': stop['stop_name']!,
      'stop_lat': stop['stop_lat']!,
      'stop_lon': stop['stop_lon']!,
      'stop_sequence': sequence.toString(),
    });
  }

  // Sort stops by sequence
  for (final stops in tripStops.values) {
    stops.sort((a, b) => int.parse(a['stop_sequence']!).compareTo(int.parse(b['stop_sequence']!)));
  }

  // Group trips by route
  final routeTrips = <String, List<String>>{};
  for (final entry in tripToRoute.entries) {
    routeTrips.putIfAbsent(entry.value, () => []).add(entry.key);
  }

  // Identify Vizag-relevant routes and classify them
  final allVizagRouteIds = <String>{};
  final cityRouteIds = <String>{};
  final regionRouteIds = <String>{};
  final intercityRouteIds = <String>{};
  final routeClassifications = <String, String>{};

  for (final entry in routeTrips.entries) {
    final routeId = entry.key;
    final tripsForRoute = entry.value;
    final hasCityStop = <String>{};
    final hasRegionStop = <String>{};
    final hasOutsideStop = <String>{};
    final allStopNames = <String>{};

    for (final tripId in tripsForRoute) {
      final stopList = tripStops[tripId];
      if (stopList == null) continue;
      for (final stop in stopList) {
        final stopId = stop['stop_id']!;
        allStopNames.add(stop['stop_name']!.toUpperCase());
        if (vizagCityStopIds.contains(stopId)) {
          hasCityStop.add(stopId);
        } else if (vizagRegionStopIds.contains(stopId)) {
          hasRegionStop.add(stopId);
        } else {
          hasOutsideStop.add(stopId);
        }
      }
    }

    if (hasCityStop.isEmpty && hasRegionStop.isEmpty) continue;

    allVizagRouteIds.add(routeId);

    // Classify based on route extent
    final routeRow = routes.firstWhere((row) => row['route_id'] == routeId, orElse: () => {});
    final routeName = (routeRow['route_long_name'] ?? routeRow['route_short_name'] ?? routeId).toUpperCase();

    if (hasOutsideStop.isEmpty) {
      cityRouteIds.add(routeId);
      routeClassifications[routeId] = 'city';
    } else if (hasCityStop.isNotEmpty) {
      // Has both Vizag city stops and outside stops
      intercityRouteIds.add(routeId);
      routeClassifications[routeId] = 'intercity';
    } else {
      // Only region stops, no city stops
      regionRouteIds.add(routeId);
      routeClassifications[routeId] = 'region';
    }
  }

  print('Vizag routes: ${allVizagRouteIds.length}');
  print('  City/local: ${cityRouteIds.length}');
  print('  Region: ${regionRouteIds.length}');
  print('  Intercity: ${intercityRouteIds.length}');

  // Build stops set
  final usedStopIds = <String>{};
  for (final routeId in allVizagRouteIds) {
    final tripsForRoute = routeTrips[routeId] ?? [];
    for (final tripId in tripsForRoute) {
      final stopList = tripStops[tripId];
      if (stopList == null) continue;
      for (final stop in stopList) {
        usedStopIds.add(stop['stop_id']!);
      }
    }
  }

  print('Unique stops used: ${usedStopIds.length}');

  // Count stops with coordinates
  int stopsWithCoords = 0;
  int stopsWithoutCoords = 0;
  for (final stopId in usedStopIds) {
    final stop = stopMap[stopId];
    if (stop == null) continue;
    final lat = double.tryParse(stop['stop_lat']!);
    final lon = double.tryParse(stop['stop_lon']!);
    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      stopsWithCoords++;
    } else {
      stopsWithoutCoords++;
    }
  }
  print('Stops with coordinates: $stopsWithCoords');
  print('Stops missing coordinates: $stopsWithoutCoords');

  // Count directions/trips
  final totalDirections = <String>{};
  final totalShapes = <String>{};
  for (final routeId in allVizagRouteIds) {
    final tripsForRoute = routeTrips[routeId] ?? [];
    for (final tripId in tripsForRoute) {
      totalDirections.add('${routeId}_${tripToDirection[tripId]}');
      final shape = tripToShape[tripId];
      if (shape != null && shape.isNotEmpty) {
        totalShapes.add(shape);
      }
    }
  }
  print('Route directions/trips: ${totalDirections.length}');
  print('Route shapes: ${totalShapes.length}');

  // Generate routes.json
  final routesOut = <Map<String, dynamic>>[];
  for (final routeId in allVizagRouteIds.toList()..sort()) {
    final routeRow = routes.firstWhere((row) => row['route_id'] == routeId, orElse: () => {});
    if (routeRow.isEmpty) continue;

    final routeNumber = routeRow['route_short_name'] ?? routeId;
    final routeName = routeRow['route_long_name'] ?? routeNumber;

    // Get first trip's stops for each direction
    final tripsForRoute = routeTrips[routeId] ?? [];
    final directionStops = <String, List<Map<String, String>>>{};
    for (final tripId in tripsForRoute) {
      final stopList = tripStops[tripId];
      if (stopList == null || stopList.isEmpty) continue;
      final direction = tripToDirection[tripId] ?? '0';
      if (!directionStops.containsKey(direction)) {
        directionStops[direction] = stopList;
      }
    }

    // Use direction 0 as primary, or first available
    List<Map<String, String>> primaryStops = directionStops['0'] ?? directionStops.values.first;
    final stopNames = primaryStops.map((s) => s['stop_name']!).toList();
    final origin = stopNames.isNotEmpty ? stopNames.first : '';
    final destination = stopNames.isNotEmpty ? stopNames.last : '';

    routesOut.add({
      'id': routeNumber,
      'routeNumber': routeNumber,
      'title': '$origin → $destination',
      'startingPoint': origin,
      'destination': destination,
      'stops': stopNames,
      'distance': 'N/A',
      'duration': 'N/A',
      'totalStops': stopNames.length,
      'firstBus': 'N/A',
      'lastBus': 'N/A',
      'frequency': 'N/A',
      'description': 'APSRTC route $routeNumber (${routeClassifications[routeId] ?? 'unknown'})',
    });
  }

  // Generate stops.json
  final stopsOut = <Map<String, dynamic>>[];
  for (final stopId in usedStopIds.toList()..sort()) {
    final stop = stopMap[stopId];
    if (stop == null) continue;
    final lat = double.tryParse(stop['stop_lat']!) ?? 0.0;
    final lon = double.tryParse(stop['stop_lon']!) ?? 0.0;
    stopsOut.add({
      'id': stopId,
      'name': stop['stop_name']!,
      'latitude': lat,
      'longitude': lon,
      'zone': _guessZone(stop['stop_name']!, lat, lon),
      'isActive': true,
    });
  }

  // Generate buses.json
  final busesOut = <Map<String, dynamic>>[];
  for (final route in routesOut) {
    final routeNumber = route['routeNumber'] as String;
    busesOut.add({
      'id': routeNumber,
      'busNumber': routeNumber,
      'routeNumber': routeNumber,
      'routeId': routeNumber,
      'routeName': route['title'] as String,
      'startingPoint': route['startingPoint'] as String,
      'destination': route['destination'] as String,
      'stops': route['stops'] as List<String>,
      'currentStop': (route['stops'] as List<String>).isNotEmpty ? (route['stops'] as List<String>)[((route['stops'] as List<String>).length / 2).floor()] : '',
      'nextStop': '',
      'eta': 'N/A',
      'status': 'onTime',
      'busType': 'standard',
      'driverName': 'TBD',
      'driverId': null,
      'capacity': 52,
      'availableSeats': 30,
      'speed': 0.0,
      'lastUpdated': 'N/A',
      'distanceRemaining': 'N/A',
      'estimatedJourneyTime': 'N/A',
      'isActive': true,
      'latitude': 0.0,
      'longitude': 0.0,
    });
  }

  // Write JSON files
  _writeJson('$_outputDir/routes.json', routesOut);
  _writeJson('$_outputDir/stops.json', stopsOut);
  _writeJson('$_outputDir/buses.json', busesOut);

  // Generate DATA_GAPS.md
  final gaps = <String>[];
  gaps.add('# Data Gaps and Issues\n');
  gaps.add('## Generated from APSRTC GTFS feed\n');
  gaps.add('Source: https://github.com/Neo2308/apsrtc-gtfs/raw/refs/heads/main/gtfs/gtfs.zip\n');
  gaps.add('');
  gaps.add('## Summary\n');
  gaps.add('- Total routes generated: ${routesOut.length}');
  gaps.add('- Total stops generated: ${stopsOut.length}');
  gaps.add('- Total buses generated: ${busesOut.length}');
  gaps.add('');
  gaps.add('## Route Classification\n');
  gaps.add('- City/local routes: ${cityRouteIds.length}');
  gaps.add('- Region routes: ${regionRouteIds.length}');
  gaps.add('- Intercity routes: ${intercityRouteIds.length}');
  gaps.add('');
  gaps.add('## Stops\n');
  gaps.add('- Stops with coordinates: $stopsWithCoords');
  gaps.add('- Stops missing coordinates: $stopsWithoutCoords');
  gaps.add('');
  gaps.add('## Trips and Shapes\n');
  gaps.add('- Total directions/trips: ${totalDirections.length}');
  gaps.add('- Total unique shapes: ${totalShapes.length}');
  gaps.add('');
  gaps.add('## Missing Information\n');
  gaps.add('- Distance/duration: N/A (not in GTFS)');
  gaps.add('- First/last bus times: N/A (not in GTFS)');
  gaps.add('- Frequency: N/A (not in GTFS)');
  gaps.add('- Bus type: defaulted to "standard"');
  gaps.add('- Driver name: defaulted to "TBD"');
  gaps.add('- Live location: defaulted to 0.0, 0.0');
  gaps.add('- ETA, speed, available seats: defaulted');
  gaps.add('');
  gaps.add('## Classification Notes\n');
  gaps.add('- City/local: routes entirely within Vizag city bounds');
  gaps.add('- Region: routes connecting Vizag to nearby regions');
  gaps.add('- Intercity: routes connecting Vizag to distant cities');
  gaps.add('');
  gaps.add('## Known Issues\n');
  gaps.add('- Route 540/541 not found in GTFS feed');
  gaps.add('- Simhachalam and Kothavalasa stops not present in GTFS');
  gaps.add('- Some stop names may have duplicates in different locations');
  gaps.add('- Direction information preserved where available');
  gaps.add('- Shape data exists but not exported to JSON (app doesn\'t use shapes yet)');
  gaps.add('');
  gaps.add('## Cross-check Sources\n');
  gaps.add('- OpenStreetMap: https://wiki.openstreetmap.org/wiki/Visakhapatnam_APSRTC_Bus_Routes');
  gaps.add('- Discrepancies: route numbers may not match OSM exactly due to GTFS padding');
  gaps.add('- Note: This GTFS feed may not contain all APSRTC routes or may use different numbering');

  File('$_outputDir/DATA_GAPS.md').writeAsStringSync(gaps.join('\n'));
  print('Wrote DATA_GAPS.md');
}

String _guessZone(String stopName, double lat, double lon) {
  final upper = stopName.toUpperCase();
  if (upper.contains('MADDILAPALEM') || upper.contains('RTC COMPLEX') || upper.contains('DWARAKA') || upper.contains('AUTONAGAR')) return 'Central';
  if (upper.contains('MVP') || upper.contains('RUSHIKONDA') || upper.contains('BEACH ROAD') || upper.contains('KAILASAGIRI')) return 'North';
  if (upper.contains('HB COLONY') || upper.contains('SEETHAMMADHARA') || upper.contains('NAD') || upper.contains('BHEEMUNI')) return 'East';
  if (upper.contains('GAJUWAKA') || upper.contains('KURMANNAPALEM') || upper.contains('STEEL PLANT') || upper.contains('OLD GAJUWAKA')) return 'South';
  if (upper.contains('SIMHACHALAM') || upper.contains('KOTHAVALASA') || upper.contains('ANANDAPURAM')) return 'West';
  if (upper.contains('AIRPORT') || upper.contains('MADHURAWADA')) return 'North-West';
  if (upper.contains('PENDURTHI')) return 'North';
  if (upper.contains('NARSIPATNAM')) return 'North';
  if (upper.contains('CHODAVARAM')) return 'West';
  return 'Vizag';
}

List<Map<String, String>> _readCsv(String path) {
  final lines = File(path).readAsStringSync().trim().split('\n');
  if (lines.isEmpty) return [];
  final headers = lines[0].split(',');
  final result = <Map<String, String>>[];
  for (var i = 1; i < lines.length; i++) {
    final values = _parseCsvLine(lines[i]);
    if (values.length != headers.length) continue;
    final row = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = values[j];
    }
    result.add(row);
  }
  return result;
}

List<String> _parseCsvLine(String line) {
  final result = <String>[];
  final buffer = StringBuffer();
  bool inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(buffer.toString().trim());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  result.add(buffer.toString().trim());
  return result;
}

void _writeJson(String path, List<dynamic> data) {
  final encoder = JsonEncoder.withIndent('  ');
  final json = encoder.convert(data);
  File(path).writeAsStringSync(json);
  print('Wrote $path (${data.length} records)');
}
