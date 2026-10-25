import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_pdf_service.dart';
import '../../services/user_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/async_value_view.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  bool _busy = false;

  Future<void> _export(List<AppUser> users) async {
    try {
      await UserPdfService.printUsers(users);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _createUser() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final surname = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var role = 'user';
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear cuenta'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nombre(s)'),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: surname,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (value) => (value?.contains('@') ?? false)
                          ? null
                          : 'Ingresa un correo válido.',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      validator: (value) => (value?.length ?? 0) >= 6
                          ? null
                          : 'Mínimo 6 caracteres.',
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => role = value ?? 'user'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    if (result != true) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.createAccount(
        nombre: name.text,
        apellidos: surname.text,
        email: email.text,
        password: password.text,
        role: role,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('La cuenta fue creada.')));
      }
    } catch (error) {
      _showError(error);
    } finally {
      name.dispose();
      surname.dispose();
      email.dispose();
      password.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          'Se eliminará permanentemente el acceso de ${user.fullName}. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UserService.instance.deleteUser(user.uid);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: UserService.instance.watchUsers(),
      builder: (context, snapshot) => AsyncValueView<List<AppUser>>(
        snapshot: snapshot,
        builder: (users) {
          final activeCount = users
              .where((user) => user.status == 'active')
              .length;
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${users.length} usuarios · $activeCount activos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Exportar e imprimir PDF',
                        onPressed: () => _export(users),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                      ),
                      IconButton(
                        tooltip: 'Crear usuario o administrador',
                        onPressed: _busy ? null : _createUser,
                        icon: const Icon(Icons.person_add_alt_1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aún no hay usuarios.'),
                    ),
                  ...users.map((user) => _userTile(user)),
                ],
              ),
              if (_busy)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _userTile(AppUser user) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
          ),
        ),
        title: Text(user.fullName.isEmpty ? user.email : user.fullName),
        subtitle: Text(
          '${user.email}\n${user.role == 'admin' ? 'Administrador' : 'Usuario'} · '
          '${user.status == 'active' ? 'Activo' : 'Inactivo'}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          enabled: user.uid != currentUid,
          onSelected: (value) async {
            try {
              if (value == 'toggle') {
                await UserService.instance.setActive(
                  user.uid,
                  user.status != 'active',
                );
              } else if (value == 'delete') {
                await _delete(user);
              }
            } catch (error) {
              _showError(error);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(
                user.status == 'active'
                    ? 'Desactivar acceso'
                    : 'Activar acceso',
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar permanentemente'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Este campo es obligatorio.' : null;
}
