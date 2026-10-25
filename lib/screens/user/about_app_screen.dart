import 'package:flutter/material.dart';

import '../../theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuestra misión')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sageGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(Icons.eco_outlined, color: forestGreen, size: 52),
                SizedBox(height: 12),
                Text(
                  'Conocimiento natural, al alcance de todos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: forestGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.favorite_outline,
            title: 'Misión',
            description:
                'Acercar información clara y organizada sobre plantas '
                'medicinales y sus preparaciones, para facilitar su consulta '
                'con responsabilidad.',
          ),
          _InfoCard(
            icon: Icons.visibility_outlined,
            title: 'Visión',
            description:
                'Ser una guía digital accesible que promueva el aprendizaje '
                'y la valoración responsable del conocimiento tradicional '
                'sobre las plantas.',
          ),
          _InfoCard(
            icon: Icons.track_changes_outlined,
            title: 'Objetivo de la aplicación',
            description:
                'Organizar recetas por categorías, explicar sus ingredientes '
                'y pasos, y permitir guardar favoritas y descargar recetas '
                'para consultarlas después.',
          ),
          const SizedBox(height: 8),
          const Text(
            'El contenido es únicamente educativo. No diagnostica ni '
            'sustituye la orientación de un profesional de salud.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF59675E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: forestGreen),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: forestGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}
