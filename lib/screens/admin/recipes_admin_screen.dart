import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category.dart';
import '../../models/recipe.dart';
import '../../services/catalog_service.dart';
import '../../utils/error_messages.dart';
import '../../utils/recipe_image_compressor.dart';

class RecipesAdminScreen extends StatefulWidget {
  const RecipesAdminScreen({super.key});

  @override
  State<RecipesAdminScreen> createState() => _RecipesAdminScreenState();
}

class _RecipesAdminScreenState extends State<RecipesAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _plantName = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  final _result = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  String? _categoryId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _plantName.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _result.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image != null) {
        final compressedBytes = compressRecipeImage(await image.readAsBytes());
        setState(() {
          _imageBytes = compressedBytes;
          _imageName = image.name;
        });
      }
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final bytes = _imageBytes;
    if (bytes == null || _imageName == null) {
      _showError(StateError('Selecciona una imagen para la receta.'));
      return;
    }
    setState(() => _saving = true);
    try {
      await CatalogService.instance.addRecipe(
        title: _title.text,
        plantName: _plantName.text,
        categoryId: _categoryId!,
        imageBytes: bytes,
        ingredients: _splitLines(_ingredients.text),
        steps: _splitLines(_steps.text),
        result: _result.text,
      );
      _title.clear();
      _plantName.clear();
      _ingredients.clear();
      _steps.clear();
      _result.clear();
      setState(() {
        _imageBytes = null;
        _imageName = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Receta publicada.')));
      }
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _splitLines(String input) => input
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
    }
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Este campo es obligatorio.' : null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'No se pudieron cargar las categorías: ${snapshot.error}',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data!.docs
            .map((doc) => PlantCategory.fromMap(doc.id, doc.data()))
            .toList();
        if (categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Crea una categoría antes de publicar una receta.'),
            ),
          );
        }
        _categoryId ??= categories.first.id;
        if (!categories.any((category) => category.id == _categoryId)) {
          _categoryId = categories.first.id;
        }
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Nombre de receta',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plantName,
                decoration: const InputDecoration(
                  labelText: 'Planta (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_imageName ?? 'Seleccionar imagen'),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _imageBytes!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredients,
                minLines: 3,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes (uno por línea)',
                  alignLabelWithHint: true,
                ),
                validator: (value) => _splitLines(value ?? '').isEmpty
                    ? 'Agrega al menos un ingrediente.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _steps,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Pasos de preparación (uno por línea)',
                  alignLabelWithHint: true,
                ),
                validator: (value) => _splitLines(value ?? '').isEmpty
                    ? 'Agrega al menos un paso.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _result,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Resultado o beneficio esperado',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Publicar receta'),
              ),
              const SizedBox(height: 28),
              Text(
                'Recetas publicadas y borradores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _recipeManagement(),
            ],
          ),
        );
      },
    );
  }

  Widget _recipeManagement() {
    return StreamBuilder<List<PlantRecipe>>(
      stream: CatalogService.instance.watchAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('No se pudieron cargar las recetas: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Text('Todavía no hay recetas.');
        }
        return Column(
          children: snapshot.data!
              .map(
                (recipe) => Card(
                  child: ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(
                      '${recipe.plantName.isEmpty ? 'Planta no indicada' : recipe.plantName}'
                      ' · ${recipe.published ? 'Publicada' : 'Borrador'}',
                    ),
                    trailing: TextButton(
                      onPressed: () => _setPublished(recipe),
                      child: Text(recipe.published ? 'Retirar' : 'Publicar'),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _setPublished(PlantRecipe recipe) async {
    try {
      await CatalogService.instance.setRecipePublished(
        recipe.id,
        !recipe.published,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              recipe.published
                  ? 'La receta se retiró de publicación.'
                  : 'La receta se publicó.',
            ),
          ),
        );
      }
    } catch (error) {
      _showError(error);
    }
  }
}
