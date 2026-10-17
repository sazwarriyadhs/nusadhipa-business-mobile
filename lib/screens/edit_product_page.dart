import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descController;

  String? _selectedCategory;
  bool _submitting = false;

  static const categories = [
    ('daging-unggas', 'Daging & Unggas'),
    ('ikan-seafood', 'Ikan & Seafood'),
    ('sembako', 'Sembako'),
    ('minuman', 'Minuman'),
    ('makanan-olahan', 'Makanan Olahan'),
    ('pakan-ternak', 'Pakan Ternak'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.minPrice.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.product.availableStock.toString(),
    );
    _descController = TextEditingController(
      text: widget.product.shortDescription ?? '',
    );
    _selectedCategory = widget.product.categorySlug.isNotEmpty
        ? widget.product.categorySlug
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await ApiService().updateProduct(
        publicId: widget.product.publicId,
        name: _nameController.text,
        price: double.parse(_priceController.text.replaceAll('.', '')),
        stock: int.parse(_stockController.text),
        description: _descController.text.isEmpty
            ? null
            : _descController.text,
        categorySlug: _selectedCategory,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Produk berhasil diupdate!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.message}'),
          backgroundColor: brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text(
          'Produk "${widget.product.name}" akan dihapus dari katalog. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: brandRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);

    try {
      await ApiService().deleteProduct(widget.product.publicId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Produk berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.message}'),
          backgroundColor: brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.resolveImageUrl(widget.product.imageUrl);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Edit Produk',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Foto produk
            const Text(
              'Foto produk',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: line),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.inventory_2_outlined,
                            color: muted, size: 48),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          color: muted, size: 48),
                    ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Untuk ganti foto, upload dari tab Tambah Produk dengan nama sama.',
              style: TextStyle(fontSize: 10, color: muted, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),

            _Field(
              controller: _nameController,
              label: 'Nama produk',
              hint: 'Contoh: Ikan Tongkol Segar',
              icon: Icons.inventory_2_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            _Field(
              controller: _priceController,
              label: 'Harga (Rp)',
              hint: 'Contoh: 40000',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Harga tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _Field(
              controller: _stockController,
              label: 'Stok tersedia',
              hint: 'Contoh: 100',
              icon: Icons.warehouse_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Stok tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _Field(
              controller: _descController,
              label: 'Deskripsi singkat (opsional)',
              hint: 'Deskripsi produk...',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text(
                    'Pilih kategori...',
                    style: TextStyle(fontSize: 13, color: muted),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.$1,
                            child: Text(c.$2),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol hapus
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : _delete,
                icon: const Icon(Icons.delete_outline,
                    color: brandRed, size: 20),
                label: const Text(
                  'Hapus Produk',
                  style: TextStyle(
                    color: brandRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: brandRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: muted),
            prefixIcon: Icon(icon, color: brandRed, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: brandRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}