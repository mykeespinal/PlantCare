import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  FavoriteService._();

  static final instance = FavoriteService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favorites(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  Stream<Set<String>> watchFavoriteIds(String uid) => _favorites(
    uid,
  ).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());

  Stream<bool> watchFavorite(String uid, String recipeId) => _favorites(
    uid,
  ).doc(recipeId).snapshots().map((snapshot) => snapshot.exists);

  Future<void> setFavorite({
    required String uid,
    required String recipeId,
    required bool favorite,
  }) async {
    final reference = _favorites(uid).doc(recipeId);
    if (favorite) {
      await reference.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await reference.delete();
    }
  }
}
