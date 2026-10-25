import 'package:flutter/material.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 56, color: Color(0xFF245B45)),
                const SizedBox(height: 16),
                Text(
                  'Configuración requerida',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'La aplicación no puede continuar con la configuración actual. '
                  'Verifica Firebase, las reglas de acceso y el perfil de tu cuenta. '
                  'Consulta README.md para obtener instrucciones.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SelectableText(error, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
