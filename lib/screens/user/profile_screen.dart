import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.uid, super.key});

  final String uid;

  Future<void> _editProfile(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProfileEditScreen(
          uid: uid,
          nombre: data['nombre'] as String? ?? '',
          apellidos: data['apellidos'] as String? ?? '',
          email: data['email'] as String? ?? '',
          role: data['role'] as String? ?? 'user',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('No se pudo cargar el perfil: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data();
        if (data == null) {
          return const Center(child: Text('No se encontró el perfil.'));
        }
        final nombre = data['nombre'] as String? ?? '';
        final apellidos = data['apellidos'] as String? ?? '';
        final authUser = FirebaseAuth.instance.currentUser;
        final authNameParts = (authUser?.displayName ?? '').trim().split(
          RegExp(r'\s+'),
        );
        final profileNombre = nombre.isNotEmpty
            ? nombre
            : authNameParts.firstOrNull ?? '';
        final profileApellidos = apellidos.isNotEmpty
            ? apellidos
            : authNameParts.skip(1).join(' ');
        final email = (data['email'] as String? ?? '').isNotEmpty
            ? data['email'] as String
            : authUser?.email ?? '';
        final role = data['role'] as String? ?? 'user';
        final photoURL = data['photoURL'] as String? ?? authUser?.photoURL;
        final profileData = {
          ...data,
          'nombre': profileNombre,
          'apellidos': profileApellidos,
          'email': email,
        };
        final usesGoogle =
            authUser?.providerData.any(
              (provider) => provider.providerId == 'google.com',
            ) ??
            false;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color(0xFFE6EFE4),
                    foregroundImage: photoURL == null || photoURL.isEmpty
                        ? null
                        : NetworkImage(photoURL),
                    child: const Icon(
                      Icons.person_outline,
                      size: 42,
                      color: Color(0xFF245B45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$profileNombre $profileApellidos'.trim().isEmpty
                        ? 'Mi perfil'
                        : '$profileNombre $profileApellidos'.trim(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Datos de la cuenta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ProfileInfo(
              label: 'Nombre',
              value: profileNombre,
              icon: Icons.person_outline,
            ),
            _ProfileInfo(
              label: 'Apellidos',
              value: profileApellidos,
              icon: Icons.badge_outlined,
            ),
            _ProfileInfo(
              label: 'Correo electrónico',
              value: email,
              icon: Icons.email_outlined,
            ),
            _ProfileInfo(
              label: 'Inicio de sesión',
              value: usesGoogle ? 'Google' : 'Correo y contraseña',
              icon: usesGoogle ? Icons.g_mobiledata : Icons.lock_outline,
            ),
            _ProfileInfo(
              label: 'Tipo de cuenta',
              value: role == 'admin' ? 'Administrador' : 'Usuario',
              icon: Icons.verified_user_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _editProfile(context, profileData),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Actualizar mis datos'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      title: Text(label),
      subtitle: Text(value.isEmpty ? 'No especificado' : value),
      leading: Icon(icon),
    ),
  );
}
