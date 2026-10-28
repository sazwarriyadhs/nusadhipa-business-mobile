class Produk {
  final String id;
  final String nama;
  final String deskripsi;
  final int harga;
  final String kategori;
  final String gambar;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.gambar,
  });
}

final List<Produk> listProduk = [
  Produk(id: "01", nama: "Jahe Rempah Stamina", deskripsi: "Daya tahan tubuh, masuk angin, linu, sperma, ginjal, hati, kejantanan", harga: 14000, kategori: "Menu Best Seller", gambar: "assets/products/jahe_rempah/01_Jahe_Rempah_Stamina.jpg"),
  Produk(id: "02", nama: "Jahe Rempah Sereh", deskripsi: "Kulit, bau badan, anti bakteri, daya tahan tubuh.", harga: 12000, kategori: "Menu Best Seller", gambar: "assets/products/jahe_rempah/02_Jahe_Rempah_Sereh.jpg"),
  Produk(id: "03", nama: "Jahe Rempah Temulawak", deskripsi: "Stamina, kesuburan, ginjal, hati, nafsu makan, pegal-pegal.", harga: 12000, kategori: "Menu Best Seller", gambar: "assets/products/jahe_rempah/03_Jahe_Rempah_Temulawak.jpg"),
  Produk(id: "04", nama: "Jahe Rempah Kencur", deskripsi: "Diet, lambung, pencernaan, kolesterol.", harga: 12000, kategori: "Menu Best Seller", gambar: "assets/products/jahe_rempah/04_Jahe_Rempah_Kencur.jpg"),
  Produk(id: "05", nama: "Jahe Rempah Kunyit", deskripsi: "Diet, lambung, pencernaan, kolesterol.", harga: 12000, kategori: "Menu Best Seller", gambar: "assets/products/jahe_rempah/05_Jahe_Rempah_Kunyit.jpg"),
  Produk(id: "06", nama: "Jahe Rempah Secang Susu", deskripsi: "Mencegah sel-sel kanker, memperlancar aliran tubuh.", harga: 15000, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/06_Jahe_Rempah_Secang_Susu.jpg"),
  Produk(id: "07", nama: "Jahe Rempah Kunyit Kencur", deskripsi: "Batuk, pilek, radang pencernaan, sakit kepala.", harga: 13500, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/07_Jahe_Rempah_Kunyit_Kencur.jpg"),
  Produk(id: "08", nama: "Jahe Rempah Lambung", deskripsi: "Pencernaan, asam lambung, nyeri haid.", harga: 13500, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/08_Jahe_Rempah_Lambung.jpg"),
  Produk(id: "09", nama: "Jahe Rempah Detox Rahim", deskripsi: "Kesuburan, keputihan, mengencangkan otot rahim.", harga: 14000, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/09_Jahe_Rempah_Detox_Rahim.jpg"),
  Produk(id: "10", nama: "Jahe Rempah Detox Sperma", deskripsi: "Memperbaiki kualitas sperma.", harga: 17000, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/10_Jahe_Rempah_Detox_Sperma.jpg"),
  Produk(id: "11", nama: "Jahe Rempah Komplit + Telur", deskripsi: "Segala jenis penyakit.", harga: 22000, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/11_Jahe_Rempah_Komplit_Telur.jpg"),
  Produk(id: "12", nama: "Jahe Rempah Komplit", deskripsi: "Segala jenis penyakit.", harga: 17000, kategori: "Menu Spesial", gambar: "assets/products/jahe_rempah/12_Jahe_Rempah_Komplit.jpg"),
  Produk(id: "13", nama: "STMJ (Susu Telur Madu Jahe)", deskripsi: "Stamina, daya tahan, pernapasan.", harga: 15000, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/13_STMJ_Susu_Telur_Madu_Jahe.jpg"),
  Produk(id: "14", nama: "Jahe Merah Susu", deskripsi: "Netralisir racun dalam tubuh dan imunitas.", harga: 12500, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/14_Jahe_Merah_Susu.jpg"),
  Produk(id: "15", nama: "Wedang Uwuh Jogja", deskripsi: "Melancarkan peredaran darah, imunitas, masuk angin dan mual.", harga: 15000, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/15_Wedang_Uwuh_Jogja.jpg"),
  Produk(id: "16", nama: "Wedang Jahe Sereh Madu", deskripsi: "Memperbaiki sel kulit mati, jerawat, bau badan.", harga: 12000, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/16_Wedang_Jahe_Sereh_Madu.jpg"),
  Produk(id: "17", nama: "Wedang Jahe Original", deskripsi: "Imunitas, masuk angin, pegal-pegal", harga: 12500, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/17_Wedang_Jahe_Original.jpg"),
  Produk(id: "18", nama: "Bandrek Susu", deskripsi: "Menjaga imunitas, masuk angin, netralisir racun.", harga: 13000, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/18_Bandrek_Susu.jpg"),
  Produk(id: "19", nama: "Jahe Susu Jogja", deskripsi: "Mentralisit racun dan imunitas.", harga: 12500, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/19_Jahe_Susu_Jogja.jpg"),
  Produk(id: "20", nama: "Jahe Merah Temulawak Madu", deskripsi: "-", harga: 13500, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/20_Jahe_Merah_Temulawak_Madu.jpg"),
  Produk(id: "21", nama: "Jahe Merah Gula Aren", deskripsi: "Menjaga imunitas tubuh, fungsi otak, pegal-pegal.", harga: 12000, kategori: "Wedang & Jahe Merah", gambar: "assets/products/jahe_rempah/21_Jahe_Merah_Gula_Aren.jpg"),
  Produk(id: "22", nama: "Pisang Bakar Keju Coklat", deskripsi: "-", harga: 17000, kategori: "Cemilan", gambar: "assets/products/jahe_rempah/22_Pisang_Bakar_Keju_Coklat.jpg"),
  Produk(id: "23", nama: "Pisang Bakar Keju", deskripsi: "-", harga: 13000, kategori: "Cemilan", gambar: "assets/products/jahe_rempah/23_Pisang_Bakar_Keju.jpg"),
  Produk(id: "24", nama: "Pisang Bakar Coklat", deskripsi: "Pisang bakar lezat dengan coklat lembut, camilan manis penuh kehangatan.", harga: 13000, kategori: "Cemilan", gambar: "assets/products/jahe_rempah/24_Pisang_Bakar_Coklat.jpg"),
  Produk(id: "25", nama: "Pisang Bakar Keju Coklat Susu Tambahan", deskripsi: "-", harga: 0, kategori: "Cemilan", gambar: "assets/products/jahe_rempah/25_Pisang_Bakar_Keju_Coklat_Susu_Tambahan.jpg"),
];
