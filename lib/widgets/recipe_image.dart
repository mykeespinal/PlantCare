import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({required this.recipe, this.height, super.key});

  final PlantRecipe recipe;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bytes = recipe.imageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (recipe.imageUrl.isNotEmpty) {
      return Image.network(
        recipe.imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => ColoredBox(
    color: const Color(0xFFE6EFE4),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: const Center(child: Icon(Icons.local_florist, size: 46)),
    ),
  );
}
