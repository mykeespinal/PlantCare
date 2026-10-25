class PlantCategory {
  const PlantCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory PlantCategory.fromMap(String id, Map<String, dynamic> data) =>
      PlantCategory(
        id: id,
        name: data['name'] as String? ?? '',
        description: data['description'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'name': name, 'description': description};
}
