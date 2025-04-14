import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saved_recipes_screen.dart';
import 'recipe_search_screen.dart';
import 'recommended_recipes_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Find Your Perfect Recipe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildOptionButton(
              context,
              'Saved Recipes',
              Icons.favorite,
              Colors.red,
              'View your favorite recipes',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedRecipesScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              'Recipe Search',
              Icons.search,
              Colors.blue,
              'Search from our collection of recipes',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeSearchScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              'Recommended Recipes',
              Icons.recommend,
              Colors.green,
              'Recipes based on your pantry items',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendedRecipesScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
