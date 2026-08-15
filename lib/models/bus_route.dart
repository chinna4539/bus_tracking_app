class BusRoute {
  final String routeNumber;
  final String title;
  final String startingPoint;
  final String destination;
  final List<String> stops;
  final String distance;
  final String duration;
  final int totalStops;
  final String firstBus;
  final String lastBus;
  final String frequency;
  final String description;

  const BusRoute({
    required this.routeNumber,
    required this.title,
    required this.startingPoint,
    required this.destination,
    required this.stops,
    required this.distance,
    required this.duration,
    required this.totalStops,
    required this.firstBus,
    required this.lastBus,
    required this.frequency,
    required this.description,
  });

  factory BusRoute.fromMap(Map<String, dynamic> data) {
    return BusRoute(
      routeNumber: data['routeNumber'] as String? ?? '',
      title: data['title'] as String? ?? '',
      startingPoint: data['startingPoint'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      stops: List<String>.from(data['stops'] as List<dynamic>? ?? []),
      distance: data['distance'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      totalStops: data['totalStops'] as int? ?? 0,
      firstBus: data['firstBus'] as String? ?? '',
      lastBus: data['lastBus'] as String? ?? '',
      frequency: data['frequency'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  factory BusRoute.fromFirestore(String id, Map<String, dynamic> data) {
    return BusRoute(
      routeNumber: data['routeNumber'] as String? ?? id,
      title: data['title'] as String? ?? '',
      startingPoint: data['startingPoint'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      stops: List<String>.from(data['stops'] as List<dynamic>? ?? []),
      distance: data['distance'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      totalStops: data['totalStops'] as int? ?? 0,
      firstBus: data['firstBus'] as String? ?? '',
      lastBus: data['lastBus'] as String? ?? '',
      frequency: data['frequency'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeNumber': routeNumber,
      'title': title,
      'startingPoint': startingPoint,
      'destination': destination,
      'stops': stops,
      'distance': distance,
      'duration': duration,
      'totalStops': totalStops,
      'firstBus': firstBus,
      'lastBus': lastBus,
      'frequency': frequency,
      'description': description,
    };
  }
}
