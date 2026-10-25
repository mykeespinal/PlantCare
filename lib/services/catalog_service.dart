import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/recipe.dart';

class CatalogService {
  CatalogService._();

  static final instance = CatalogService._();
  static const maxRecipeImageBytes = 700 * 1024;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PlantCategory>> watchCategories() => _db
      .collection('categories')
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PlantCategory.fromMap(doc.id, doc.data()))
            .toList(),
      );

  Stream<List<PlantRecipe>> watchPublishedRecipes() => _db
      .collection('recipes')
      .where('published', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => PlantRecipe.fromMap(doc.id, doc.data()))
                .toList()
              ..sort(
                (first, second) => (second.createdAt ?? DateTime(0)).compareTo(
                  first.createdAt ?? DateTime(0),
                ),
              ),
      );

  Stream<List<PlantRecipe>> watchAllRecipes() => _db
      .collection('recipes')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PlantRecipe.fromMap(doc.id, doc.data()))
            .toList(),
      );

  Future<void> addCategory(String name, String description) async {
    await _db.collection('categories').add({
      'name': name.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addRecipe({
    required String title,
    required String plantName,
    required String categoryId,
    required Uint8List imageBytes,
    required List<String> ingredients,
    required List<String> steps,
    required String result,
  }) async {
    final recipe = _db.collection('recipes').doc();
    if (imageBytes.isEmpty) {
      throw ArgumentError('El archivo de imagen seleccionado está vacío.');
    }
    if (imageBytes.lengthInBytes > maxRecipeImageBytes) {
      throw ArgumentError(
        'La imagen comprimida supera 700 KB. Selecciona otra imagen.',
      );
    }
    await recipe.set({
      'title': title.trim(),
      'plantName': plantName.trim(),
      'categoryId': categoryId,
      'imageBytes': Blob(imageBytes),
      'ingredients': ingredients,
      'steps': steps,
      'result': result.trim(),
      'published': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRecipePublished(String recipeId, bool published) =>
      _db.collection('recipes').doc(recipeId).update({'published': published});
}
