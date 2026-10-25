import 'package:flutter_test/flutter_test.dart';
import 'package:plantas/models/recipe.dart';
import 'package:plantas/utils/recipe_search.dart';

PlantRecipe recipe({
  required String id,
  required String title,
  required String plantName,
  required String categoryId,
  bool published = true,
}) => PlantRecipe(
  id: id,
  title: title,
  plantName: plantName,
  categoryId: categoryId,
  imageUrl: '',
  ingredients: const [],
  steps: const [],
  result: '',
  published: published,
);

void main() {
  final recipes = [
    recipe(
      id: '1',
      title: 'Infusión calmante',
      plantName: 'Manzanilla',
      categoryId: 'infusiones',
    ),
    recipe(
      id: '2',
      title: 'Gel refrescante',
      plantName: 'Sábila',
      categoryId: 'tópicos',
    ),
    recipe(
      id: '3',
      title: 'Borrador oculto',
      plantName: 'Manzanilla',
      categoryId: 'infusiones',
      published: false,
    ),
  ];
  final categories = {'infusiones': 'Bebidas', 'tópicos': 'Cuidado tópico'};

  test(
    'matches recipe title, plant name, or category without case sensitivity',
    () {
      expect(
        searchPublishedRecipes(
          recipes,
          categoryNames: categories,
          query: 'INFUSIÓN',
        ).map((recipe) => recipe.id),
        ['1'],
      );
      expect(
        searchPublishedRecipes(
          recipes,
          categoryNames: categories,
          query: 'sábila',
        ).map((recipe) => recipe.id),
        ['2'],
      );
      expect(
        searchPublishedRecipes(
          recipes,
          categoryNames: categories,
          query: 'bebidas',
        ).map((recipe) => recipe.id),
        ['1'],
      );
    },
  );

  test('excludes unpublished recipes and applies the category filter', () {
    expect(
      searchPublishedRecipes(
        recipes,
        categoryNames: categories,
        categoryId: 'infusiones',
      ).map((recipe) => recipe.id),
      ['1'],
    );
  });
}
