import 'package:cloud_firestore/cloud_firestore.dart';

class LiveLocation {
  final String id;
  final String busId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LiveLocation({
    required this.id,
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LiveLocation.fromMap(String id, Map<String, dynamic> map) {
    return LiveLocation(
      id: id,
      busId: map['busId'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }
}
