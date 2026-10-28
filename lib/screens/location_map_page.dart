import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/business.dart';
import '../services/geocoding_service.dart';

class LocationMapPage extends StatefulWidget {
  final Business? business;
  const LocationMapPage({super.key, this.business});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  bool loading = true;
  LatLng? coords;
  String? errorMessage;
  String addressForSearch = '';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final biz = widget.business;
    if (biz == null) {
      setState(() {
        loading = false;
        errorMessage = 'Data bisnis tidak tersedia.';
      });
      return;
    }

    // Bangun alamat lengkap
    final parts = <String>[
      if (biz.address != null && biz.address!.isNotEmpty) biz.address!,
      if (biz.city != null && biz.city!.isNotEmpty) biz.city!,
      if (biz.province != null && biz.province!.isNotEmpty) biz.province!,
    ];
    addressForSearch = parts.join(', ');

    if (addressForSearch.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = 'Alamat toko belum diisi.';
      });
      return;
    }

    final result = await GeocodingService.geocode(addressForSearch);
    if (!mounted) return;
    setState(() {
      coords = result;
      loading = false;
      if (result == null) {
        errorMessage = 'Lokasi tidak ditemukan di peta.';
      }
    });
  }

  Future<void> _openOsmAnd() async {
    if (coords == null) return;
    final url = Uri.parse(
      'https://osmand.net/go.html?lat=${coords!.latitude}&lon=${coords!.longitude}&z=17',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBrowser() async {
    if (coords == null) return;
    final url = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${coords!.latitude}&mlon=${coords!.longitude}#map=17/${coords!.latitude}/${coords!.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final biz = widget.business;
    final name = biz?.businessName ?? 'Toko Saya';
    final address = addressForSearch.isEmpty
        ? (biz?.locationDisplay ?? '-')
        : addressForSearch;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Toko'),
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: brandRed),
            )
          : Column(
              children: [
                // Peta
                Expanded(
                  child: coords != null
                      ? FlutterMap(
                          options: MapOptions(
                            initialCenter: coords!,
                            initialZoom: 16,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.nusadhipa.business',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: coords!,
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: brandRed,
                                    size: 44,
                                  ),
                                ),
                              ],
                            ),
                            const RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  '© OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
                        )
                      : Container(
                          color: canvas,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_rounded,
                                size: 64,
                                color: muted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage ?? 'Lokasi tidak ditemukan',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                address,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // Info card bawah
                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront_rounded,
                              color: brandRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: muted,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (coords != null) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _openBrowser,
                                  icon: const Icon(
                                    Icons.public_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Browser'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: brandRed,
                                    side: BorderSide(
                                      color: brandRed.withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _openOsmAnd,
                                  icon: const Icon(
                                    Icons.navigation_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Buka OsmAnd'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: brandRed,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}