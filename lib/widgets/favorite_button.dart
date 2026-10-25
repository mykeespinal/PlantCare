import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/favorite_service.dart';
import '../utils/error_messages.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: FavoriteService.instance.watchFavorite(user.uid, recipeId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return IconButton(
            tooltip: 'No se pudo cargar el favorito: ${snapshot.error}',
            onPressed: null,
            icon: const Icon(Icons.error_outline),
          );
        }
        if (!snapshot.hasData) {
          return const IconButton(
            onPressed: null,
            icon: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final isFavorite = snapshot.data!;
        return IconButton(
          tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          onPressed: () async {
            try {
              await FavoriteService.instance.setFavorite(
                uid: user.uid,
                recipeId: recipeId,
                favorite: !isFavorite,
              );
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
              }
            }
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        );
      },
    );
  }
}
