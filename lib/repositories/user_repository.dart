import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _service;

  UserRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _service.usersRef.doc(uid).set({
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final doc = await _service.usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _service.usersRef.doc(uid).update({
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
