import 'package:flutter/material.dart';
import '../models/business.dart';

/// Jenis usaha berdasarkan KBLI. Setiap jenis punya:
/// - label tampilan (chip)
/// - ikon
/// - gradient banner fallback
/// - warna aksen
class BusinessTypeInfo {
  final String slug;
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color accent;

  const BusinessTypeInfo({
    required this.slug,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}

const List<BusinessTypeInfo> _allTypes = [
  BusinessTypeInfo(
    slug: '01-makanan-minuman',
    label: 'Makanan & Minuman',
    icon: Icons.restaurant_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFE5232E), Color(0xFFC41E28)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFFE5232E),
  ),
  BusinessTypeInfo(
    slug: '03-peternakan-daging-perikanan',
    label: 'Unggas, Daging & Perikanan',
    icon: Icons.set_meal_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFFB91C1C),
  ),
  BusinessTypeInfo(
    slug: '04-petfood-kebutuhan-hewan',
    label: 'Petfood & Hewan',
    icon: Icons.pets_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFEA580C), Color(0xFF9A3412)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFFEA580C),
  ),
  BusinessTypeInfo(
    slug: '05-fashion-aksesori',
    label: 'Fashion & Aksesori',
    icon: Icons.checkroom_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF7C3AED),
  ),
  BusinessTypeInfo(
    slug: '06-kerajinan-produk-kreatif',
    label: 'Kerajinan & Kreatif',
    icon: Icons.palette_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFD97706), Color(0xFF92400E)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFFD97706),
  ),
  BusinessTypeInfo(
    slug: '07-rumah-tangga-perlengkapan',
    label: 'Rumah Tangga',
    icon: Icons.chair_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF0891B2), Color(0xFF155E75)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF0891B2),
  ),
  BusinessTypeInfo(
    slug: '08-kecantikan-perawatan-diri',
    label: 'Kecantikan & Perawatan',
    icon: Icons.spa_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFDB2777), Color(0xFF9D174D)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFFDB2777),
  ),
  BusinessTypeInfo(
    slug: '09-tanaman-bunga-florist',
    label: 'Tanaman & Bunga',
    icon: Icons.local_florist_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF16A34A), Color(0xFF15803D)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF16A34A),
  ),
  BusinessTypeInfo(
    slug: '10-elektronik-peralatan',
    label: 'Elektronik & Peralatan',
    icon: Icons.devices_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF2563EB),
  ),
  BusinessTypeInfo(
    slug: '11-jasa-layanan-bisnis',
    label: 'Jasa & Layanan',
    icon: Icons.work_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF475569), Color(0xFF1E293B)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF475569),
  ),
  BusinessTypeInfo(
    slug: '12-industri-grosir-b2b',
    label: 'Industri & Grosir',
    icon: Icons.factory_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF0369A1), Color(0xFF075985)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    accent: Color(0xFF0369A1),
  ),
];

/// KBLI code → jenis usaha slug
const Map<String, String> _kbliToSlug = {
  // Makanan & Minuman
  '56101': '01-makanan-minuman', '56102': '01-makanan-minuman', '56201': '01-makanan-minuman',
  // Peternakan, Daging, Perikanan
  '46322': '03-peternakan-daging-perikanan', '46325': '03-peternakan-daging-perikanan',
  '46205': '03-peternakan-daging-perikanan', '46311': '03-peternakan-daging-perikanan',
  '46319': '03-peternakan-daging-perikanan', '47211': '03-peternakan-daging-perikanan',
  '47212': '03-peternakan-daging-perikanan',
  // Petfood
  '47731': '04-petfood-kebutuhan-hewan', '47732': '04-petfood-kebutuhan-hewan',
  '47733': '04-petfood-kebutuhan-hewan',
  // Fashion
  '14111': '05-fashion-aksesori', '14112': '05-fashion-aksesori',
  '47511': '05-fashion-aksesori', '47512': '05-fashion-aksesori',
  '47711': '05-fashion-aksesori',
  // Kerajinan
  '16101': '06-kerajinan-produk-kreatif', '16291': '06-kerajinan-produk-kreatif',
  '32901': '06-kerajinan-produk-kreatif',
  // Rumah Tangga
  '47531': '07-rumah-tangga-perlengkapan', '47532': '07-rumah-tangga-perlengkapan',
  '47781': '07-rumah-tangga-perlengkapan',
  // Kecantikan
  '47721': '08-kecantikan-perawatan-diri', '47722': '08-kecantikan-perawatan-diri',
  '96011': '08-kecantikan-perawatan-diri',
  // Tanaman & Bunga
  '47761': '09-tanaman-bunga-florist', '47762': '09-tanaman-bunga-florist',
  '01301': '09-tanaman-bunga-florist', '01309': '09-tanaman-bunga-florist',
  // Elektronik
  '47411': '10-elektronik-peralatan', '47412': '10-elektronik-peralatan',
  '47413': '10-elektronik-peralatan',
  // Jasa
  '62010': '11-jasa-layanan-bisnis', '62020': '11-jasa-layanan-bisnis',
  '62900': '11-jasa-layanan-bisnis', '70201': '11-jasa-layanan-bisnis',
  '73100': '11-jasa-layanan-bisnis',
  // Industri/Grosir
  '46900': '12-industri-grosir-b2b',
};

/// Deteksi jenis usaha dari Business.
/// Prioritas: 1) KBLI code, 2) nama bisnis, 3) default.
BusinessTypeInfo resolveBusinessType(Business? business) {
  if (business == null) return _allTypes.first;

  // 1. Dari KBLI code
  final kbli = business.kbliCode ?? '';
  final slugFromKbli = _kbliToSlug[kbli];
  if (slugFromKbli != null) {
    return _allTypes.firstWhere(
      (t) => t.slug == slugFromKbli,
      orElse: () => _allTypes.first,
    );
  }

  // 2. Dari nama bisnis
  final name = business.businessName.toLowerCase();
  if (name.contains('bunga') || name.contains('florist') || name.contains('tanaman')) {
    return _allTypes.firstWhere((t) => t.slug == '09-tanaman-bunga-florist');
  }
  if (name.contains('ayam') || name.contains('daging') || name.contains('ikan') || name.contains('unggas')) {
    return _allTypes.firstWhere((t) => t.slug == '03-peternakan-daging-perikanan');
  }
  if (name.contains('kucing') || name.contains('anjing') || name.contains('pet')) {
    return _allTypes.firstWhere((t) => t.slug == '04-petfood-kebutuhan-hewan');
  }
  if (name.contains('digital') || name.contains('media') || name.contains('teknologi')) {
    return _allTypes.firstWhere((t) => t.slug == '11-jasa-layanan-bisnis');
  }
  if (name.contains('fashion') || name.contains('butik') || name.contains('baju')) {
    return _allTypes.firstWhere((t) => t.slug == '05-fashion-aksesori');
  }

  // 3. Default
  return _allTypes.first;
}

/// URL cover default (dari server nusadhipa.shop).
/// Kalau gagal load, BrandHeader akan fallback ke gradient jenis usaha.
String coverUrlForType(BusinessTypeInfo info) =>
    'https://nusadhipa.shop/kategori/${info.slug}.png';
