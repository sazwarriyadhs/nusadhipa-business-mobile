import 'package:flutter/material.dart';
import 'dart:math'; // Tambahan untuk generate data grafik dinamis
import '../models/business.dart';
import '../config/business_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/theme/app_theme.dart'; 
import '../services/api_service.dart';
import '../services/nav_service.dart';
import '../services/auth_service.dart'; // Import untuk Logout
import 'login_screen.dart'; // Sesuaikan dengan nama file Login kamu
import 'add_product_page.dart';
import 'market_insight_page.dart';
import 'documents/financial_report_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = true;
  int totalProducts = 0;
  int totalCategories = 0;
  int totalSellers = 0;
  bool connected = false;
  String tenantName = 'Memuat Data...';
  Business? businessData;
  
  // List untuk menyimpan data grafik dinamis
  List<FlSpot> chartSpots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final business = await ApiService().getMyBusiness();
      setState(() { businessData = business; tenantName = business.businessName; });
      final products = await ApiService().getProducts(business: business.slug, limit: 100);

      final categories = products.map((p) => p.categoryName).where((c) => c.isNotEmpty).toSet().toList();
      final sellers = <String>{business.businessName};

      // Generate data grafik dinamis (simulasi harga komoditas)
      final random = Random();
      final generatedSpots = List.generate(7, (index) => 
        FlSpot(index.toDouble(), (40 + random.nextInt(50)).toDouble())
      );

      if (!mounted) return;
      setState(() {
        tenantName = business.businessName.toUpperCase();
        totalProducts = products.length;
        totalCategories = categories.length;
        totalSellers = sellers.length;
        chartSpots = generatedSpots;
        loading = false;
        connected = true;
      });

      // DEBUG: Cek di terminal apakah API ngirim data halal atau nggak
      debugPrint("DEBUG HALAL: ${business.halalCertificateNumber}");

    } catch (e) {
      debugPrint("ERROR LOAD DATA: $e");
      if (!mounted) return;
      setState(() {
        loading = false;
        connected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTopBackground(),
                  Positioned(
                    top: 160,
                    left: 0,
                    right: 0,
                    child: _buildSummaryCard(),
                  ),
                ],
              ),
              
              const SizedBox(height: 220),
              _buildKpiChart(),
              const SizedBox(height: 16),
              _buildBusinessBanner(),
              const SizedBox(height: 20),
              _buildOperationalMenu(),
              const SizedBox(height: 24),
              _buildNetworkSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBackground() {
    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        image: DecorationImage(
          image: NetworkImage(businessData?.bannerUrl ?? 'https://res.cloudinary.com/wqytmco9/image/upload/v1793337981/coverpempek.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkNavy.withOpacity(0.95),
              AppColors.darkNavy.withOpacity(0.4),
              AppColors.darkNavy.withOpacity(0.9),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/branding/logo_nusadhipa_baru.png', 
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      children: [
                        // Ikon Lonceng Notifikasi
                        Stack(
                          children: [
                            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                            Positioned(
                              right: 0, top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle),
                                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 16), // Jarak antara lonceng dan logout
                        
                        // Tombol Logout
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text('Konfirmasi Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.poppins()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await AuthService().logout(); // Hapus token
                              if (context.mounted) {
                                // Balik ke halaman login (hapus semua history route)
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()), // Sesuaikan dengan nama class Login kamu
                                  (route) => false,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.logout, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text('Selamat Datang', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tenantName, 
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.circle, color: connected ? AppColors.successGreen : Colors.red, size: 10),
                    const SizedBox(width: 6),
                    Text(
                      connected ? 'TENANT WORKSPACE AKTIF' : 'KONEKSI TERPUTUS',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardNavy.withOpacity(0.95), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
        image: const DecorationImage(
          image: AssetImage('assets/branding/Fresh Poultry Processing Showcase.png'),
          fit: BoxFit.cover,
          alignment: Alignment.bottomRight,
          opacity: 0.15, 
        ),
      ),
      child: loading
          ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppColors.primaryRed)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RINGKASAN BISNIS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 16),
                        Text('TOTAL PRODUK', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                        Text('$totalProducts', style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
                      ],
                    ),
                    Container(
                      height: 60, width: 60,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: businessData?.logoUrl != null ? Image.network(businessData!.logoUrl!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) { return Text(businessData!.businessName.substring(0, 2).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)); }) : Text(businessData?.businessName.substring(0, 2).toUpperCase() ?? 'PT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    _buildMetricItem(Icons.grid_view_rounded, 'KATEGORI', '$totalCategories'),
                    const SizedBox(width: 12),
                    _buildMetricItem(Icons.people_alt_rounded, 'TENANT', '$totalSellers'),
                  ],
                ),
                const SizedBox(height: 12),

                // BADGE HALAL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/branding/halalmerah.png',
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.verified, color: AppColors.primaryRed, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          (businessData?.halalCertificateNumber != null && businessData!.halalCertificateNumber!.isNotEmpty) 
                              ? 'Halal: ${businessData!.halalCertificateNumber}' 
                              : 'Belum ada sertifikat halal', 
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 13
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(Icons.check_circle, color: connected ? AppColors.successGreen : Colors.red, size: 14),
                    const SizedBox(width: 6),
                    Text(connected ? 'API TERHUBUNG' : 'API OFFLINE', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                    const Spacer(),
                    Text('Semua sistem berjalan normal >', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9)),
                  ],
                )
              ],
            ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKpiChart() {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TREN PASAR', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkNavy)),
                  const SizedBox(height: 4),
                  Text('Pergerakan harga komoditas minggu ini', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('+12.5%', style: GoogleFonts.poppins(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(days[value.toInt()], style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.darkNavy,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          'Rp ${barSpot.y.toStringAsFixed(0)}K',
                          GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartSpots.isEmpty 
                        ? const [FlSpot(0, 0)]
                        : chartSpots,
                    isCurved: true,
                    color: AppColors.primaryRed,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.primaryRed,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryRed.withOpacity(0.2),
                          AppColors.primaryRed.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      height: 110, 
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/branding/Fresh Poultry Processing Showcase.png'), 
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.darkNavy, AppColors.darkNavy.withOpacity(0.0)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset('assets/branding/logo_nusadhipa_baru.png', height: 24, fit: BoxFit.contain),
                    const SizedBox(width: 8),
                    Text('BUSINESS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Merajut Kearifan Lokal Nusantara', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 8),
                Text('UMKM  •  LEGAL  •  TERHUBUNG', style: GoogleFonts.poppins(color: AppColors.primaryRed, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPERASIONAL BISNIS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkNavy)),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.grid_view_rounded, 'Produk', 'Kelola katalog produk Anda', AppColors.primaryRed, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProductPage()))),
          _buildMenuItem(Icons.receipt_long_rounded, 'Pesanan', 'Kelola transaksi dan pesanan', AppColors.darkNavy, () => NavService.switchTab(1)),
          _buildMenuItem(Icons.diamond_rounded, 'Identitas Toko', 'Logo dan branding toko Anda', AppColors.primaryRed, () => NavService.switchTab(4)),
          _buildMenuItem(Icons.account_balance_wallet_rounded, 'Keuangan', 'Laporan bisnis dan keuangan', AppColors.darkNavy, () async {
            final business = await ApiService().getMyBusiness();
            setState(() { businessData = business; tenantName = business.businessName; });
            if (!context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => FinancialReportPage(business: business)));
          }),
          _buildMenuItem(Icons.trending_up_rounded, 'Insight Pasar', 'Informasi komoditas dan tren pasar', AppColors.primaryRed, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MarketInsightPage()))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, Color iconColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20), 
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkNavy)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNetworkSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('JEJARING UMKM NUSANTARA', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkNavy)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNetworkCard(Icons.verified_user_rounded, AppColors.primaryRed, 'TERVERIFIKASI', 'Kualitas UMKM')),
              const SizedBox(width: 12),
              Expanded(child: _buildNetworkCard(Icons.handshake_rounded, AppColors.darkNavy, 'TERHUBUNG', 'Kolaborasi & peluang')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNetworkCard(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkNavy)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}