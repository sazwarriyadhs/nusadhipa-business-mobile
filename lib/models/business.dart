class Business {
  final String publicId;
  final String businessName;
  final String slug;
  final String? legalName;
  final String? nib;
  final String? npwp;
  final String? taxNumber;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? province;
  final String? logoUrl;
  final String? bannerUrl;
  final String businessType;
  final String? description;
  final int productCount;
  final String? kbliCode;
  final String? kbliName;
  final String? verificationStatus;
  final String? status;
  final double? latitude;
  final double? longitude;

  Business({
    required this.publicId,
    required this.businessName,
    required this.slug,
    this.legalName,
    this.nib,
    this.npwp,
    this.taxNumber,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.province,
    this.logoUrl,
    this.bannerUrl,
    required this.businessType,
    this.description,
    this.productCount = 0,
    this.kbliCode,
    this.kbliName,
    this.verificationStatus,
    this.status,
    this.latitude,
    this.longitude,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      publicId: json['public_id'] ?? '',
      businessName: json['business_name'] ?? '',
      slug: json['slug'] ?? '',
      legalName: json['legal_name'],
      nib: json['nib'],
      npwp: json['npwp'],
      taxNumber: json['tax_number'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      businessType: json['business_type'] ?? 'umkm',
      description: json['description'],
      productCount: json['product_count'] ?? 0,
      kbliCode: json['kbli_code'],
      kbliName: json['kbli_name'],
      verificationStatus: json['verification_status'],
      status: json['status'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  // ============================================================
  // GETTERS (Buat nampilin data di UI)
  // ============================================================
  
  String get locationDisplay {
    final parts = [city, province].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isEmpty ? 'Lokasi belum diisi' : parts.join(', ');
  }

  bool get isVerified => verificationStatus == 'verified';
  
  String get businessTypeDisplay {
    switch (businessType) {
      case 'umkm': return 'UMKM';
      case 'retailer': return 'Retailer';
      case 'supplier': return 'Supplier';
      case 'manufacturer': return 'Manufacturer';
      default: return businessType.toUpperCase();
    }
  }
}