class PaymentProvider {
  final int id;
  final String code;
  final String name;
  final String feeType;
  final double feePercentage;
  final int feeFlat;
  final double taxPercentage;

  PaymentProvider({
    required this.id,
    required this.code,
    required this.name,
    required this.feeType,
    required this.feePercentage,
    required this.feeFlat,
    required this.taxPercentage,
  });

  factory PaymentProvider.fromJson(Map<String, dynamic> json) {
    return PaymentProvider(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      feeType: json['fee_type'] ?? 'percentage',
      feePercentage: (json['fee_percentage'] ?? 0).toDouble(),
      feeFlat: json['fee_flat'] ?? 0,
      taxPercentage: (json['tax_percentage'] ?? 0).toDouble(),
    );
  }
}
