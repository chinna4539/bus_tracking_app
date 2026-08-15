import '../models/bus_info.dart';
import '../services/firestore_service.dart';

class BusRepository {
  final FirestoreService _service;

  BusRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<BusInfo>> watchBuses() {
    return _service.busesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BusInfo.fromFirestore(doc.id, doc.data())).toList();
    });
  }

  Future<List<BusInfo>> fetchBuses() async {
    final snapshot = await _service.busesRef.get();
    return snapshot.docs.map((doc) => BusInfo.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<BusInfo?> fetchBusByNumber(String busNumber) async {
    final snapshot = await _service.busesRef
        .where('busNumber', isEqualTo: busNumber)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return BusInfo.fromFirestore(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<List<BusInfo>> fetchBusesByRoute(String routeId) async {
    final snapshot = await _service.busesRef
        .where('routeId', isEqualTo: routeId)
        .get();
    return snapshot.docs.map((doc) => BusInfo.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> updateBus(String busId, Map<String, dynamic> data) async {
    await _service.busesRef.doc(busId).update(data);
  }
}
