import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/catalog_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/async_value_view.dart';

class CategoriesAdminScreen extends StatelessWidget {
  const CategoriesAdminScreen({super.key});

  Future<void> _addCategory(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final description = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Escribe un nombre.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await CatalogService.instance.addCategory(name.text, description.text);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Categoría creada.')));
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
        }
      }
    }
    name.dispose();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlantCategory>>(
      stream: CatalogService.instance.watchCategories(),
      builder: (context, snapshot) => AsyncValueView<List<PlantCategory>>(
        snapshot: snapshot,
        builder: (categories) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _addCategory(context),
                icon: const Icon(Icons.add),
                label: const Text('Crear categoría'),
              ),
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Todavía no se han creado categorías.'),
              ),
            ...categories.map(
              (category) => Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(category.name),
                  subtitle: category.description.isEmpty
                      ? null
                      : Text(category.description),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
