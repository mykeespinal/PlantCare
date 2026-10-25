import 'package:flutter/material.dart';

import '../models/recipe.dart';
import 'favorite_button.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    required this.recipe,
    required this.categoryName,
    required this.onTap,
    super.key,
  });

  final PlantRecipe recipe;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.4,
                  child: RecipeImage(recipe: recipe),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      shape: BoxShape.circle,
                    ),
                    child: FavoriteButton(recipeId: recipe.id),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF55705E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
