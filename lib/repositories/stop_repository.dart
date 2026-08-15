import '../models/bus_stop.dart';
import '../services/firestore_service.dart';

class StopRepository {
  final FirestoreService _service;

  StopRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<BusStop>> watchStops() {
    return _service.busStopsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BusStop.fromFirestore(doc.id, doc.data())).toList();
    });
  }

  Future<List<BusStop>> fetchStops() async {
    final snapshot = await _service.busStopsRef.get();
    return snapshot.docs.map((doc) => BusStop.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<BusStop?> fetchStopById(String stopId) async {
    final doc = await _service.busStopsRef.doc(stopId).get();
    if (!doc.exists) return null;
    return BusStop.fromFirestore(doc.id, doc.data()!);
  }
}
