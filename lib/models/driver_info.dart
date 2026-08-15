class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String busId;
  final String status;

  DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.busId,
    required this.status,
  });

  factory DriverInfo.fromMap(String id, Map<String, dynamic> map) {
    return DriverInfo(
      id: id,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      licenseNumber: map['licenseNumber'] as String? ?? '',
      busId: map['busId'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'busId': busId,
      'status': status,
    };
  }
}
