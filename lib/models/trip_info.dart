class TripInfo {
  final String tripId;
  final String busId;
  final String routeId;
  final String driverId;
  final String status;
  final String direction;
  final int? currentStopIndex;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TripInfo({
    required this.tripId,
    required this.busId,
    required this.routeId,
    required this.driverId,
    required this.status,
    required this.direction,
    this.currentStopIndex,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory TripInfo.fromMap(String id, Map<String, dynamic> data) {
    return TripInfo(
      tripId: id,
      busId: data['busId'] as String? ?? '',
      routeId: data['routeId'] as String? ?? '',
      driverId: data['driverId'] as String? ?? '',
      status: data['status'] as String? ?? 'scheduled',
      direction: data['direction'] as String? ?? 'outbound',
      currentStopIndex: data['currentStopIndex'] as int?,
      startedAt: data['startedAt'] != null ? DateTime.tryParse(data['startedAt'].toString()) : null,
      completedAt: data['completedAt'] != null ? DateTime.tryParse(data['completedAt'].toString()) : null,
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'routeId': routeId,
      'driverId': driverId,
      'status': status,
      'direction': direction,
      'currentStopIndex': currentStopIndex,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
