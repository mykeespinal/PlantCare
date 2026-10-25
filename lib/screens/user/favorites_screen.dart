import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/recipe.dart';
import '../../services/catalog_service.dart';
import '../../services/favorite_service.dart';
import '../../theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: FavoriteService.instance.watchFavoriteIds(uid),
      builder: (context, favoriteSnapshot) {
        if (favoriteSnapshot.hasError) {
          return Center(
            child: Text(
              'No se pudieron cargar tus favoritos: ${favoriteSnapshot.error}',
            ),
          );
        }
        if (!favoriteSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<PlantCategory>>(
          stream: CatalogService.instance.watchCategories(),
          builder: (context, categorySnapshot) {
            if (categorySnapshot.hasError) {
              return Center(
                child: Text(
                  'No se pudieron cargar las categorías: '
                  '${categorySnapshot.error}',
                ),
              );
            }
            if (!categorySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<List<PlantRecipe>>(
              stream: CatalogService.instance.watchPublishedRecipes(),
              builder: (context, recipeSnapshot) {
                return AsyncValueView<List<PlantRecipe>>(
                  snapshot: recipeSnapshot,
                  builder: (recipes) {
                    final favoriteIds = favoriteSnapshot.data!;
                    final favorites = recipes
                        .where((recipe) => favoriteIds.contains(recipe.id))
                        .toList();
                    final categoryNames = {
                      for (final category in categorySnapshot.data!)
                        category.id: category.name,
                    };
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: sageGreen,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.favorite_outline,
                                  color: forestGreen,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'En esta sección encontrarás las recetas que guardaste en favoritos.',
                                    style: TextStyle(
                                      color: forestGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: favorites.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Todavía no has guardado recetas favoritas.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    20,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 0.76,
                                      ),
                                  itemCount: favorites.length,
                                  itemBuilder: (context, index) {
                                    final recipe = favorites[index];
                                    final categoryName =
                                        categoryNames[recipe.categoryId] ??
                                        recipe.plantName;
                                    return RecipeCard(
                                      recipe: recipe,
                                      categoryName: categoryName,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => RecipeDetailScreen(
                                            recipe: recipe,
                                            categoryName: categoryName,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
