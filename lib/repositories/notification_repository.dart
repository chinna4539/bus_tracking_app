import '../models/notification_info.dart';
import '../services/firestore_service.dart';

class NotificationRepository {
  final FirestoreService _service;

  NotificationRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<NotificationInfo>> watchUserNotifications(String userId) {
    return _service.notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationInfo.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<NotificationInfo>> fetchUserNotifications(String userId) async {
    final snapshot = await _service.notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationInfo.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _service.notificationsRef.doc(notificationId).update({'read': true});
  }
}
