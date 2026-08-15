class BusStop {
  final String name;

  const BusStop({required this.name});

  factory BusStop.fromMap(Map<String, dynamic> data) {
    return BusStop(name: data['name'] as String? ?? '');
  }

  factory BusStop.fromFirestore(String id, Map<String, dynamic> data) {
    return BusStop(name: data['name'] as String? ?? id);
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
