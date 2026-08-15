import '../models/live_location.dart';
import '../services/firestore_service.dart';

class LocationRepository {
  final FirestoreService _service;

  LocationRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<LiveLocation?> watchLiveLocation(String busId) {
    return _service.liveLocationsRef
        .where('busId', isEqualTo: busId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return LiveLocation.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    });
  }

  Future<LiveLocation?> fetchLiveLocation(String busId) async {
    final snapshot = await _service.liveLocationsRef
        .where('busId', isEqualTo: busId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return LiveLocation.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<void> updateLiveLocation(LiveLocation location) async {
    final docId = location.id;
    await _service.liveLocationsRef.doc(docId).set(location.toMap());
  }
}
