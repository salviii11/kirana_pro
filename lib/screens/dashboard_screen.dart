// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = FirebaseService();
    final today = DateTime.now();
    final greeting = today.hour < 12
        ? 'Good Morning'
        : today.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🛒',
                                  style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(greeting,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.8),
                                        fontSize: 13)),
                                const Text('Smart Kirana Shop',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(today),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats Grid ─────────────────────────────────────
                StreamBuilder<List<Product>>(
                  stream: svc.productsStream(),
                  builder: (ctx, pSnap) => StreamBuilder<List<Bill>>(
                    stream: svc.billsStream(),
                    builder: (ctx2, bSnap) {
                      final products = pSnap.data ?? [];
                      final bills = bSnap.data ?? [];
                      final todayBills = bills.where((b) =>
                          b.createdAt.day == today.day &&
                          b.createdAt.month == today.month &&
                          b.createdAt.year == today.year);
                      final todaySales = todayBills.fold(
                          0.0, (s, b) => s + b.grandTotal);
                      final totalSales =
                          bills.fold(0.0, (s, b) => s + b.grandTotal);
                      final lowStock =
                          products.where((p) => p.quantity < 5).length;

                      return Column(children: [
                        Row(children: [
                          _InfoCard(
                            label: "Today's Sales",
                            value: '₹${todaySales.toStringAsFixed(0)}',
                            icon: Icons.trending_up,
                            gradient: const [Color(0xFF43A047), Color(0xFF1B5E20)],
                          ),
                          const SizedBox(width: 12),
                          _InfoCard(
                            label: "Today's Bills",
                            value: '${todayBills.length}',
                            icon: Icons.receipt,
                            gradient: const [Color(0xFFFF7043), Color(0xFFBF360C)],
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          _InfoCard(
                            label: 'Total Revenue',
                            value: '₹${totalSales.toStringAsFixed(0)}',
                            icon: Icons.currency_rupee,
                            gradient: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                          ),
                          const SizedBox(width: 12),
                          _InfoCard(
                            label: 'Low Stock',
                            value: '$lowStock items',
                            icon: Icons.warning_amber_rounded,
                            gradient: lowStock > 0
                                ? const [Color(0xFFEF5350), Color(0xFFB71C1C)]
                                : const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                          ),
                        ]),
                      ]);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Category Breakdown ───────────────────────────
                _SectionHeader(title: 'Category Overview', icon: Icons.pie_chart_outline),
                const SizedBox(height: 10),
                StreamBuilder<List<Product>>(
                  stream: svc.productsStream(),
                  builder: (ctx, snap) {
                    final products = snap.data ?? [];
                    final Map<String, int> catCount = {};
                    for (final p in products) {
                      catCount[p.category] = (catCount[p.category] ?? 0) + 1;
                    }
                    if (catCount.isEmpty) {
                      return const _EmptyState(
                          icon: Icons.category, msg: 'No products yet');
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: catCount.entries
                          .map((e) => _CategoryChip(
                              name: e.key, count: e.value))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Low Stock Alert ─────────────────────────────
                _SectionHeader(
                    title: 'Low Stock Alert', icon: Icons.warning_amber),
                const SizedBox(height: 10),
                StreamBuilder<List<Product>>(
                  stream: svc.productsStream(),
                  builder: (ctx, snap) {
                    final lowStock = (snap.data ?? [])
                        .where((p) => p.quantity < 5)
                        .toList();
                    if (lowStock.isEmpty) {
                      return const _EmptyState(
                          icon: Icons.check_circle_outline,
                          msg: 'All products are well stocked!',
                          color: Colors.green);
                    }
                    return Column(
                      children: lowStock
                          .map((p) => _LowStockTile(product: p))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Recent Bills ────────────────────────────────
                _SectionHeader(
                    title: 'Recent Bills', icon: Icons.receipt_long_outlined),
                const SizedBox(height: 10),
                StreamBuilder<List<Bill>>(
                  stream: svc.billsStream(),
                  builder: (ctx, snap) {
                    final bills = (snap.data ?? []).take(5).toList();
                    if (bills.isEmpty) {
                      return const _EmptyState(
                          icon: Icons.receipt_long, msg: 'No bills yet');
                    }
                    return Column(
                      children: bills
                          .map((b) => _RecentBillTile(bill: b))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _InfoCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2C1B))),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final int count;
  const _CategoryChip({required this.name, required this.count});

  static const _colors = [
    Color(0xFFE8F5E9), Color(0xFFFFF3E0), Color(0xFFE3F2FD),
    Color(0xFFFCE4EC), Color(0xFFF3E5F5), Color(0xFFE0F7FA),
    Color(0xFFFFF8E1), Color(0xFFE8EAF6),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = name.hashCode % _colors.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _colors[idx.abs()],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text('$name ($count)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final Product product;
  const _LowStockTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.warning_amber,
                color: Colors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${product.quantity} ${product.unit}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentBillTile extends StatelessWidget {
  final Bill bill;
  const _RecentBillTile({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              bill.customerName[0].toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${bill.items.length} items · ${DateFormat('hh:mm a').format(bill.createdAt)}',
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${bill.grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B5E20))),
              Text(DateFormat('dd MMM').format(bill.createdAt),
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String msg;
  final Color color;
  const _EmptyState(
      {required this.icon, required this.msg, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(msg, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
