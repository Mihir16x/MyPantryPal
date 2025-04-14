import 'package:flutter/material.dart';

import '../models/pantry_item.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';

class ViewPantryScreen extends StatefulWidget {
  const ViewPantryScreen({super.key});

  @override
  State<ViewPantryScreen> createState() => _ViewPantryScreenState();
}

class _ViewPantryScreenState extends State<ViewPantryScreen> {
  final _dbHelper = DatabaseHelper();
  List<PantryItem> _pantryItems = [];
  bool _isLoading = true;
  PantryItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }

  Future<void> _loadPantryItems() async {
    setState(() {
      _isLoading = true;
    });

    final items = await _dbHelper.getPantryItems();

    if (mounted) {
      setState(() {
        _pantryItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(PantryItem item, int change) async {
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      // Delete item if quantity becomes zero or negative
      await _dbHelper.deletePantryItem(item.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} removed from pantry')));
      }
    } else {
      // Update quantity
      final updatedItem = PantryItem(id: item.id, name: item.name, quantity: newQuantity, nutritionalInfo: item.nutritionalInfo);

      await _dbHelper.updatePantryItem(updatedItem);
    }

    // Refresh the list
    await _loadPantryItems();
  }

  void _showNutritionalInfo(PantryItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pantryItems.isEmpty
              ? const Center(
                child: Text('Your pantry is empty.\nAdd some items to get started!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pantryItems.length,
                      itemBuilder: (context, index) {
                        final item = _pantryItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Quantity: ${item.quantity}'),
                            onTap: () => _showNutritionalInfo(item),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateQuantity(item, -1)),
                                IconButton(icon: const Icon(Icons.add), onPressed: () => _updateQuantity(item, 1)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_selectedItem != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedItem!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedItem = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Nutritional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (_selectedItem?.nutritionalInfo != null) ..._buildNutritionalInfo(_selectedItem!.nutritionalInfo!),
                        ],
                      ),
                    ),
                ],
              ),
      floatingActionButton: FloatingActionButton(onPressed: _loadPantryItems, tooltip: 'Refresh', child: const Icon(Icons.refresh)),
    );
  }

  List<Widget> _buildNutritionalInfo(Map<String, dynamic> nutritionalInfo) {
    return [
      _buildNutrientRow('Calories', '${nutritionalInfo['calories'] ?? 'N/A'} kcal'),
      _buildNutrientRow('Protein', '${nutritionalInfo['protein'] ?? 'N/A'} g'),
      _buildNutrientRow('Fat', '${nutritionalInfo['fat'] ?? 'N/A'} g'),
      _buildNutrientRow('Carbohydrates', '${nutritionalInfo['carbs'] ?? 'N/A'} g'),
      _buildNutrientRow('Fiber', '${nutritionalInfo['fiber'] ?? 'N/A'} g'),
      _buildNutrientRow('Vitamins', nutritionalInfo['vitamins'] is List 
          ? (nutritionalInfo['vitamins'] as List<dynamic>).join(', ')
          : nutritionalInfo['vitamins']?.toString() ?? 'N/A'),
      _buildNutrientRow('Minerals', nutritionalInfo['minerals'] is List
          ? (nutritionalInfo['minerals'] as List<dynamic>).join(', ')
          : nutritionalInfo['minerals']?.toString() ?? 'N/A'),
    ];
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value)],
      ),
    );
  }
}
