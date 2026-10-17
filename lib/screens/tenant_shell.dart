import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/nav_service.dart';
import 'dashboard_page.dart';
import 'orders_page.dart';
import 'products_page.dart';
import 'shipping_page.dart';
import 'store_page.dart';

class TenantShell extends StatefulWidget {
  const TenantShell({super.key});

  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Daftarkan switcher supaya QuickAction bisa ganti tab
    NavService.registerTabSwitcher((i) {
      if (mounted) setState(() => selectedIndex = i);
    });
  }

  final pages = const [
    DashboardPage(),
    OrdersPage(),
    ProductsPage(),
    ShippingPage(),
    StorePage(),
  ];

  final labels = const ['Beranda', 'Pesanan', 'Produk', 'Kirim', 'Toko'];

  final icons = const [
    Icons.grid_view_rounded,
    Icons.receipt_long_rounded,
    Icons.inventory_2_rounded,
    Icons.local_shipping_rounded,
    Icons.storefront_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: _RedBottomNav(
        selectedIndex: selectedIndex,
        labels: labels,
        icons: icons,
        onSelect: (value) => setState(() => selectedIndex = value),
      ),
    );
  }
}

class _RedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onSelect;

  const _RedBottomNav({
    required this.selectedIndex,
    required this.labels,
    required this.icons,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: brandGradient,
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(
              labels.length,
              (i) => Expanded(
                child: _NavItem(
                  icon: icons[i],
                  label: labels[i],
                  selected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: selected
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.72),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}