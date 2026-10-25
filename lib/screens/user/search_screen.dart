import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/recipe.dart';
import '../../services/catalog_service.dart';
import '../../theme.dart';
import '../../utils/recipe_search.dart';
import '../../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Buscar receta, planta o categoría',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        Expanded(
          child: _query.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 52,
                          color: leafGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Escribe para buscar',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: forestGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Los resultados aparecerán aquí cuando busques una receta, planta o categoría.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _buildResults(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return StreamBuilder<List<PlantCategory>>(
      stream: CatalogService.instance.watchCategories(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudieron cargar las categorías: ${categorySnapshot.error}',
              ),
            ),
          );
        }
        if (!categorySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categoryNames = {
          for (final category in categorySnapshot.data!)
            category.id: category.name,
        };
        return StreamBuilder<List<PlantRecipe>>(
          stream: CatalogService.instance.watchPublishedRecipes(),
          builder: (context, recipeSnapshot) {
            if (recipeSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar las recetas: ${recipeSnapshot.error}',
                  ),
                ),
              );
            }
            if (!recipeSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final recipes = searchPublishedRecipes(
              recipeSnapshot.data!,
              categoryNames: categoryNames,
              query: _query,
            );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Resultados',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: forestGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        '${recipes.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: recipes.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No encontramos recetas. Prueba otra búsqueda.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.76,
                              ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
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
  }
}
