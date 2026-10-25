import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlantRecipe {
  const PlantRecipe({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.ingredients,
    required this.steps,
    required this.result,
    this.imageUrl = '',
    this.imageBytes,
    this.plantName = '',
    this.published = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String categoryId;
  final String imageUrl;
  final Uint8List? imageBytes;
  final List<String> ingredients;
  final List<String> steps;
  final String result;
  final String plantName;
  final bool published;
  final DateTime? createdAt;

  factory PlantRecipe.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    final storedImage = data['imageBytes'];
    return PlantRecipe(
      id: id,
      title: data['title'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      imageBytes: storedImage is Blob
          ? storedImage.bytes
          : storedImage is Uint8List
          ? storedImage
          : null,
      ingredients: List<String>.from(data['ingredients'] as List? ?? const []),
      steps: List<String>.from(data['steps'] as List? ?? const []),
      result: data['result'] as String? ?? '',
      plantName: data['plantName'] as String? ?? '',
      published: data['published'] == true,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
