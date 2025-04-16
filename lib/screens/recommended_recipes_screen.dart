import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';
import 'recipe_detail_screen.dart';

class RecommendedRecipesScreen extends StatefulWidget {
  const RecommendedRecipesScreen({super.key});

  @override
  State<RecommendedRecipesScreen> createState() => _RecommendedRecipesScreenState();
}

class _RecommendedRecipesScreenState extends State<RecommendedRecipesScreen> {
  final _dbHelper = DatabaseHelper();
  List<PantryItem> _pantryItems = [];
  List<Recipe> _recommendedRecipes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPantryItemsAndGetRecommendations();
  }

  Future<void> _loadPantryItemsAndGetRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load pantry items
      final items = await _dbHelper.getPantryItems();
      
      if (mounted) {
        setState(() {
          _pantryItems = items;
        });
      }

      if (_pantryItems.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Your pantry is empty. Add some ingredients to get recipe recommendations.';
          });
        }
        return;
      }

      // Get ingredient names for recommendations
      final ingredients = _pantryItems.map((item) => item.name).toList();
      
      // Get recommendations from Gemini
      final recommendations = await _getRecipeRecommendations(ingredients);
      
      if (mounted) {
        setState(() {
          _recommendedRecipes = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error getting recommendations: $e';
        });
      }
    }
  }

  Future<List<Recipe>> _getRecipeRecommendations(List<String> ingredients) async {
    try {
      // Initialize Gemini with the API key
      final generativeModel = GenerativeModel(
        model: 'gemini-2.5-pro-exp-03-25',
        apiKey: 'AIzaSyCLeYLQ2cNq9HL3uiCiXrqNFsgB4EI3daw',
      );

      // Create prompt for Gemini
      final prompt = '''
I have the following ingredients in my pantry:
${ingredients.join(', ')}

Please suggest 3 recipes I can make with these ingredients. For each recipe, provide:
1. Recipe name
2. List of ingredients (include quantities)
3. Step-by-step instructions
4. Nutritional information (calories, protein, fat, carbs, fiber, vitamins, minerals)

Format the response as JSON with this structure:
[
  {
    "name": "Recipe Name",
    "ingredients": ["Ingredient 1", "Ingredient 2", ...],
    "instructions": ["Step 1", "Step 2", ...],
    "nutritionalInfo": {
      "calories": 000,
      "protein": 00,
      "fat": 00,
      "carbs": 00,
      "fiber": 0,
      "vitamins": ["Vitamin A", "Vitamin C", ...],
      "minerals": ["Iron", "Calcium", ...]
    }
  },
  ...
]
''';

      // Generate content with Gemini
      final content = [Content.text(prompt)];
      final response = await generativeModel.generateContent(content);
      
      // Parse the response
      final responseText = response.text;
      if (responseText == null) {
        throw Exception('Empty response from Gemini');
      }

      // Extract JSON from response (in case there's any text before or after the JSON)
      final jsonStart = responseText.indexOf('[');
      final jsonEnd = responseText.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0 || jsonStart >= jsonEnd) {
        throw Exception('Invalid JSON response format');
      }
      
      final jsonStr = responseText.substring(jsonStart, jsonEnd);
      
      // Parse JSON and create Recipe objects
      final List<dynamic> recipesJson = json.decode(jsonStr);
      final List<Recipe> recipes = [];
      
      for (final recipeJson in recipesJson) {
        final recipe = Recipe(
          name: recipeJson['name'],
          ingredients: List<String>.from(recipeJson['ingredients']),
          instructions: List<String>.from(recipeJson['instructions']),
          nutritionalInfo: recipeJson['nutritionalInfo'],
        );
        recipes.add(recipe);
      }
      
      return recipes;
    } catch (e) {
      // If there's an error with Gemini, return some fallback recipes
      return _getFallbackRecipes(ingredients);
    }
  }

  List<Recipe> _getFallbackRecipes(List<String> ingredients) {
    // Create some fallback recipes based on common ingredients
    final fallbackRecipes = <Recipe>[];
    
    if (ingredients.any((item) => ['Pasta', 'Tomato', 'Garlic'].contains(item))) {
      fallbackRecipes.add(
        Recipe(
          name: 'Simple Pasta',
          ingredients: ['Pasta', 'Tomato', 'Garlic', 'Olive oil', 'Salt', 'Pepper'],
          instructions: [
            'Cook pasta according to package instructions.',
            'Dice tomatoes and mince garlic.',
            'Heat olive oil in a pan and sauté garlic until fragrant.',
            'Add tomatoes and cook for 5 minutes.',
            'Season with salt and pepper.',
            'Toss with cooked pasta and serve.'
          ],
          nutritionalInfo: {
            'calories': 350,
            'protein': 10,
            'fat': 8,
            'carbs': 60,
            'fiber': 4,
            'vitamins': ['Vitamin C', 'Vitamin A'],
            'minerals': ['Iron', 'Potassium']
          },
        ),
      );
    }
    
    if (ingredients.any((item) => ['Rice', 'Vegetables', 'Onion'].contains(item))) {
      fallbackRecipes.add(
        Recipe(
          name: 'Vegetable Rice',
          ingredients: ['Rice', 'Mixed vegetables', 'Onion', 'Garlic', 'Vegetable broth', 'Olive oil'],
          instructions: [
            'Dice onion and mince garlic.',
            'Heat olive oil in a pan and sauté onion and garlic.',
            'Add rice and stir to coat with oil.',
            'Add vegetables and vegetable broth.',
            'Bring to a boil, then reduce heat and simmer until rice is cooked.',
            'Season with salt and pepper to taste.'
          ],
          nutritionalInfo: {
            'calories': 300,
            'protein': 6,
            'fat': 5,
            'carbs': 55,
            'fiber': 3,
            'vitamins': ['Vitamin A', 'Vitamin C', 'Vitamin K'],
            'minerals': ['Iron', 'Magnesium']
          },
        ),
      );
    }
    
    if (ingredients.any((item) => ['Eggs', 'Cheese', 'Milk'].contains(item))) {
      fallbackRecipes.add(
        Recipe(
          name: 'Simple Omelette',
          ingredients: ['Eggs', 'Cheese', 'Milk', 'Salt', 'Pepper', 'Butter'],
          instructions: [
            'Beat eggs with a splash of milk, salt, and pepper.',
            'Melt butter in a non-stick pan over medium heat.',
            'Pour in egg mixture and cook until edges start to set.',
            'Sprinkle cheese over half the omelette.',
            'Fold omelette in half and cook until cheese melts.',
            'Serve immediately.'
          ],
          nutritionalInfo: {
            'calories': 250,
            'protein': 15,
            'fat': 18,
            'carbs': 2,
            'fiber': 0,
            'vitamins': ['Vitamin A', 'Vitamin D', 'Vitamin B12'],
            'minerals': ['Calcium', 'Iron', 'Selenium']
          },
        ),
      );
    }
    
    // If no matching recipes, provide a generic one
    if (fallbackRecipes.isEmpty) {
      fallbackRecipes.add(
        Recipe(
          name: 'Pantry Salad',
          ingredients: [...ingredients, 'Olive oil', 'Lemon juice', 'Salt', 'Pepper'],
          instructions: [
            'Prepare all ingredients as needed (wash, chop, etc.).',
            'Combine all ingredients in a large bowl.',
            'Drizzle with olive oil and lemon juice.',
            'Season with salt and pepper to taste.',
            'Toss well and serve.'
          ],
          nutritionalInfo: {
            'calories': 200,
            'protein': 5,
            'fat': 10,
            'carbs': 20,
            'fiber': 5,
            'vitamins': ['Various'],
            'minerals': ['Various']
          },
        ),
      );
    }
    
    return fallbackRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Recipes'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPantryItemsAndGetRecommendations,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Based on your pantry items:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _pantryItems.map((item) {
                              return Chip(
                                label: Text(item.name),
                                backgroundColor: Colors.green.shade100,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _recommendedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recommendedRecipes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    color: Colors.green.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.restaurant,
                                            size: 50,
                                            color: Colors.green.shade800,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'AI Recommended',
                                            style: TextStyle(
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ingredients: ${recipe.ingredients.take(3).join(", ")}${recipe.ingredients.length > 3 ? "..." : ""}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPantryItemsAndGetRecommendations,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
