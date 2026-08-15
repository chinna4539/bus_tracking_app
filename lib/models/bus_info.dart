enum BusStatus { onTime, delayed, diverted, cancelled, arrivingSoon }

enum BusType { standard, express, ac }

class BusInfo {
  final String busNumber;
  final String routeNumber;
  final String routeName;
  final String startingPoint;
  final String destination;
  final List<String> stops;
  final String currentStop;
  final String nextStop;
  final String eta;
  final BusStatus status;
  final BusType busType;
  final String driverName;
  final int capacity;
  final int availableSeats;
  final double speed;
  final String lastUpdated;
  final String distanceRemaining;
  final String estimatedJourneyTime;
  final bool isActive;
  final double latitude;
  final double longitude;

  const BusInfo({
    required this.busNumber,
    required this.routeNumber,
    required this.routeName,
    required this.startingPoint,
    required this.destination,
    required this.stops,
    required this.currentStop,
    required this.nextStop,
    required this.eta,
    required this.status,
    required this.busType,
    required this.driverName,
    required this.capacity,
    required this.availableSeats,
    required this.speed,
    required this.lastUpdated,
    required this.distanceRemaining,
    required this.estimatedJourneyTime,
    required this.isActive,
    required this.latitude,
    required this.longitude,
  });

  factory BusInfo.fromMap(Map<String, dynamic> data) {
    return BusInfo(
      busNumber: data['busNumber'] as String? ?? '',
      routeNumber: data['routeNumber'] as String? ?? '',
      routeName: data['routeName'] as String? ?? '',
      startingPoint: data['startingPoint'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      stops: List<String>.from(data['stops'] as List<dynamic>? ?? []),
      currentStop: data['currentStop'] as String? ?? '',
      nextStop: data['nextStop'] as String? ?? '',
      eta: data['eta'] as String? ?? '',
      status: BusStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => BusStatus.onTime,
      ),
      busType: BusType.values.firstWhere(
        (type) => type.name == data['busType'],
        orElse: () => BusType.standard,
      ),
      driverName: data['driverName'] as String? ?? '',
      capacity: data['capacity'] as int? ?? 0,
      availableSeats: data['availableSeats'] as int? ?? 0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: data['lastUpdated'] as String? ?? '',
      distanceRemaining: data['distanceRemaining'] as String? ?? '',
      estimatedJourneyTime: data['estimatedJourneyTime'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory BusInfo.fromFirestore(String id, Map<String, dynamic> data) {
    return BusInfo(
      busNumber: data['busNumber'] as String? ?? id,
      routeNumber: data['routeNumber'] as String? ?? data['routeId'] as String? ?? id,
      routeName: data['routeName'] as String? ?? '',
      startingPoint: data['startingPoint'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      stops: List<String>.from(data['stops'] as List<dynamic>? ?? []),
      currentStop: data['currentStop'] as String? ?? '',
      nextStop: data['nextStop'] as String? ?? '',
      eta: data['eta'] as String? ?? '',
      status: BusStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => BusStatus.onTime,
      ),
      busType: BusType.values.firstWhere(
        (type) => type.name == data['busType'],
        orElse: () => BusType.standard,
      ),
      driverName: data['driverName'] as String? ?? '',
      capacity: data['capacity'] as int? ?? 0,
      availableSeats: data['availableSeats'] as int? ?? 0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: data['lastUpdated'] as String? ?? '',
      distanceRemaining: data['distanceRemaining'] as String? ?? '',
      estimatedJourneyTime: data['estimatedJourneyTime'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'routeNumber': routeNumber,
      'routeName': routeName,
      'startingPoint': startingPoint,
      'destination': destination,
      'stops': stops,
      'currentStop': currentStop,
      'nextStop': nextStop,
      'eta': eta,
      'status': status.name,
      'busType': busType.name,
      'driverName': driverName,
      'capacity': capacity,
      'availableSeats': availableSeats,
      'speed': speed,
      'lastUpdated': lastUpdated,
      'distanceRemaining': distanceRemaining,
      'estimatedJourneyTime': estimatedJourneyTime,
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get occupancyLabel => '$availableSeats / $capacity';
  String get statusLabel {
    switch (status) {
      case BusStatus.onTime:
        return 'On time';
      case BusStatus.delayed:
        return 'Delayed';
      case BusStatus.diverted:
        return 'Diverted';
      case BusStatus.cancelled:
        return 'Cancelled';
      case BusStatus.arrivingSoon:
        return 'Arriving soon';
    }
  }

  String get typeLabel {
    switch (busType) {
      case BusType.standard:
        return 'Standard';
      case BusType.express:
        return 'Express';
      case BusType.ac:
        return 'A/C';
    }
  }
}
