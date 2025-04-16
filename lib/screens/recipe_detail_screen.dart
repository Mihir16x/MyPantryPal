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
          content: Row(
            children: [
              Icon(
                _recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _recipe.isFavorite
                    ? '${_recipe.name} added to favorites'
                    : '${_recipe.name} removed from favorites',
              ),
            ],
          ),
          backgroundColor: _recipe.isFavorite 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  _recipe.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_outlined,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _recipe.name,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _recipe.isFavorite 
                              ? Icons.favorite_rounded 
                              : Icons.favorite_border_rounded,
                          color: _recipe.isFavorite 
                              ? theme.colorScheme.error 
                              : theme.colorScheme.onBackground.withOpacity(0.5),
                          size: 28,
                        ),
                        onPressed: _isUpdating ? null : _toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Nutritional Information', theme),
                  const SizedBox(height: 16),
                  if (_recipe.nutritionalInfo != null)
                    ..._buildNutritionalInfo(_recipe.nutritionalInfo!, theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Ingredients', theme),
                  const SizedBox(height: 16),
                  ..._recipe.ingredients.map((ingredient) => _buildListItem(ingredient, theme)),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Instructions', theme),
                  const SizedBox(height: 16),
                  ..._buildNumberedInstructions(_recipe.instructions, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            _getSectionIcon(title),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Nutritional Information':
        return Icons.monitor_heart_outlined;
      case 'Ingredients':
        return Icons.egg_outlined;
      case 'Instructions':
        return Icons.menu_book_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildListItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fiber_manual_record,
              size: 12,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNumberedInstructions(List<String> instructions, ThemeData theme) {
    return List.generate(
      instructions.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                instructions[index],
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNutritionalInfo(Map<String, dynamic> nutritionalInfo, ThemeData theme) {
    return [
      _buildNutrientRow('Calories', '${nutritionalInfo['calories']} kcal', theme),
      _buildNutrientRow('Protein', '${nutritionalInfo['protein']} g', theme),
      _buildNutrientRow('Fat', '${nutritionalInfo['fat']} g', theme),
      _buildNutrientRow('Carbohydrates', '${nutritionalInfo['carbs']} g', theme),
      _buildNutrientRow('Fiber', '${nutritionalInfo['fiber']} g', theme),
      _buildNutrientRow(
        'Vitamins',
        (nutritionalInfo['vitamins'] as List<dynamic>).join(', '),
        theme,
      ),
      _buildNutrientRow(
        'Minerals',
        (nutritionalInfo['minerals'] as List<dynamic>).join(', '),
        theme,
      ),
    ];
  }

  Widget _buildNutrientRow(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
