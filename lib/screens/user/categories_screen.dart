import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/catalog_service.dart';
import '../../theme.dart';
import 'category_recipes_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: StreamBuilder<List<PlantCategory>>(
        stream: CatalogService.instance.watchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudieron cargar las categorías: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no hay categorías disponibles. Vuelve pronto.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Explora por categoría',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: forestGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Elige una sección para ver sus recetas publicadas.'),
              const SizedBox(height: 16),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CategoryRecipesScreen(category: category),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: sageGreen,
                                foregroundColor: forestGreen,
                                child: Icon(Icons.local_florist_outlined),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: forestGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (category.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(category.description),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 17,
                                color: forestGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
