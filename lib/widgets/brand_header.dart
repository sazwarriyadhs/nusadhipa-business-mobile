import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/business_type.dart';
import '../models/business.dart';
import '../services/api_service.dart';
import '../screens/location_map_page.dart';
import 'demo_message.dart';

class BrandHeader extends StatefulWidget {
  const BrandHeader({super.key});

  @override
  State<BrandHeader> createState() => _BrandHeaderState();
}

class _BrandHeaderState extends State<BrandHeader> {
  Business? business;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await ApiService().getMyBusiness();
      if (!mounted) return;
      setState(() {
        business = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeInfo = resolveBusinessType(business);

    return Column(
      children: [
        const _WhiteTopHeader(),
        _CoverHero(
          business: business,
          typeInfo: typeInfo,
          loading: loading,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _TenantCard(
            business: business,
            typeInfo: typeInfo,
            loading: loading,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TOP HEADER
// ============================================================
class _WhiteTopHeader extends StatelessWidget {
  const _WhiteTopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Image.asset(
                'assets/branding/logo_nusadhipa.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text(
                  'NUSA-DHIPA',
                  style: TextStyle(
                    color: brandRed,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: canvas,
                  shape: BoxShape.circle,
                  border: Border.all(color: line),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      demoMessage(context, 'Notifikasi demo belum terhubung.'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: ink,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COVER HERO — banner + overlay gradient + chip jenis usaha
// ============================================================
class _CoverHero extends StatelessWidget {
  final Business? business;
  final BusinessTypeInfo typeInfo;
  final bool loading;

  const _CoverHero({
    this.business,
    required this.typeInfo,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final customBanner = business?.bannerUrl;
    final useCustom = customBanner != null && customBanner.isNotEmpty;
    final imageUrl =
        useCustom ? customBanner : coverUrlForType(typeInfo);

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetworkCover(url: imageUrl, typeInfo: typeInfo),

          // Gradient overlay (bawah lebih gelap, atas transparan)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Chip jenis usaha (kanan atas)
          Positioned(
            top: 12,
            right: 12,
            child: _TypeChip(info: typeInfo),
          ),

          // Nama singkat di kiri bawah
          if (!loading && business != null)
            Positioned(
              left: 16,
              bottom: 14,
              right: 16,
              child: Text(
                business!.businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkCover extends StatelessWidget {
  final String url;
  final BusinessTypeInfo typeInfo;

  const _NetworkCover({required this.url, required this.typeInfo});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSyncLoaded) {
        if (wasSyncLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, _, _) => _FallbackCover(info: typeInfo),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  final BusinessTypeInfo info;
  const _FallbackCover({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: info.gradient),
      child: Center(
        child: Icon(
          info.icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: 64,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final BusinessTypeInfo info;
  const _TypeChip({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 12, color: info.accent),
          const SizedBox(width: 5),
          Text(
            info.label,
            style: TextStyle(
              color: info.accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TENANT CARD — logo, nama, badge verifikasi, lokasi tap-able
// ============================================================
class _TenantCard extends StatelessWidget {
  final Business? business;
  final BusinessTypeInfo typeInfo;
  final bool loading;

  const _TenantCard({
    this.business,
    required this.typeInfo,
    required this.loading,
  });

  void _openLocationMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationMapPage(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = business?.businessName ?? 'Toko Saya';
    final location = business?.locationDisplay ?? 'Lokasi belum diisi';
    final isVerified = business?.isVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo tenant — border accent sesuai jenis usaha
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: typeInfo.accent.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: business?.logoUrl != null
                      ? Image.network(
                          business!.logoUrl!.startsWith('http')
                              ? business!.logoUrl!
                              : 'https://api.nusadhipa.shop${business!.logoUrl}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            typeInfo.icon,
                            color: typeInfo.accent,
                            size: 32,
                          ),
                        )
                      : Icon(
                          typeInfo.icon,
                          color: typeInfo.accent,
                          size: 32,
                        ),
                ),
              ),
              if (isVerified)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge verifikasi
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: brandRed.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text(
                          'UMKM TERVERIFIKASI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),

                // Nama toko
                Text(
                  loading ? 'Memuat...' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),

                // Lokasi — tap untuk buka peta
                InkWell(
                  onTap: () => _openLocationMap(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: typeInfo.accent,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: typeInfo.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  typeInfo.accent.withValues(alpha: 0.3),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.open_in_new,
                          color: typeInfo.accent,
                          size: 10,
                        ),
                      ],
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