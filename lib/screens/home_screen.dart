import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'view_pantry_screen.dart';
import 'recipes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry Pal'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Welcome to My Pantry Pal',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to do today?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 48),
              _buildFeatureButton(
                context,
                'Add Item',
                Icons.add_circle_outline_rounded,
                theme.colorScheme.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureButton(
                context,
                'View Pantry',
                Icons.kitchen_outlined,
                theme.colorScheme.secondary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewPantryScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureButton(
                context,
                'Find Recipe',
                Icons.restaurant_menu_outlined,
                theme.colorScheme.secondary.withBlue(200),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipesScreen()),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Organize your ingredients and discover new recipes',
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

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
