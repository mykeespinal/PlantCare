import '../models/recipe.dart';

List<PlantRecipe> searchPublishedRecipes(
  Iterable<PlantRecipe> recipes, {
  required Map<String, String> categoryNames,
  String query = '',
  String? categoryId,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  return recipes.where((recipe) {
    if (!recipe.published) return false;
    if (categoryId != null && categoryId != recipe.categoryId) return false;
    if (normalizedQuery.isEmpty) return true;

    final categoryName = categoryNames[recipe.categoryId] ?? '';
    return recipe.title.toLowerCase().contains(normalizedQuery) ||
        recipe.plantName.toLowerCase().contains(normalizedQuery) ||
        categoryName.toLowerCase().contains(normalizedQuery);
  }).toList();
}
