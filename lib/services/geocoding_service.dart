import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Service geocoding gratis pakai Nominatim (OpenStreetMap).
/// Rate limit: 1 req/detik. Kita cache hasilnya di memory biar aman.
class GeocodingService {
  static final Map<String, LatLng?> _cache = {};
  static DateTime _lastRequest = DateTime(2000);

  /// Geocode alamat teks jadi koordinat.
  /// Return null kalau tidak ketemu atau error.
  static Future<LatLng?> geocode(String address) async {
    final key = address.trim().toLowerCase();
    if (key.isEmpty) return null;

    // Cek cache dulu
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    // Rate limit: minimal 1 detik jeda antar request
    final now = DateTime.now();
    final diff = now.difference(_lastRequest);
    if (diff.inMilliseconds < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - diff.inMilliseconds));
    }
    _lastRequest = DateTime.now();

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(address)}'
        '&format=json&limit=1&countrycodes=id',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'NusadhipaBusinessMobile/1.0 (contact@nusadhipa.shop)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _cache[key] = null;
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final item = data.first as Map<String, dynamic>;
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lng = double.tryParse(item['lon']?.toString() ?? '');
        if (lat != null && lng != null) {
          final coords = LatLng(lat, lng);
          _cache[key] = coords;
          return coords;
        }
      }

      _cache[key] = null;
      return null;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  /// Bersihkan cache (opsional, misal saat user logout).
  static void clearCache() => _cache.clear();
}