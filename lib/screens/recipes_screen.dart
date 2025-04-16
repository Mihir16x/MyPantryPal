import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saved_recipes_screen.dart';
import 'recipe_search_screen.dart';
import 'recommended_recipes_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Find Your Perfect Recipe',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an option below to discover delicious meals',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 48),
              _buildOptionButton(
                context,
                'Saved Recipes',
                Icons.favorite_border_rounded,
                theme.colorScheme.error.withOpacity(0.9),
                'View your favorite recipes',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedRecipesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                context,
                'Recipe Search',
                Icons.search_rounded,
                theme.colorScheme.secondary,
                'Search from our collection of recipes',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipeSearchScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                context,
                'Recommended Recipes',
                Icons.recommend_outlined,
                theme.colorScheme.primary,
                'Recipes based on your pantry items',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecommendedRecipesScreen(),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Powered by Gemini 2.5 Pro for smart recipe recommendations',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
