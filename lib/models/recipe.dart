import 'dart:convert';

class Recipe {
  final int? id;
  final String name;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, dynamic>? nutritionalInfo;
  bool isFavorite;

  Recipe({
    this.id,
    required this.name,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.nutritionalInfo,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ingredients': ingredients.join('|'),
      'instructions': instructions.join('|'),
      'nutritionalInfo': nutritionalInfo != null ? jsonEncode(nutritionalInfo) : null,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      ingredients: map['ingredients'].split('|'),
      instructions: map['instructions'].split('|'),
      nutritionalInfo: map['nutritionalInfo'] != null 
          ? jsonDecode(map['nutritionalInfo']) as Map<String, dynamic>
          : null,
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
