//lib/models/category_model.dart

class AppCategory {
  const AppCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  AppCategory copyWith({String? id, String? name, String? description}) {
    return AppCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
