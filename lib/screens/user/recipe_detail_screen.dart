import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../services/recipe_pdf_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/recipe_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    required this.recipe,
    required this.categoryName,
    super.key,
  });

  final PlantRecipe recipe;
  final String categoryName;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _downloading = false;

  Future<void> _downloadRecipe() async {
    setState(() => _downloading = true);
    try {
      await RecipePdfService.download(
        recipe: widget.recipe,
        categoryName: widget.categoryName,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la receta'),
        actions: [
          IconButton(
            tooltip: 'Descargar receta en PDF',
            onPressed: _downloading ? null : _downloadRecipe,
            icon: _downloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
          FavoriteButton(recipeId: widget.recipe.id),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1.45,
            child: RecipeImage(recipe: widget.recipe),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  avatar: const Icon(Icons.spa, size: 18),
                  label: Text(widget.categoryName),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _section(context, 'Ingredientes', Icons.inventory_2_outlined),
                ...widget.recipe.ingredients.asMap().entries.map(
                  (entry) => _bullet(entry.value),
                ),
                const SizedBox(height: 22),
                _section(context, 'Preparación', Icons.menu_book_outlined),
                ...widget.recipe.steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: const Color(0xFFE6EFE4),
                          child: Text('${entry.key + 1}'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _section(context, 'Beneficio esperado', Icons.favorite_outline),
                Text(widget.recipe.result),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _downloading ? null : _downloadRecipe,
                    icon: _downloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_outlined),
                    label: Text(
                      _downloading ? 'Preparando PDF…' : 'Descargar receta en PDF',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'La información es educativa y no sustituye la valoración de un profesional de salud.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF245B45)),
        const SizedBox(width: 9),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
