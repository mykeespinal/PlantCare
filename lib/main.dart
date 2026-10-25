import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    startupError = error;
  }
  runApp(PlantasApp(startupError: startupError));
}

class PlantasApp extends StatelessWidget {
  const PlantasApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantas Medicinales',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: startupError == null
          ? const _AuthenticationGate()
          : SetupScreen(error: startupError.toString()),
    );
  }
}

class _AuthenticationGate extends StatefulWidget {
  const _AuthenticationGate();

  @override
  State<_AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<_AuthenticationGate> {
  String? _signingOutUid;
  Object? _signOutError;

  void _signOutInactiveUser(String uid) {
    if (_signingOutUid == uid) return;
    _signingOutUid = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (FirebaseAuth.instance.currentUser?.uid == uid) {
          await FirebaseAuth.instance.signOut();
        }
      } catch (error) {
        if (mounted) setState(() => _signOutError = error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        final user = authSnapshot.data;
        if (user == null) {
          _signingOutUid = null;
          _signOutError = null;
          return const LoginScreen();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          key: ValueKey(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return SetupScreen(error: profileSnapshot.error.toString());
            }
            if (!profileSnapshot.hasData) return const _LoadingScreen();
            final profile = profileSnapshot.data;
            if (profile == null || !profile.exists) {
              return const SetupScreen(
                error: 'Tu cuenta no tiene un perfil de usuario asociado.',
              );
            }
            final data = profile.data()!;
            if (data['status'] != 'active') {
              _signOutInactiveUser(user.uid);
              if (_signOutError != null) {
                return SetupScreen(error: _signOutError.toString());
              }
              return const LoginScreen(
                message:
                    'Esta cuenta está inactiva. Contacta a administración.',
              );
            }
            if (data['role'] == 'admin') return const AdminDashboardScreen();
            if (data['role'] == 'user') return const UserDashboardScreen();
            return const SetupScreen(
              error: 'El rol de la cuenta no es válido.',
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
