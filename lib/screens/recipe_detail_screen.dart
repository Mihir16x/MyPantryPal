import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _dbHelper = DatabaseHelper();
  late Recipe _recipe;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isUpdating = true;
    });

    // Toggle favorite status
    final updatedRecipe = Recipe(
      id: _recipe.id,
      name: _recipe.name,
      imageUrl: _recipe.imageUrl,
      ingredients: _recipe.ingredients,
      instructions: _recipe.instructions,
      nutritionalInfo: _recipe.nutritionalInfo,
      isFavorite: !_recipe.isFavorite,
    );

    // Update in database
    await _dbHelper.updateRecipe(updatedRecipe);

    if (mounted) {
      setState(() {
        _recipe = updatedRecipe;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _recipe.isFavorite
                ? '${_recipe.name} added to favorites'
                : '${_recipe.name} removed from favorites',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recipe.imageUrl != null)
              Image.network(
                _recipe.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 80),
                    ),
                  );
                },
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.restaurant, size: 80),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _recipe.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _recipe.isFavorite ? Icons.star : Icons.star_border,
                          color: _recipe.isFavorite ? Colors.amber : Colors.grey,
                          size: 30,
                        ),
                        onPressed: _isUpdating ? null : _toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nutritional Information'),
                  const SizedBox(height: 8),
                  if (_recipe.nutritionalInfo != null)
                    ..._buildNutritionalInfo(_recipe.nutritionalInfo!),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ingredients'),
                  const SizedBox(height: 8),
                  ..._recipe.ingredients.map((ingredient) => _buildListItem(ingredient)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Instructions'),
                  const SizedBox(height: 8),
                  ..._buildNumberedInstructions(_recipe.instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNumberedInstructions(List<String> instructions) {
    return List.generate(
      instructions.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                instructions[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNutritionalInfo(Map<String, dynamic> nutritionalInfo) {
    return [
      _buildNutrientRow('Calories', '${nutritionalInfo['calories']} kcal'),
      _buildNutrientRow('Protein', '${nutritionalInfo['protein']} g'),
      _buildNutrientRow('Fat', '${nutritionalInfo['fat']} g'),
      _buildNutrientRow('Carbohydrates', '${nutritionalInfo['carbs']} g'),
      _buildNutrientRow('Fiber', '${nutritionalInfo['fiber']} g'),
      _buildNutrientRow(
        'Vitamins',
        (nutritionalInfo['vitamins'] as List<dynamic>).join(', '),
      ),
      _buildNutrientRow(
        'Minerals',
        (nutritionalInfo['minerals'] as List<dynamic>).join(', '),
      ),
    ];
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
