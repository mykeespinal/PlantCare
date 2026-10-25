import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/error_messages.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    required this.uid,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.role,
    super.key,
  });

  final String uid;
  final String nombre;
  final String apellidos;
  final String email;
  final String role;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellidos;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.nombre);
    _apellidos = TextEditingController(text: widget.apellidos);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        uid: widget.uid,
        nombre: _nombre.text,
        apellidos: _apellidos.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Datos actualizados.')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Actualizar mis datos')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Edita tu información personal. El correo y el tipo de cuenta no se pueden cambiar aquí.',
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nombre(s)'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidos,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: widget.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: widget.role == 'admin'
                      ? 'Administrador'
                      : 'Usuario',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cuenta',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _saving ? 'Guardando…' : 'Guardar cambios',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Este campo es obligatorio.' : null;
}
