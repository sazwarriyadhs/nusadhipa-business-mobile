import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/heading.dart';

class ShippingPage extends StatefulWidget {
  const ShippingPage({super.key});

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  bool loading = true;
  String? error;
  List<Shipment> shipments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getShipments();
      if (!mounted) return;
      setState(() {
        shipments = result;
        loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Terjadi kesalahan tidak terduga';
        loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return muted;
      case 'ready':
        return orange;
      case 'picked_up':
        return oceanBlue;
      case 'in_transit':
        return oceanBlue;
      case 'delivered':
        return emeraldGreen;
      case 'failed':
      case 'returned':
        return brandRed;
      default:
        return muted;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'ready':
        return Icons.inventory_2_rounded;
      case 'picked_up':
        return Icons.local_shipping_rounded;
      case 'in_transit':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'failed':
        return Icons.error_rounded;
      case 'returned':
        return Icons.assignment_return_rounded;
      default:
        return Icons.local_shipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inTransit = shipments
        .where((s) => s.status == 'in_transit' || s.status == 'picked_up')
        .length;
    final delivered = shipments.where((s) => s.status == 'delivered').length;

    return SafeArea(
      child: RefreshIndicator(
        color: brandRed,
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Heading('Pengiriman', 'Kelola status pengantaran'),

            // ===== Hero card =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: brandRed.withValues(alpha: 0.4),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.local_shipping,
                        color: Colors.white.withValues(alpha: 0.12),
                        size: 120,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Pusat pengiriman',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pantau kesiapan paket dan status pengiriman.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _HeroStat(
                              icon: Icons.local_shipping_rounded,
                              value: '$inTransit',
                              label: 'Dalam perjalanan',
                            ),
                            const SizedBox(width: 10),
                            _HeroStat(
                              icon: Icons.check_circle_rounded,
                              value: '$delivered',
                              label: 'Terkirim',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Heading('Daftar pengiriman', 'Data live dari marketplace'),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: brandRed),
                ),
              )
            else if (error != null)
              _ErrorState(message: error!, onRetry: _load)
            else if (shipments.isEmpty)
              const _EmptyState()
            else
              ...shipments.map(
                (s) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: _ShipmentCard(
                    shipment: s,
                    statusColor: _statusColor(s.status),
                    statusIcon: _statusIcon(s.status),
                  ),
                ),
              ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Data pengiriman diambil dari server marketplace.',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final Color statusColor;
  final IconData statusIcon;

  const _ShipmentCard({
    required this.shipment,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(gradient: brandGradient),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            brandRed.withValues(alpha: 0.18),
                            brandRed.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: brandRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shipment.destinationCity ?? 'Alamat tidak tersedia',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            shipment.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (shipment.courier != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: muted,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${shipment.courier ?? ""} · ${shipment.serviceName ?? ""}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (shipment.trackingNumber != null)
                  Row(
                    children: [
                      const Icon(Icons.qr_code_rounded, color: muted, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shipment.trackingNumber!,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: brandRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat pengiriman',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🚚', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'Belum ada pengiriman',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: ink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Pengiriman akan muncul setelah order diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
