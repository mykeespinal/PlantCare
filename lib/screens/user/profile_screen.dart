import 'package:cloud_firestore/cloud_firestore.dart';
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
        final email = data['email'] as String? ?? '';
        final role = data['role'] as String? ?? 'user';
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Datos de la cuenta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ProfileInfo(label: 'Nombre', value: nombre),
            _ProfileInfo(label: 'Apellidos', value: apellidos),
            _ProfileInfo(label: 'Correo electrónico', value: email),
            _ProfileInfo(
              label: 'Tipo de cuenta',
              value: role == 'admin' ? 'Administrador' : 'Usuario',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _editProfile(context, data),
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
  const _ProfileInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      title: Text(label),
      subtitle: Text(value.isEmpty ? 'No especificado' : value),
      leading: const Icon(Icons.account_circle_outlined),
    ),
  );
}
