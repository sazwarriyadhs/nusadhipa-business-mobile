import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../services/api_service.dart';
import '../widgets/heading.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String search = '';
  bool loading = true;
  String? error;
  List<Product> products = [];
  Business? _business;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      Business? biz;
      try {
        biz = await ApiService().getMyBusiness();
      } catch (_) {
        biz = null;
      }

      final result = await ApiService().getProducts(
        limit: 100,
        businessSlug: biz?.slug,
      );

      if (!mounted) return;
      setState(() {
        _business = biz;
        products = result;
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
  Widget build(BuildContext context) {
    final result = products
        .where((p) =>
            p.name.toLowerCase().contains(search.toLowerCase()) ||
            p.categoryName.toLowerCase().contains(search.toLowerCase()) ||
            p.businessName.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Heading(
                'Produk',
                _business != null
                    ? 'Katalog ${_business!.businessName}'
                    : 'Katalog live dari marketplace',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: line),
                    boxShadow: [
                      BoxShadow(
                        color: brandRed.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: InputDecoration(
                      hintText: 'Cari produk atau kategori...',
                      hintStyle: const TextStyle(fontSize: 13, color: muted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: brandRed, size: 22),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? _buildError()
                        : _buildList(result),
              ),
            ],
          ),
        ),
        // TOMBOL TAMBAH PRODUK
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
              if (res == true) _loadProducts();
            },
            backgroundColor: brandRed,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: brandRed, size: 48),
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(backgroundColor: brandRed),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Product> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Belum ada produk', style: TextStyle(fontSize: 14)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: brandRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Katalog (${items.length} produk)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final product = items[index - 1];
          return _ProductTile(product: product, onRefresh: _loadProducts);
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onRefresh;
  const _ProductTile({required this.product, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.resolveImageUrl(product.imageUrl);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Produk'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    // BUKA HALAMAN EDIT
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(product: product),
                      ),
                    );
                    if (res == true) onRefresh();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Hapus Produk'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Hapus Produk?'),
                        content: Text('Yakin ingin menghapus ${product.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true), 
                            child: const Text('Hapus', style: TextStyle(color: Colors.red))
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ApiService().deleteProduct(product.publicId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Produk dihapus')),
                          );
                          onRefresh();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('❌ Gagal hapus: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: brandRed.withValues(alpha: 0.08),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_outlined,
                          color: brandRed,
                        ),
                      )
                    : const Icon(Icons.image_outlined, color: brandRed),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName,
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.minPrice}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: brandRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
