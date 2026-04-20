// lib/models/bill.dart

class BillItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  BillItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'unit': unit,
        'total': total,
      };

  factory BillItem.fromMap(Map<dynamic, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      unit: map['unit'] ?? 'piece',
    );
  }
}

class Bill {
  final String id;
  final String customerName;
  final List<BillItem> items;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.customerName,
    required this.items,
    required this.createdAt,
  });

  double get grandTotal => items.fold(0, (sum, i) => sum + i.total);

  Map<String, dynamic> toMap() => {
        'customerName': customerName,
        'items': items.map((e) => e.toMap()).toList(),
        'grandTotal': grandTotal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bill.fromMap(String id, Map<dynamic, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return Bill(
      id: id,
      customerName: map['customerName'] ?? 'Customer',
      items: rawItems
          .map((e) => BillItem.fromMap(e as Map<dynamic, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
