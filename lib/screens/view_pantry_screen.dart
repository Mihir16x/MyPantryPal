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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('${item.name} removed from pantry'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      // Update quantity
      final updatedItem = PantryItem(
        id: item.id,
        name: item.name,
        quantity: newQuantity,
        nutritionalInfo: item.nutritionalInfo,
      );
      
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pantryItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your pantry is empty',
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some items to get started!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Items'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          Text(
                            'Your Ingredients',
                            style: theme.textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${_pantryItems.length} items',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _pantryItems.length,
                        itemBuilder: (context, index) {
                          final item = _pantryItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            child: InkWell(
                              onTap: () => _showNutritionalInfo(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.restaurant_outlined,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap for nutrition info',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'x${item.quantity}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: theme.colorScheme.error,
                                          ),
                                          onPressed: () => _updateQuantity(item, -1),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: theme.colorScheme.primary,
                                          ),
                                          onPressed: () => _updateQuantity(item, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedItem != null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedItem!.name,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    setState(() {
                                      _selectedItem = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nutritional Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_selectedItem?.nutritionalInfo != null)
                              ..._buildNutritionalInfo(_selectedItem!.nutritionalInfo!),
                          ],
                        ),
                      ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPantryItems,
        tooltip: 'Refresh',
        elevation: 2,
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  List<Widget> _buildNutritionalInfo(Map<String, dynamic> nutritionalInfo) {
    final theme = Theme.of(context);
    
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
