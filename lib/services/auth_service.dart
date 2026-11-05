import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    UserCredential credential;
    String? googlePhotoUrl;

    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      credential = await _auth.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      googlePhotoUrl = googleUser.photoUrl;
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google no proporcionó una credencial válida.');
      }
      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }

    final user = credential.user;
    if (user == null) {
      throw StateError('Google no devolvió una cuenta autenticada.');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('La cuenta de Google no proporcionó un correo.');
    }

    final profileRef = _db.collection('users').doc(user.uid);
    final profile = await profileRef.get();
    if (profile.exists) {
      final profileData = profile.data();
      if (profileData?['status'] != 'active') {
        await _auth.signOut();
        if (!kIsWeb) await GoogleSignIn.instance.signOut();
        throw StateError(
          'Esta cuenta está inactiva. Contacta a administración.',
        );
      }

      final currentName = (profileData?['nombre'] as String? ?? '').trim();
      final currentLastName =
          (profileData?['apellidos'] as String? ?? '').trim();
      final photoUrl = googlePhotoUrl ?? user.photoURL;
      final updates = <String, dynamic>{
        'email': email,
        'photoURL': photoUrl,
        'authProvider': 'google.com',
      };
      if (currentName.isEmpty || currentLastName.isEmpty) {
        final displayName = user.displayName?.trim();
        if (displayName != null && displayName.isNotEmpty) {
          final nameParts = displayName.split(RegExp(r'\s+'));
          if (currentName.isEmpty) updates['nombre'] = nameParts.first;
          if (currentLastName.isEmpty) {
            updates['apellidos'] = nameParts.skip(1).join(' ');
          }
        }
      }
      await profileRef.set(updates, SetOptions(merge: true));
      return;
    }

    final ownerAdminUid = await _defaultAdminUid();
    final displayName = user.displayName?.trim();
    final name = displayName == null || displayName.isEmpty
        ? email.split('@').first
        : displayName;
    final nameParts = name.split(RegExp(r'\s+'));
    await profileRef.set({
      'uid': user.uid,
      'nombre': nameParts.first,
      'apellidos': nameParts.skip(1).join(' '),
      'email': email,
      'photoURL': googlePhotoUrl ?? user.photoURL,
      'authProvider': 'google.com',
      'role': 'user',
      'status': 'active',
      'ownerAdminUid': ownerAdminUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      final ownerAdminUid = await _defaultAdminUid();
      await _db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'email': email.trim(),
        'role': 'user',
        'status': 'active',
        'ownerAdminUid': ownerAdminUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await credential.user!.delete();
      rethrow;
    }
  }

  Future<void> createAccount({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String role,
  }) async {
    final ownerAdminUid = _auth.currentUser?.uid;
    if (ownerAdminUid == null) {
      throw StateError('Debes iniciar sesión para crear una cuenta.');
    }
    final app = await Firebase.initializeApp(
      name: 'account-creator-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    final secondaryAuth = FirebaseAuth.instanceFor(app: app);
    User? createdUser;
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = credential.user;
      await _db.collection('users').doc(createdUser!.uid).set({
        'uid': createdUser.uid,
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'email': email.trim(),
        'role': role,
        'status': 'active',
        'ownerAdminUid': ownerAdminUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (createdUser != null) await createdUser.delete();
      rethrow;
    } finally {
      await secondaryAuth.signOut();
      await app.delete();
    }
  }

  Future<void> updateProfile({
    required String uid,
    required String nombre,
    required String apellidos,
  }) => _db.collection('users').doc(uid).update({
    'nombre': nombre.trim(),
    'apellidos': apellidos.trim(),
  });

  Future<String> _defaultAdminUid() async {
    final settings = await _db.collection('settings').doc('admin').get();
    final ownerAdminUid = settings.data()?['ownerAdminUid'];
    if (ownerAdminUid is! String || ownerAdminUid.isEmpty) {
      throw StateError(
        'No se ha configurado el administrador principal del proyecto.',
      );
    }
    return ownerAdminUid;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) await GoogleSignIn.instance.signOut();
  }
}
