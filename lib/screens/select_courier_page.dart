import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class SelectCourierPage extends StatefulWidget {
  final String orderPublicId;
  final String orderNumber;
  const SelectCourierPage({
    super.key,
    required this.orderPublicId,
    required this.orderNumber,
  });

  @override
  State<SelectCourierPage> createState() => _SelectCourierPageState();
}

class _SelectCourierPageState extends State<SelectCourierPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _couriers = [];
  String? _assigningId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final couriers = await ApiService().getAvailableCouriers(
        lat: -6.5849,
        lng: 106.8234,
        radius: 5,
      );
      setState(() { _couriers = couriers; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _assign(dynamic courier) async {
    setState(() => _assigningId = courier['id'].toString());
    try {
      await ApiService().assignCourier(widget.orderPublicId, courier['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Order di-assign ke ${courier['name']}')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal assign: $e')),
      );
      setState(() => _assigningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text('Pilih Kurir — ${widget.orderNumber}'),
        backgroundColor: Colors.white,
        foregroundColor: ink,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: brandRed))
          : _error != null
              ? Center(child: Text(_error!))
              : _couriers.isEmpty
                  ? const Center(child: Text('Belum ada kurir tersedia dalam 5 km.', style: TextStyle(color: muted)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _couriers.length,
                      itemBuilder: (context, index) {
                        final c = _couriers[index];
                        final isAssigning = _assigningId == c['id'].toString();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: line),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: brandRed.withOpacity(0.1),
                                backgroundImage: (c['avatar_url'] != null && c['avatar_url'].toString().isNotEmpty)
                                    ? NetworkImage(c['avatar_url'].toString())
                                    : null,
                                child: (c['avatar_url'] == null || c['avatar_url'].toString().isEmpty)
                                    ? const Icon(Icons.person, color: brandRed)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] ?? 'Kurir', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${c['vehicle_type'] ?? '-'} · ${c['city'] ?? '-'}', style: const TextStyle(fontSize: 11, color: muted)),
                                    Text('${c['distance_km']?.toStringAsFixed(1) ?? '-'} km', style: const TextStyle(fontSize: 10, color: brandRed, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: isAssigning ? null : () => _assign(c),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandRed,
                                  foregroundColor: Colors.white,
                                ),
                                child: isAssigning
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('PILIH'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
