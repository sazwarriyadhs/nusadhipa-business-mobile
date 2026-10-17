import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/business.dart';
import '../services/api_service.dart';
import '../widgets/heading.dart';
import '../widgets/panel.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool isOpen = true;
  bool loading = true;
  String? error;
  Business? business;

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  Future<void> _loadBusiness() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getMyBusiness();
      if (!mounted) return;
      setState(() {
        business = result;
        isOpen = result.status == 'active';
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

  @override
  Widget build(BuildContext context) => SafeArea(
        child: RefreshIndicator(
          color: brandRed,
          onRefresh: _loadBusiness,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Heading('Toko & Bisnis', 'Identitas dan pengaturan toko'),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: brandRed),
                  ),
                )
              else if (error != null)
                _ErrorState(message: error!, onRetry: _loadBusiness)
              else if (business != null) ...[
                // ===== PROFIL TOKO =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/branding/Fresh Poultry Processing Showcase.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Container(color: deepRed),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        ink.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 14,
                                  bottom: 14,
                                  child: Row(
                                    children: [
                                      Icon(Icons.image_outlined,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'BRANDING TOKO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: line),
                                  ),
                                  child: Image.asset(
                                    'assets/branding/sauri_logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.storefront,
                                      color: brandRed,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                if (business!.isVerified)
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        gradient: brandGradient,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    business!.businessName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          color: brandRed, size: 11),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          business!.locationDisplay,
                                          style: const TextStyle(
                                              fontSize: 11, color: muted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  if (business!.isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: brandGradient,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified,
                                              color: Colors.white, size: 11),
                                          SizedBox(width: 4),
                                          Text(
                                            'TERVERIFIKASI AHU & OSS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== INFO BISNIS =====
                const Heading('Info Bisnis', 'Data dari OSS & AHU'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Panel(
                    accent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (business!.legalName != null) ...[
                          _InfoRow(
                            icon: Icons.business_rounded,
                            label: 'Badan Usaha',
                            value: business!.legalName!,
                          ),
                          const Divider(height: 24, color: line),
                        ],
                        if (business!.nib != null) ...[
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'NIB (Nomor Induk Berusaha)',
                            value: business!.nib!,
                          ),
                          const Divider(height: 24, color: line),
                        ],
                        if (business!.taxNumber != null) ...[
                          _InfoRow(
                            icon: Icons.credit_card_outlined,
                            label: 'NPWP',
                            value: business!.taxNumber!,
                          ),
                          const Divider(height: 24, color: line),
                        ],
                        if (business!.address != null) ...[
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat Kantor',
                            value: business!.address!,
                          ),
                          const Divider(height: 24, color: line),
                        ],
                        if (business!.phone != null) ...[
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Telepon',
                            value: business!.phone!,
                          ),
                          const Divider(height: 24, color: line),
                        ],
                        if (business!.email != null)
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: business!.email!,
                          ),
                      ],
                    ),
                  ),
                ),

                // ===== KBLI =====
                if (business!.kbliList.isNotEmpty) ...[
                  Heading('KBLI 2025',
                      '${business!.kbliList.length} kode klasifikasi usaha'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: business!.kbliList.map((kbli) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kbli.isPrimary
                                    ? brandRed.withValues(alpha: 0.3)
                                    : line,
                              ),
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
                                    width: 4,
                                    decoration: const BoxDecoration(
                                      gradient: brandGradient,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 12, 14, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: brandGradient,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          kbli.code,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kbli.name,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: ink,
                                                height: 1.3,
                                              ),
                                            ),
                                            if (kbli.isPrimary) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: gold
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: gold
                                                          .withValues(
                                                              alpha: 0.4)),
                                                ),
                                                child: const Text(
                                                  'UTAMA',
                                                  style: TextStyle(
                                                    color: goldDeep,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // ===== STATUS OPERASIONAL =====
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Panel(
                    accent: isOpen,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isOpen,
                      activeThumbColor: brandRed,
                      title: const Text(
                        'Status operasional',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                          isOpen ? 'Toko buka' : 'Toko tutup'),
                      onChanged: (v) => setState(() => isOpen = v),
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  business != null
                      ? '✅ Data legal terverifikasi dari OSS & AHU. Hubungi admin untuk perubahan.'
                      : 'Memuat data dari server...',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: brandRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: brandRed, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: muted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: ink,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
              child: const Icon(Icons.cloud_off_rounded,
                  color: brandRed, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data bisnis',
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