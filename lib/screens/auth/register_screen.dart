import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/error_messages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        nombre: _nombre.text,
        apellidos: _apellidos.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Únete a nuestra comunidad',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
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
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@') ? null : 'Correo no válido.';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Usa al menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                      ),
                      validator: (value) => value != _password.text
                          ? 'Las contraseñas no coinciden.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Crear cuenta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Este campo es obligatorio.' : null;
}
