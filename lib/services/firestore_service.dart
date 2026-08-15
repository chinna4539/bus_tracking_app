import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bus_info.dart';
import '../models/bus_route.dart';
import '../models/bus_stop.dart';
import '../models/driver_info.dart';
import '../models/live_location.dart';
import '../models/notification_info.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get busesRef =>
      _firestore.collection('buses');
  CollectionReference<Map<String, dynamic>> get routesRef =>
      _firestore.collection('routes');
  CollectionReference<Map<String, dynamic>> get busStopsRef =>
      _firestore.collection('bus_stops');
  CollectionReference<Map<String, dynamic>> get driversRef =>
      _firestore.collection('drivers');
  CollectionReference<Map<String, dynamic>> get liveLocationsRef =>
      _firestore.collection('live_locations');
  CollectionReference<Map<String, dynamic>> get notificationsRef =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get favoritesRef =>
      _firestore.collection('favorites');

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await usersRef.doc(uid).set(data);
  }

  Future<List<BusInfo>> fetchBuses() async {
    final snapshot = await busesRef.get();
    return snapshot.docs.map((doc) => BusInfo.fromMap(doc.data())).toList();
  }

  Future<List<BusRoute>> fetchRoutes() async {
    final snapshot = await routesRef.get();
    return snapshot.docs.map((doc) => BusRoute.fromMap(doc.data())).toList();
  }

  Future<List<BusStop>> fetchStops() async {
    final snapshot = await busStopsRef.get();
    return snapshot.docs
        .map((doc) => BusStop(name: doc.data()['name'] as String? ?? ''))
        .toList();
  }

  Future<List<DriverInfo>> fetchDrivers() async {
    final snapshot = await driversRef.get();
    return snapshot.docs
        .map((doc) => DriverInfo.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<LiveLocation>> fetchLiveLocations() async {
    final snapshot = await liveLocationsRef.get();
    return snapshot.docs
        .map((doc) => LiveLocation.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<LiveLocation?> fetchLiveLocationForBus(String busId) async {
    final snapshot = await liveLocationsRef
        .where('busId', isEqualTo: busId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return LiveLocation.fromMap(doc.id, doc.data());
  }

  Future<List<NotificationInfo>> fetchNotifications() async {
    final snapshot = await notificationsRef.get();
    return snapshot.docs
        .map((doc) => NotificationInfo.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> setFavorite(
    String userId,
    String itemType,
    String itemId,
  ) async {
    await favoritesRef.doc('$userId-$itemType-$itemId').set({
      'userId': userId,
      'itemType': itemType,
      'itemId': itemId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(
    String userId,
    String itemType,
    String itemId,
  ) async {
    await favoritesRef.doc('$userId-$itemType-$itemId').delete();
  }

  Future<List<String>> fetchUserFavorites(String userId) async {
    final snapshot = await favoritesRef
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['itemId'] as String? ?? '')
        .where((itemId) => itemId.isNotEmpty)
        .toList();
  }
}
