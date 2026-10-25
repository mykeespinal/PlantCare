import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:plantas/models/recipe.dart';
import 'package:plantas/services/catalog_service.dart';
import 'package:plantas/utils/recipe_image_compressor.dart';

void main() {
  test('compresses the image as a bounded JPEG', () {
    final source = img.Image(width: 300, height: 200);
    img.fill(source, color: img.ColorRgb8(40, 120, 80));
    final input = img.encodePng(source);

    final compressed = compressRecipeImage(
      Uint8List.fromList(input),
      maxDimension: 100,
    );
    final decoded = img.decodeImage(compressed);

    expect(compressed.length, lessThanOrEqualTo(700 * 1024));
    expect(decoded, isNotNull);
    expect(decoded!.width, 100);
    expect(decoded.height, 67);
  });

  test('reads image bytes saved as a Firestore Blob', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final recipe = PlantRecipe.fromMap('recipe-1', {
      'title': 'Infusión',
      'categoryId': 'bebidas',
      'imageBytes': Blob(bytes),
      'ingredients': const <String>[],
      'steps': const <String>[],
      'result': '',
    });

    expect(recipe.imageBytes, orderedEquals(bytes));
  });

  test('reserves room under Firestore document size limit', () {
    expect(CatalogService.maxRecipeImageBytes, 700 * 1024);
    expect(CatalogService.maxRecipeImageBytes, lessThan(1024 * 1024));
  });
}
