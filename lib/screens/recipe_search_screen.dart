import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final _searchController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    // Check if we have recipes in the database
    List<Recipe> recipes = await _dbHelper.getRecipes();

    // If no recipes, add some sample recipes
    if (recipes.isEmpty) {
      await _addSampleRecipes();
      recipes = await _dbHelper.getRecipes();
    }

    if (mounted) {
      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = List.from(_allRecipes);
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleRecipes() async {
    final sampleRecipes = [
      Recipe(
        name: 'Spaghetti Carbonara',
        imageUrl:
            'https://www.allrecipes.com/thmb/Vg2cRidr2zcYhWGvPD8M18xM_WY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/11973-spaghetti-carbonara-ii-DDMFS-4x3-6edea51e421e4457ac0c3269f3be5157.jpg',
        ingredients: ['Spaghetti', 'Eggs', 'Bacon', 'Parmesan cheese', 'Black pepper', 'Salt'],
        instructions: [
          'Cook spaghetti according to package instructions.',
          'Fry bacon until crispy.',
          'Beat eggs with grated cheese and pepper.',
          'Drain pasta and immediately add to the bacon.',
          'Remove from heat and add egg mixture, stirring quickly.',
          'Serve with extra cheese and pepper.',
        ],
        nutritionalInfo: {
          'calories': 450,
          'protein': 20,
          'fat': 18,
          'carbs': 52,
          'fiber': 2,
          'vitamins': ['Vitamin A', 'Vitamin B12'],
          'minerals': ['Calcium', 'Iron'],
        },
      ),
      Recipe(
        name: 'Chicken Stir Fry',
        imageUrl:
            'https://www.allrecipes.com/thmb/9wiMmExDMkHsRJ1YQEwkCbQk4bM=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/223382_chicken-stir-fry_Rita-1x1-1-b6b835cceb234e66be2b6a52e69b9a5a.jpg',
        ingredients: ['Chicken breast', 'Bell peppers', 'Broccoli', 'Carrots', 'Soy sauce', 'Garlic', 'Ginger', 'Rice'],
        instructions: [
          'Cut chicken into small pieces.',
          'Chop all vegetables.',
          'Heat oil in a wok or large pan.',
          'Cook chicken until no longer pink.',
          'Add vegetables and stir-fry until tender-crisp.',
          'Add garlic, ginger, and soy sauce.',
          'Serve over cooked rice.',
        ],
        nutritionalInfo: {
          'calories': 350,
          'protein': 30,
          'fat': 10,
          'carbs': 35,
          'fiber': 5,
          'vitamins': ['Vitamin A', 'Vitamin C', 'Vitamin K'],
          'minerals': ['Iron', 'Potassium'],
        },
      ),
      Recipe(
        name: 'Vegetable Soup',
        imageUrl:
            'https://www.allrecipes.com/thmb/vI4v8E_uQbYPTJyvMRnpK4SQgXE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/13338-homemade-vegetable-soup-DDMFS-4x3-7a9263011f1e4fdb8bc9309d83e7bdf7.jpg',
        ingredients: ['Carrots', 'Celery', 'Onion', 'Potatoes', 'Tomatoes', 'Vegetable broth', 'Herbs', 'Salt', 'Pepper'],
        instructions: [
          'Chop all vegetables.',
          'Heat oil in a large pot.',
          'Sauté onions, carrots, and celery.',
          'Add potatoes and tomatoes.',
          'Pour in vegetable broth and bring to a boil.',
          'Reduce heat and simmer until vegetables are tender.',
          'Season with herbs, salt, and pepper.',
        ],
        nutritionalInfo: {
          'calories': 120,
          'protein': 3,
          'fat': 2,
          'carbs': 25,
          'fiber': 6,
          'vitamins': ['Vitamin A', 'Vitamin C', 'Vitamin K'],
          'minerals': ['Potassium', 'Magnesium'],
        },
      ),
      Recipe(
        name: 'Banana Pancakes',
        imageUrl:
            'https://www.allrecipes.com/thmb/8QzNWDvGhdupDFqz0EYAoVlJZXE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20334-banana-pancakes-mfs-74-d0b2e81f2c4f44a1a1b9975026b37a81.jpg',
        ingredients: ['Flour', 'Baking powder', 'Sugar', 'Salt', 'Milk', 'Egg', 'Butter', 'Banana'],
        instructions: [
          'Mix flour, baking powder, sugar, and salt in a bowl.',
          'In another bowl, mash the banana and mix with milk, egg, and melted butter.',
          'Combine wet and dry ingredients.',
          'Heat a lightly oiled griddle or frying pan over medium heat.',
          'Pour batter onto the griddle, about 1/4 cup for each pancake.',
          'Cook until bubbles form and edges are dry, then flip and cook until browned.',
        ],
        nutritionalInfo: {
          'calories': 250,
          'protein': 6,
          'fat': 9,
          'carbs': 38,
          'fiber': 2,
          'vitamins': ['Vitamin B6', 'Vitamin C'],
          'minerals': ['Potassium', 'Magnesium'],
        },
      ),
      Recipe(
        name: 'Greek Salad',
        imageUrl:
            'https://www.allrecipes.com/thmb/akF9cX5vaiybdJJIxGwRBV9dOl4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/1169606-b6c0c630a5d3435dbc7a8c6c1a0e0d1f.jpg',
        ingredients: ['Cucumber', 'Tomatoes', 'Red onion', 'Feta cheese', 'Olives', 'Olive oil', 'Lemon juice', 'Oregano'],
        instructions: [
          'Chop cucumber, tomatoes, and red onion.',
          'Combine in a bowl with olives.',
          'Crumble feta cheese over the top.',
          'Mix olive oil, lemon juice, oregano, salt, and pepper for dressing.',
          'Pour dressing over salad and toss gently.',
        ],
        nutritionalInfo: {
          'calories': 180,
          'protein': 5,
          'fat': 15,
          'carbs': 8,
          'fiber': 2,
          'vitamins': ['Vitamin A', 'Vitamin C', 'Vitamin K'],
          'minerals': ['Calcium', 'Iron'],
        },
      ),
      Recipe(
        name: 'Beef Tacos',
        imageUrl:
            'https://www.allrecipes.com/thmb/kYnG_u3xR8K5-Hg5zwT-llQHbkI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/70935-taco-seasoning-i-DDMFS-4x3-28bce2ae2c484d76ae6b5374e0rebeca.jpg',
        ingredients: ['Ground beef', 'Taco seasoning', 'Taco shells', 'Lettuce', 'Tomato', 'Cheese', 'Sour cream', 'Salsa'],
        instructions: [
          'Brown ground beef in a pan.',
          'Drain excess fat and add taco seasoning with water.',
          'Simmer until thickened.',
          'Warm taco shells according to package instructions.',
          'Fill shells with beef mixture.',
          'Top with lettuce, tomato, cheese, sour cream, and salsa.',
        ],
        nutritionalInfo: {
          'calories': 320,
          'protein': 18,
          'fat': 22,
          'carbs': 15,
          'fiber': 3,
          'vitamins': ['Vitamin A', 'Vitamin C'],
          'minerals': ['Calcium', 'Iron'],
        },
      ),
      Recipe(
        name: 'Apple Pie',
        imageUrl:
            'https://www.allrecipes.com/thmb/X8k8CYGvbTBCRgbKALpEcTjXN2U=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/12682-apple-pie-by-grandma-ople-DDMFS-4x3-b761a2a7bea14d1cb5caf783b643878b.jpg',
        ingredients: ['Pie crust', 'Apples', 'Sugar', 'Flour', 'Cinnamon', 'Nutmeg', 'Lemon juice', 'Butter'],
        instructions: [
          'Preheat oven to 425°F (220°C).',
          'Peel, core, and slice apples.',
          'Mix apples with sugar, flour, cinnamon, nutmeg, and lemon juice.',
          'Place bottom crust in pie dish and fill with apple mixture.',
          'Dot with butter and cover with top crust.',
          'Seal edges and cut slits in top crust for steam to escape.',
          'Bake for 45-50 minutes until crust is golden and filling is bubbly.',
        ],
        nutritionalInfo: {
          'calories': 300,
          'protein': 2,
          'fat': 14,
          'carbs': 45,
          'fiber': 3,
          'vitamins': ['Vitamin A', 'Vitamin C'],
          'minerals': ['Iron', 'Potassium'],
        },
      ),
      Recipe(
        name: 'Mushroom Risotto',
        imageUrl:
            'https://www.allrecipes.com/thmb/xKCrHXXh3L-pVOXiJl8dmkRXFbY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/85389-gourmet-mushroom-risotto-DDMFS-4x3-a8a80a3b35524b07b6e0c300d799a089.jpg',
        ingredients: ['Arborio rice', 'Mushrooms', 'Onion', 'Garlic', 'White wine', 'Vegetable broth', 'Parmesan cheese', 'Butter', 'Olive oil'],
        instructions: [
          'Sauté mushrooms in butter until tender, then set aside.',
          'In the same pan, sauté onion and garlic in olive oil.',
          'Add rice and stir to coat with oil.',
          'Add wine and cook until absorbed.',
          'Gradually add hot broth, stirring constantly and allowing each addition to be absorbed before adding more.',
          'When rice is creamy and tender, stir in mushrooms and Parmesan cheese.',
          'Season with salt and pepper.',
        ],
        nutritionalInfo: {
          'calories': 380,
          'protein': 10,
          'fat': 12,
          'carbs': 52,
          'fiber': 2,
          'vitamins': ['Vitamin D', 'Vitamin B'],
          'minerals': ['Selenium', 'Potassium'],
        },
      ),
      Recipe(
        name: 'Chocolate Chip Cookies',
        imageUrl:
            'https://www.allrecipes.com/thmb/oVYdY5QZJaGJwBULiDRXPUkYrko=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/10813-best-chocolate-chip-cookies-mfs-step-7-148-5c8d2a0c46e0fb0001a1c38c.jpg',
        ingredients: ['Butter', 'White sugar', 'Brown sugar', 'Eggs', 'Vanilla extract', 'Flour', 'Baking soda', 'Salt', 'Chocolate chips'],
        instructions: [
          'Preheat oven to 350°F (175°C).',
          'Cream together butter and sugars until smooth.',
          'Beat in eggs one at a time, then stir in vanilla.',
          'Combine flour, baking soda, and salt; gradually add to the creamed mixture.',
          'Fold in chocolate chips.',
          'Drop by rounded tablespoons onto ungreased cookie sheets.',
          'Bake for 10-12 minutes until edges are nicely browned.',
        ],
        nutritionalInfo: {
          'calories': 150,
          'protein': 2,
          'fat': 7,
          'carbs': 20,
          'fiber': 1,
          'vitamins': ['Vitamin A', 'Vitamin E'],
          'minerals': ['Iron', 'Calcium'],
        },
      ),
      Recipe(
        name: 'Vegetable Curry',
        imageUrl:
            'https://www.allrecipes.com/thmb/3l79N93Nwzp9q0S_mUZfAzLOtQU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/87148-coconut-curry-tofu-DDMFS-4x3-e7ac9c1d09864b1d9d1d1047a2b17eef.jpg',
        ingredients: ['Potatoes', 'Carrots', 'Peas', 'Cauliflower', 'Onion', 'Garlic', 'Curry powder', 'Coconut milk', 'Vegetable broth', 'Rice'],
        instructions: [
          'Chop all vegetables into bite-sized pieces.',
          'Sauté onion and garlic in oil until soft.',
          'Add curry powder and cook for 1 minute.',
          'Add vegetables and stir to coat with spices.',
          'Pour in coconut milk and vegetable broth.',
          'Simmer until vegetables are tender.',
          'Serve over cooked rice.',
        ],
        nutritionalInfo: {
          'calories': 320,
          'protein': 8,
          'fat': 18,
          'carbs': 35,
          'fiber': 7,
          'vitamins': ['Vitamin A', 'Vitamin C', 'Vitamin K'],
          'minerals': ['Iron', 'Potassium', 'Magnesium'],
        },
      ),
    ];

    for (final recipe in sampleRecipes) {
      await _dbHelper.insertRecipe(recipe);
    }
  }

  void _filterRecipes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRecipes = List.from(_allRecipes);
      });
      return;
    }

    setState(() {
      _filteredRecipes =
          _allRecipes
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                    recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(query.toLowerCase())),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Search'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search Recipes', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: _filterRecipes,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecipes.isEmpty
                    ? const Center(
                      child: Text('No recipes found.\nTry a different search term.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _filteredRecipes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
                              ).then((_) => _loadRecipes());
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipe.imageUrl != null)
                                  Image.network(
                                    recipe.imageUrl!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.restaurant, size: 50)),
                                      );
                                    },
                                  )
                                else
                                  Container(height: 180, color: Colors.grey[300], child: const Center(child: Icon(Icons.restaurant, size: 50))),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(recipe.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                          Icon(
                                            recipe.isFavorite ? Icons.star : Icons.star_border,
                                            color: recipe.isFavorite ? Colors.amber : Colors.grey,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('${recipe.ingredients.length} ingredients', style: TextStyle(color: Colors.grey[600])),
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
    );
  }
}
