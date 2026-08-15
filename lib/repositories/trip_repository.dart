import '../models/trip_info.dart';
import '../services/firestore_service.dart';

class TripRepository {
  final FirestoreService _service;

  TripRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<TripInfo>> watchTrips() {
    return _service.tripsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TripInfo.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<TripInfo>> fetchTrips() async {
    final snapshot = await _service.tripsRef.get();
    return snapshot.docs.map((doc) => TripInfo.fromMap(doc.id, doc.data())).toList();
  }

  Future<TripInfo?> fetchActiveTripForBus(String busId) async {
    final snapshot = await _service.tripsRef
        .where('busId', isEqualTo: busId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return TripInfo.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<void> createTrip(TripInfo trip) async {
    await _service.tripsRef.doc(trip.tripId).set(trip.toMap());
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _service.tripsRef.doc(tripId).update(data);
  }
}
