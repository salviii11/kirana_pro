// lib/screens/bills_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../services/firebase_service.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _svc = FirebaseService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF4A148C),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Sales History',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                         const   Text('',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by customer...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (v) =>
                      setState(() => _search = v.toLowerCase()),
                ),
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<Bill>>(
          stream: _svc.billsStream(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? [];
            final bills = _search.isEmpty
                ? all
                : all
                    .where((b) =>
                        b.customerName.toLowerCase().contains(_search))
                    .toList();

            if (bills.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 70, color: Colors.grey[200]),
                    const SizedBox(height: 12),
                    Text('No bills found',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 16)),
                  ],
                ),
              );
            }

            // Summary strip
            final totalRevenue =
                bills.fold(0.0, (s, b) => s + b.grandTotal);

            return Column(
              children: [
                // Summary banner
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                          label: 'Total Bills',
                          value: '${bills.length}',
                          icon: Icons.receipt),
                      Container(
                          width: 1, height: 40, color: Colors.white24),
                      _SummaryItem(
                          label: 'Total Revenue',
                          value: '₹${totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee),
                      Container(
                          width: 1, height: 40, color: Colors.white24),
                      _SummaryItem(
                          label: 'Avg Bill',
                          value:
                              '₹${(totalRevenue / bills.length).toStringAsFixed(0)}',
                          icon: Icons.analytics_outlined),
                    ],
                  ),
                ),

                // Bill list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: bills.length,
                    itemBuilder: (_, i) => _BillCard(
                      bill: bills[i],
                      onDelete: () =>
                          _confirmDelete(context, bills[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
            'Delete bill for "${bill.customerName}" — ₹${bill.grandTotal.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _svc.deleteBill(bill.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback onDelete;
  const _BillCard({required this.bill, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy · hh:mm a');
    final avatarColors = [
      Colors.purple, Colors.blue, Colors.teal, Colors.indigo, Colors.pink
    ];
    final color = avatarColors[bill.customerName.hashCode.abs() % 5];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              bill.customerName[0].toUpperCase(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(bill.customerName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(fmt.format(bill.createdAt),
              style: const TextStyle(fontSize: 11)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${bill.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15)),
                  Text('${bill.items.length} items',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red[300], size: 18),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  ...bill.items.map((item) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [
                          Expanded(
                              child: Text(item.productName,
                                  style: const TextStyle(fontSize: 14))),
                          Text(
                              '${item.quantity} ${item.unit} × ₹${item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12)),
                          const SizedBox(width: 12),
                          Text('₹${item.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ]),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${bill.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
