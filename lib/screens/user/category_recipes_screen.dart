import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/recipe.dart';
import '../../services/catalog_service.dart';
import '../../theme.dart';
import '../../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class CategoryRecipesScreen extends StatelessWidget {
  const CategoryRecipesScreen({required this.category, super.key});

  final PlantCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: StreamBuilder<List<PlantRecipe>>(
        stream: CatalogService.instance.watchPublishedRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las recetas: ${snapshot.error}',
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipes = snapshot.data!
              .where((recipe) => recipe.categoryId == category.id)
              .toList();
          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aún no hay recetas publicadas en ${category.name}.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: sageGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.spa_outlined,
                      color: forestGreen,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${recipes.length} ${recipes.length == 1 ? 'receta publicada' : 'recetas publicadas'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: forestGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...recipes.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: RecipeCard(
                    recipe: recipe,
                    categoryName: category.name,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecipeDetailScreen(
                          recipe: recipe,
                          categoryName: category.name,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
