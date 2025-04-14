import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search_ingredients_screen.dart';
import 'home_screen.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  void _scanBarcode(BuildContext context) {
    // In a real app, this would use a barcode scanning package
    // For this demo, we'll simulate a barcode scan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Scanner'),
        content: const Text('Simulating barcode scan...\nBarcode: 123456789'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item added to pantry: Pasta'),
                ),
              );
            },
            child: const Text('Add Item'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
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
              'How would you like to add an item?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildOptionButton(
              context,
              'Scan Barcode',
              Icons.qr_code_scanner,
              Colors.blue,
              'Do you have a barcode to scan?',
              () => _scanBarcode(context),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              'Search Ingredients',
              Icons.search,
              Colors.green,
              'Search for ingredients manually',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchIngredientsScreen(),
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
