// lib/services/firebase_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';
import '../models/bill.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  final _db = FirebaseDatabase.instance;
  final _uuid = const Uuid();

  Stream<List<Product>> productsStream() {
    return _db.ref('products').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => Product.fromMap(e.key as String, e.value as Map))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> addProduct(Product p) =>
      _db.ref('products/${_uuid.v4()}').set(p.toMap());

  Future<void> updateProduct(Product p) =>
      _db.ref('products/${p.id}').update(p.toMap());

  Future<void> deleteProduct(String id) =>
      _db.ref('products/$id').remove();

  Future<void> decreaseStock(String id, int qty) async {
    final ref = _db.ref('products/$id/quantity');
    final snap = await ref.get();
    final current = (snap.value as int?) ?? 0;
    await ref.set((current - qty).clamp(0, 999999));
  }

  Stream<List<Bill>> billsStream() {
    return _db.ref('bills').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => Bill.fromMap(e.key as String, e.value as Map))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> saveBill(Bill bill) =>
      _db.ref('bills/${bill.id}').set(bill.toMap());

  Future<void> deleteBill(String id) => _db.ref('bills/$id').remove();

  // ── Seed Demo Data ─────────────────────────────────────────────────────────
  Future<void> seedDemoData() async {
    final snap = await _db.ref('products').get();
    if (snap.exists) return; // already seeded

    final products = [
      {'name': 'Basmati Rice', 'category': 'Grains', 'price': 85.0, 'quantity': 50, 'unit': 'kg'},
      {'name': 'Wheat Flour (Atta)', 'category': 'Grains', 'price': 42.0, 'quantity': 30, 'unit': 'kg'},
      {'name': 'Toor Dal', 'category': 'Grains', 'price': 120.0, 'quantity': 25, 'unit': 'kg'},
      {'name': 'Chana Dal', 'category': 'Grains', 'price': 95.0, 'quantity': 20, 'unit': 'kg'},
      {'name': 'Moong Dal', 'category': 'Grains', 'price': 110.0, 'quantity': 3, 'unit': 'kg'},
      {'name': 'Turmeric Powder', 'category': 'Spices', 'price': 18.0, 'quantity': 40, 'unit': 'packet'},
      {'name': 'Red Chilli Powder', 'category': 'Spices', 'price': 22.0, 'quantity': 35, 'unit': 'packet'},
      {'name': 'Cumin Seeds', 'category': 'Spices', 'price': 15.0, 'quantity': 2, 'unit': 'packet'},
      {'name': 'Coriander Powder', 'category': 'Spices', 'price': 16.0, 'quantity': 30, 'unit': 'packet'},
      {'name': 'Garam Masala', 'category': 'Spices', 'price': 45.0, 'quantity': 20, 'unit': 'packet'},
      {'name': 'Amul Butter', 'category': 'Dairy', 'price': 55.0, 'quantity': 15, 'unit': 'piece'},
      {'name': 'Amul Cheese Slice', 'category': 'Dairy', 'price': 110.0, 'quantity': 10, 'unit': 'piece'},
      {'name': 'Paneer 200g', 'category': 'Dairy', 'price': 90.0, 'quantity': 4, 'unit': 'piece'},
      {'name': "Lay's Chips", 'category': 'Snacks', 'price': 20.0, 'quantity': 60, 'unit': 'piece'},
      {'name': 'Kurkure', 'category': 'Snacks', 'price': 20.0, 'quantity': 50, 'unit': 'piece'},
      {'name': 'Parle-G Biscuit', 'category': 'Snacks', 'price': 10.0, 'quantity': 80, 'unit': 'piece'},
      {'name': 'Britannia Good Day', 'category': 'Snacks', 'price': 30.0, 'quantity': 40, 'unit': 'piece'},
      {'name': 'Tata Tea Premium', 'category': 'Beverages', 'price': 85.0, 'quantity': 25, 'unit': 'packet'},
      {'name': 'Nescafe Coffee', 'category': 'Beverages', 'price': 220.0, 'quantity': 12, 'unit': 'piece'},
      {'name': 'Pepsi 2L', 'category': 'Beverages', 'price': 95.0, 'quantity': 18, 'unit': 'piece'},
      {'name': 'Frooti 200ml', 'category': 'Beverages', 'price': 15.0, 'quantity': 3, 'unit': 'piece'},
      {'name': 'Surf Excel 1kg', 'category': 'Cleaning', 'price': 145.0, 'quantity': 20, 'unit': 'packet'},
      {'name': 'Vim Bar', 'category': 'Cleaning', 'price': 22.0, 'quantity': 35, 'unit': 'piece'},
      {'name': 'Lizol Floor Cleaner', 'category': 'Cleaning', 'price': 125.0, 'quantity': 10, 'unit': 'piece'},
      {'name': 'Colgate Toothpaste', 'category': 'Personal Care', 'price': 60.0, 'quantity': 25, 'unit': 'piece'},
      {'name': 'Dove Soap', 'category': 'Personal Care', 'price': 45.0, 'quantity': 30, 'unit': 'piece'},
      {'name': 'Head & Shoulders', 'category': 'Personal Care', 'price': 185.0, 'quantity': 15, 'unit': 'piece'},
    ];

    final Map<String, dynamic> productData = {};
    final List<String> ids = [];
    for (final p in products) {
      final id = _uuid.v4();
      ids.add(id);
      productData[id] = p;
    }
    await _db.ref('products').set(productData);

    // Seed bills for last 7 days
    final customers = ['Ramesh Patel', 'Sunita Shah', 'Mehul Joshi', 'Priya Desai', 'Kamlesh Modi'];
    final now = DateTime.now();

    for (int day = 6; day >= 0; day--) {
      final billDate = now.subtract(Duration(days: day));
      final billsCount = day == 0 ? 3 : 2;

      for (int b = 0; b < billsCount; b++) {
        final billId = _uuid.v4();
        final customer = customers[(day + b) % customers.length];
        final itemCount = 2 + (day + b) % 3;
        final List<Map<String, dynamic>> items = [];
        double grandTotal = 0;

        for (int i = 0; i < itemCount; i++) {
          final idx = (day * 3 + b * 7 + i * 5) % products.length;
          final prod = products[idx];
          final qty = 1 + i % 3;
          final price = prod['price'] as double;
          final total = price * qty;
          grandTotal += total;
          items.add({
            'productId': ids[idx],
            'productName': prod['name'],
            'price': price,
            'quantity': qty,
            'unit': prod['unit'],
            'total': total,
          });
        }

        final billTime = billDate.add(Duration(hours: 9 + b * 3, minutes: b * 17));
        await _db.ref('bills/$billId').set({
          'customerName': customer,
          'items': items,
          'grandTotal': grandTotal,
          'createdAt': billTime.toIso8601String(),
        });
      }
    }
  }
}
