// lib/screens/billing_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../services/firebase_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _svc = FirebaseService();
  final _customerCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final List<BillItem> _cart = [];
  String _productSearch = '';
  List<Product> _allProducts = [];

  double get _total => _cart.fold(0, (s, i) => s + i.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<List<Product>>(
        stream: _svc.productsStream(),
        builder: (ctx, snap) {
          _allProducts = snap.data ?? [];
          final filtered = _productSearch.isEmpty
              ? <Product>[]
              : _allProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(_productSearch) ||
                      p.category.toLowerCase().contains(_productSearch))
                  .toList();

          return Column(
            children: [
              // ── Header ─────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Bill',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const Text('Add products to cart',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 14),
                        // Customer field
                        TextField(
                          controller: _customerCtrl,
                          decoration: InputDecoration(
                            hintText: 'Customer name (optional)',
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Product search
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search & add product...',
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.grey),
                            suffixIcon: _productSearch.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(
                                          () => _productSearch = '');
                                    })
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (v) =>
                              setState(() => _productSearch = v.toLowerCase()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Search Results ──────────────────────────────────
              if (filtered.isNotEmpty)
                Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[50],
                          radius: 18,
                          child: Text(p.name[0],
                              style:
                                  TextStyle(color: Colors.orange[800])),
                        ),
                        title: Text(p.name,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                            '₹${p.price} / ${p.unit}  ·  Stock: ${p.quantity}',
                            style: const TextStyle(fontSize: 12)),
                        trailing: GestureDetector(
                          onTap: () => _addToCart(p),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              if (filtered.isNotEmpty) const Divider(height: 1),

              // ── Cart ───────────────────────────────────────────
              Expanded(
                child: _cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 70, color: Colors.grey[200]),
                            const SizedBox(height: 12),
                            Text('Cart is empty',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Search above to add products',
                                style: TextStyle(
                                    color: Colors.grey[300], fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cart.length,
                        itemBuilder: (_, i) =>
                            _CartItem(
                          item: _cart[i],
                          onRemove: () =>
                              setState(() => _cart.removeAt(i)),
                          onIncrease: () => _changeQty(i, 1),
                          onDecrease: () => _changeQty(i, -1),
                        ),
                      ),
              ),

              // ── Bill Footer ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4))
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      if (_cart.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_cart.length} items',
                                style: TextStyle(color: Colors.grey[600])),
                            Text(
                              '₹${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          if (_cart.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _cart.clear()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side:
                                      const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                child: const Icon(Icons.delete_sweep),
                              ),
                            ),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE65100),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.receipt_long),
                              label: const Text('Save Bill',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _saveBill,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _changeQty(int index, int delta) {
    setState(() {
      final old = _cart[index];
      final newQty = old.quantity + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = BillItem(
          productId: old.productId,
          productName: old.productName,
          price: old.price,
          quantity: newQty,
          unit: old.unit,
        );
      }
    });
  }

  void _addToCart(Product product) {
    final idx = _cart.indexWhere((i) => i.productId == product.id);
    setState(() {
      if (idx >= 0) {
        final old = _cart[idx];
        _cart[idx] = BillItem(
          productId: old.productId,
          productName: old.productName,
          price: old.price,
          quantity: old.quantity + 1,
          unit: old.unit,
        );
      } else {
        _cart.add(BillItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
          unit: product.unit,
        ));
      }
    });
    _searchCtrl.clear();
    setState(() => _productSearch = '');
  }

  Future<void> _saveBill() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty!')));
      return;
    }
    final bill = Bill(
      id: const Uuid().v4(),
      customerName:
          _customerCtrl.text.trim().isEmpty ? 'Walk-in' : _customerCtrl.text.trim(),
      items: List.from(_cart),
      createdAt: DateTime.now(),
    );
    await _svc.saveBill(bill);
    for (final item in _cart) {
      await _svc.decreaseStock(item.productId, item.quantity);
    }
    if (!mounted) return;
    final total = bill.grandTotal;
    setState(() {
      _cart.clear();
      _customerCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '✅ Bill saved for ${bill.customerName} — ₹${total.toStringAsFixed(2)}'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _CartItem extends StatelessWidget {
  final BillItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItem(
      {required this.item,
      required this.onRemove,
      required this.onIncrease,
      required this.onDecrease});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 2),
              Text('₹${item.price} / ${item.unit}',
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
        // Qty controls
        Row(children: [
          GestureDetector(
            onTap: onDecrease,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.remove, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.quantity}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.add,
                  size: 16, color: Colors.orange[700]),
            ),
          ),
        ]),
        const SizedBox(width: 14),
        Text('₹${item.total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B5E20))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
        ),
      ]),
    );
  }
}
