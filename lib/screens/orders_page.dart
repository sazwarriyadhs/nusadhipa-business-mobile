import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import 'select_courier_page.dart';
import '../models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _loading = true;
  String? _error;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Baru', 'Dibayar', 'Dikirim', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await ApiService().getOrders();
      setState(() {
        _orders = orders;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'Semua') {
      _filteredOrders = _orders;
    } else {
      _filteredOrders = _orders.where((o) {
        return o.statusLabel.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }
  }

  Future<void> _claimPickup(Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Klaim Pickup?'),
        content: Text('Kurir NUSA-DHIPA akan mengambil pesanan ${order.orderNumber}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
            child: const Text('Klaim'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiService().claimPickup(order.publicId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pickup berhasil diklaim! Kurir akan segera datang.')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal klaim: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: brandRed));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: brandRed, size: 52),
              const SizedBox(height: 12),
              const Text('Gagal memuat pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: canvas,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text('Pesanan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Pantau pesanan pelanggan', style: TextStyle(fontSize: 12, color: muted)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : ink)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilter();
                          });
                        },
                        selectedColor: brandRed,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? brandRed : line),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_filteredOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada pesanan.', style: TextStyle(color: muted))),
                )
              else
                ..._filteredOrders.map((o) => _buildOrderCard(o)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final canClaimPickup = order.statusLabel == 'Dibayar' || order.statusLabel == 'Diproses';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: brandRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.receipt_long, color: brandRed, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(order.orderNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(order.statusLabel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: brandRed)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: muted),
              const SizedBox(width: 6),
              Text(order.buyerName, style: const TextStyle(fontSize: 12, color: ink)),
              const Spacer(),
              const Icon(Icons.shopping_bag_outlined, size: 14, color: muted),
              const SizedBox(width: 6),
              Text('${order.itemsCount} item', style: const TextStyle(fontSize: 12, color: muted)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 10, color: muted)),
                    Text(order.grandTotalDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: brandRed)),
                  ],
                ),
              ),
              if (canClaimPickup) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectCourierPage(
                          orderPublicId: order.publicId,
                          orderNumber: order.orderNumber,
                        ),
                      ),
                    );
                    if (res == true) _load();
                  },
                  icon: const Icon(Icons.person_search, size: 16),
                  label: const Text('PILIH KURIR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: brandRed),
                    foregroundColor: brandRed,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
              if (canClaimPickup)
                ElevatedButton.icon(
                  onPressed: () => _claimPickup(order),
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('KLAIM PICKUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('INVOICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: brandRed),
                    foregroundColor: brandRed,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

