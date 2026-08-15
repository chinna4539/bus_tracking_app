import '../services/firestore_service.dart';

class FavoriteRepository {
  final FirestoreService _service;

  FavoriteRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Future<List<String>> fetchUserFavorites(String userId) async {
    final snapshot = await _service.favoritesRef
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => doc.data()['itemId'] as String? ?? '').where((id) => id.isNotEmpty).toList();
  }

  Future<void> addFavorite(String userId, String itemType, String itemId) async {
    final docId = '$userId-$itemType-$itemId';
    await _service.favoritesRef.doc(docId).set({
      'userId': userId,
      'itemType': itemType,
      'itemId': itemId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String itemType, String itemId) async {
    final docId = '$userId-$itemType-$itemId';
    await _service.favoritesRef.doc(docId).delete();
  }
}
