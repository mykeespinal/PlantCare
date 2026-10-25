import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserService {
  UserService._();

  static final instance = UserService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<List<AppUser>> watchUsers() {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      throw StateError('Debes iniciar sesión para consultar las cuentas.');
    }
    return _db
        .collection('users')
        .where('ownerAdminUid', isEqualTo: adminUid)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList();
          users.sort(
            (first, second) => first.nombre.toLowerCase().compareTo(
              second.nombre.toLowerCase(),
            ),
          );
          return users;
        });
  }

  Future<void> setActive(String uid, bool active) => _db
      .collection('users')
      .doc(uid)
      .update({'status': active ? 'active' : 'inactive'});

  Future<void> deleteUser(String uid) async {
    await _functions.httpsCallable('deleteUser').call<void>({'uid': uid});
  }
}
