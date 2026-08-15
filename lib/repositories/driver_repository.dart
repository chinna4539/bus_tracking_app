import '../models/driver_info.dart';
import '../services/firestore_service.dart';

class DriverRepository {
  final FirestoreService _service;

  DriverRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<DriverInfo>> watchDrivers() {
    return _service.driversRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DriverInfo.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<DriverInfo>> fetchDrivers() async {
    final snapshot = await _service.driversRef.get();
    return snapshot.docs.map((doc) => DriverInfo.fromMap(doc.id, doc.data())).toList();
  }

  Future<DriverInfo?> fetchDriverById(String driverId) async {
    final doc = await _service.driversRef.doc(driverId).get();
    if (!doc.exists) return null;
    return DriverInfo.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateDriver(String driverId, Map<String, dynamic> data) async {
    await _service.driversRef.doc(driverId).update(data);
  }
}
