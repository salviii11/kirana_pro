// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String unit; // kg, piece, litre, etc.

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory Product.fromMap(String id, Map<dynamic, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      unit: map['unit'] ?? 'piece',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'price': price,
        'quantity': quantity,
        'unit': unit,
      };
}
