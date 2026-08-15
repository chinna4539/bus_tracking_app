import '../models/bus_route.dart';
import '../services/firestore_service.dart';

class RouteRepository {
  final FirestoreService _service;

  RouteRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<BusRoute>> watchRoutes() {
    return _service.routesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BusRoute.fromFirestore(doc.id, doc.data())).toList();
    });
  }

  Future<List<BusRoute>> fetchRoutes() async {
    final snapshot = await _service.routesRef.get();
    return snapshot.docs.map((doc) => BusRoute.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<BusRoute?> fetchRouteById(String routeId) async {
    final doc = await _service.routesRef.doc(routeId).get();
    if (!doc.exists) return null;
    return BusRoute.fromFirestore(doc.id, doc.data()!);
  }

  Future<List<BusRoute>> fetchRoutesByCategory(String category) async {
    final snapshot = await _service.routesRef
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => BusRoute.fromFirestore(doc.id, doc.data())).toList();
  }
}
