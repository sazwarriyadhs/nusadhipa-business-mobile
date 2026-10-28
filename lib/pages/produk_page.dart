import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/produk_model.dart'; // Pastikan path ini sesuai struktur folder lo

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  String _selectedKategori = 'Semua';
  
  // Daftar kategori untuk filter
  final List<String> _kategoriList = [
    'Semua', 
    'Menu Best Seller', 
    'Menu Spesial', 
    'Wedang & Jahe Merah', 
    'Cemilan'
  ];

  // Helper buat format Rupiah
  String _formatRupiah(int harga) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan kategori yang dipilih
    final filteredProduk = _selectedKategori == 'Semua'
        ? listProduk
        : listProduk.where((p) => p.kategori == _selectedKategori).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          // --- Bagian Filter Kategori ---
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriList[index];
                final isSelected = _selectedKategori == kategori;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedKategori = kategori;
                      });
                    },
                    selectedColor: Colors.red.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.red.shade900 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Bagian Grid Produk ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72, // Disesuaikan biar gambar dan teks muat
              ),
              itemCount: filteredProduk.length,
              itemBuilder: (context, index) {
                final produk = filteredProduk[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Produk
                      Expanded(
                        child: Image.asset(
                          produk.gambar,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      // Info Produk
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRupiah(produk.harga),
                              style: const TextStyle(
                                color: Color(0xFFE5232E), // Warna merah NUSA-DHIPA
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
