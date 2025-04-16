import 'dart:convert';

class PantryItem {
  final int? id;
  final String name;
  int quantity;
  final Map<String, dynamic>? nutritionalInfo;

  PantryItem({
    this.id,
    required this.name,
    required this.quantity,
    this.nutritionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'nutritionalInfo': nutritionalInfo != null ? jsonEncode(nutritionalInfo) : null,
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      nutritionalInfo: map['nutritionalInfo'] != null 
          ? jsonDecode(map['nutritionalInfo']) as Map<String, dynamic>
          : null,
    );
  }
}
