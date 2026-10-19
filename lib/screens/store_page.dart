import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/business.dart';
import '../services/api_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Business? _business;
  bool _loading = true;
  bool _uploading = false;
  File? _newLogo;
  File? _newCover;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final biz = await ApiService().getMyBusiness();
      if (mounted) setState(() { _business = biz; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isLogo) _newLogo = File(picked.path);
        else _newCover = File(picked.path);
      });
      _uploadImage(isLogo);
    }
  }

  Future<void> _uploadImage(bool isLogo) async {
    if (_business == null) return;
    final file = isLogo ? _newLogo : _newCover;
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      if (isLogo) {
        await ApiService().uploadLogo(file);
      } else {
        await ApiService().uploadBanner(file);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${isLogo ? "Logo" : "Cover"} berhasil diupdate!')),
        );
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal upload: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_business == null) return const Center(child: Text('Gagal load data toko'));

    final coverUrl = ApiConfig.resolveImageUrl(_business!.bannerUrl);
    final logoUrl = ApiConfig.resolveImageUrl(_business!.logoUrl);

    return Scaffold(
      backgroundColor: canvas,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== COVER FULL =====
            GestureDetector(
              onTap: _uploading ? null : () => _pickImage(false),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      image: DecorationImage(
                        image: _newCover != null
                            ? FileImage(_newCover!)
                            : (coverUrl != null ? NetworkImage(coverUrl) : const AssetImage('assets/placeholder.png')) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Ganti Cover', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== LOGO & NAMA TOKO =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _uploading ? null : () => _pickImage(true),
                          child: Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                              image: DecorationImage(
                                image: _newLogo != null
                                    ? FileImage(_newLogo!)
                                    : (logoUrl != null ? NetworkImage(logoUrl) : const AssetImage('assets/placeholder.png')) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                radius: 14, backgroundColor: Colors.black54,
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _business!.businessName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.2),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: brandRed, size: 14),
                                    const SizedBox(width: 4),
                                    Text('${_business!.city}, ${_business!.province}', style: const TextStyle(fontSize: 12, color: muted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: brandRed, size: 14),
                          SizedBox(width: 4),
                          Text('TERVERIFIKASI AHU & OSS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: brandRed)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // INFO NIB & NPWP
                    Text('NIB: ${_business!.nib ?? '-'}   NPWP: ${_business!.taxNumber ?? '-'}', style: const TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 16),

                    // TOMBOL AKSI
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openWhatsApp(_business!.phone ?? ''),
                            icon: const Icon(Icons.chat, size: 16),
                            label: const Text('Chat WhatsApp'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Telepon'),
                            style: OutlinedButton.styleFrom(foregroundColor: ink),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('Follow'),
                            style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ===== CARD STATISTIK =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(Icons.inventory_2, '0', 'PRODUK'),
                  const SizedBox(width: 8),
                  _buildStatCard(Icons.category, '0', 'KATEGORI'),
                  const SizedBox(width: 8),
                  _buildStatCard(Icons.verified, 'Verified', 'STATUS'),
                  const SizedBox(width: 8),
                  _buildStatCard(Icons.storefront, _business!.businessType.toUpperCase(), 'TIPE USAHA'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // ===== INFO BISNIS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Info Bisnis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
                    child: Column(
                      children: [
                        _buildInfoRow('Badan Usaha', _business!.legalName ?? '-'),
                        const Divider(),
                        _buildInfoRow('NIB', _business!.nib ?? '-'),
                        const Divider(),
                        _buildInfoRow('Alamat', _business!.address ?? '-'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
        child: Column(
          children: [
            Icon(icon, color: brandRed, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 9, color: muted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: muted))),
        Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }
}

