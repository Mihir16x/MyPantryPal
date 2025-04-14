import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';

class SearchIngredientsScreen extends StatefulWidget {
  const SearchIngredientsScreen({super.key});

  @override
  State<SearchIngredientsScreen> createState() => _SearchIngredientsScreenState();
}

class _SearchIngredientsScreenState extends State<SearchIngredientsScreen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  List<String> _searchResults = [];
  List<String> _allIngredients = [
    'Apple', 'Banana', 'Beef', 'Broccoli', 'Carrot', 'Cheese', 'Chicken',
    'Eggs', 'Flour', 'Garlic', 'Milk', 'Onion', 'Pasta', 'Potato',
    'Rice', 'Salt', 'Sugar', 'Tomato', 'Tuna', 'Yogurt'
  ];
  String? _selectedIngredient;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(_allIngredients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = List.from(_allIngredients);
      });
      return;
    }

    setState(() {
      _searchResults = _allIngredients
          .where((ingredient) => 
              ingredient.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectIngredient(String ingredient) {
    setState(() {
      _selectedIngredient = ingredient;
      _quantityController.text = '1';
    });
  }

  Future<void> _addToPantry() async {
    if (_selectedIngredient == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ingredient and specify quantity')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    // Create a new pantry item
    final pantryItem = PantryItem(
      name: _selectedIngredient!,
      quantity: quantity,
      nutritionalInfo: _getNutritionalInfo(_selectedIngredient!),
    );

    // Save to database
    await _dbHelper.insertPantryItem(pantryItem);

    if (mounted) {
      setState(() {
        _isAdding = false;
        _selectedIngredient = null;
        _quantityController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pantryItem.name} added to pantry')),
      );
    }
  }

  Map<String, dynamic> _getNutritionalInfo(String ingredient) {
    // In a real app, this would fetch from a nutritional database
    // For this demo, we'll use mock data
    final Map<String, dynamic> nutritionalData = {
      'Apple': {
        'calories': 52,
        'protein': 0.3,
        'fat': 0.2,
        'carbs': 14,
        'fiber': 2.4,
        'vitamins': ['Vitamin C', 'Vitamin K'],
        'minerals': ['Potassium']
      },
      'Banana': {
        'calories': 89,
        'protein': 1.1,
        'fat': 0.3,
        'carbs': 22.8,
        'fiber': 2.6,
        'vitamins': ['Vitamin B6', 'Vitamin C'],
        'minerals': ['Potassium', 'Magnesium']
      },
      'Beef': {
        'calories': 250,
        'protein': 26,
        'fat': 17,
        'carbs': 0,
        'fiber': 0,
        'vitamins': ['Vitamin B12', 'Vitamin B6'],
        'minerals': ['Iron', 'Zinc']
      },
      'Chicken': {
        'calories': 165,
        'protein': 31,
        'fat': 3.6,
        'carbs': 0,
        'fiber': 0,
        'vitamins': ['Vitamin B6', 'Vitamin B12'],
        'minerals': ['Phosphorus', 'Selenium']
      },
      'Eggs': {
        'calories': 78,
        'protein': 6.3,
        'fat': 5.3,
        'carbs': 0.6,
        'fiber': 0,
        'vitamins': ['Vitamin B12', 'Vitamin D'],
        'minerals': ['Iron', 'Zinc']
      },
    };

    // Return nutritional info if available, otherwise return a default
    return nutritionalData[ingredient] ?? {
      'calories': 100,
      'protein': 2,
      'fat': 1,
      'carbs': 5,
      'fiber': 1,
      'vitamins': ['Various'],
      'minerals': ['Various']
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Ingredients'),
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
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            if (_selectedIngredient != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedIngredient!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isAdding ? null : _addToPantry,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                            ),
                            child: _isAdding
                                ? const CircularProgressIndicator()
                                : const Text('Add to Pantry'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final ingredient = _searchResults[index];
                  return ListTile(
                    title: Text(ingredient),
                    onTap: () => _selectIngredient(ingredient),
                    trailing: const Icon(Icons.add),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
