import 'package:flutter/material.dart';
import '../config/theme.dart';

class MarketInsightPage extends StatefulWidget {
  const MarketInsightPage({super.key});

  @override
  State<MarketInsightPage> createState() => _MarketInsightPageState();
}

class _MarketInsightPageState extends State<MarketInsightPage> {
  String selectedTab = 'pangan';

  // Data pasar hanya ditampilkan setelah terhubung ke sumber resmi.
  final List<(String, String, String, String, bool)> panganData = [];
  final List<(String, String, String, String, bool)> ikanData = [];

  @override
  Widget build(BuildContext context) {
    final data = selectedTab == 'pangan' ? panganData : ikanData;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Market Insight',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: brandGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: brandRed.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights_rounded, color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'HARGA PASAR HARI INI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Pantau harga pangan & ikan terkini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Sumber data resmi belum terhubung',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Filter
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: '🍚 Pangan',
                  selected: selectedTab == 'pangan',
                  onTap: () => setState(() => selectedTab = 'pangan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TabButton(
                  label: '🐟 Ikan',
                  selected: selectedTab == 'ikan',
                  onTap: () => setState(() => selectedTab = 'ikan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jangan tampilkan angka contoh sebagai harga pasar aktual.
          if (data.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: line),
              ),
              child: const Text(
                'Data harga pasar belum tersedia. Informasi akan ditampilkan setelah integrasi sumber resmi aktif.',
                style: TextStyle(fontSize: 12, color: muted, height: 1.5),
              ),
            ),
          ...data.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightRow(
                icon: item.$1,
                name: item.$2,
                price: item.$3,
                trend: item.$4,
                trendUp: item.$5,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: goldDeep, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data harga pasar belum tersedia; tidak ada angka estimasi yang ditampilkan.',
                    style: TextStyle(
                      color: goldDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected ? brandGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.transparent : line),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brandRed.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String icon;
  final String name;
  final String price;
  final String trend;
  final bool trendUp;

  const _InsightRow({
    required this.icon,
    required this.name,
    required this.price,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trendUp ? emeraldGreen : brandRed;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              width: 3,
              decoration: const BoxDecoration(gradient: brandGradient),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: brandRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: brandRed,
                          letterSpacing: -0.3,
                        ),
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
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
