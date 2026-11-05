import 'dart:math';

class PricingResult {
  final int targetNet;
  final int sellingPrice;
  final int commission;
  final int commissionPpn;
  final int paymentFee;
  final int paymentPpn;
  final int pph23;
  final int tenantNet;
  final int roundingAdjustment;

  PricingResult({
    required this.targetNet,
    required this.sellingPrice,
    required this.commission,
    required this.commissionPpn,
    required this.paymentFee,
    required this.paymentPpn,
    required this.pph23,
    required this.tenantNet,
    required this.roundingAdjustment,
  });
}

class PricingCalculator {
  static PricingResult calculate({
    required int targetNet,
    required double commissionRate,
    required double commissionPpnRate,
    required double feePercentage,
    required int feeFlat,
    required double taxPercentage,
    double pph23Rate = 0,
  }) {
    final cEff = commissionRate * (1 + commissionPpnRate);
    final fEff = feePercentage * (1 + taxPercentage);
    final fFlatEff = feeFlat * (1 + taxPercentage);
    final p23Eff = pph23Rate;

    final rawSellingPrice = (targetNet + fFlatEff) / (1 - cEff - fEff - p23Eff);
    final sellingPrice = rawSellingPrice.ceil();

    final commission = (sellingPrice * commissionRate).floor();
    final commissionPpn = (sellingPrice * commissionRate * commissionPpnRate).floor();
    final paymentFee = (sellingPrice * feePercentage).floor() + feeFlat;
    final paymentPpn = (sellingPrice * feePercentage * taxPercentage).floor() + (feeFlat * taxPercentage).floor();
    final pph23 = (sellingPrice * pph23Rate).floor();

    var tenantNet = sellingPrice - commission - commissionPpn - paymentFee - paymentPpn - pph23;
    var roundingAdjustment = 0;

    if (tenantNet < targetNet) {
      roundingAdjustment = targetNet - tenantNet;
      tenantNet = targetNet;
    }

    return PricingResult(
      targetNet: targetNet,
      sellingPrice: sellingPrice,
      commission: commission,
      commissionPpn: commissionPpn,
      paymentFee: paymentFee,
      paymentPpn: paymentPpn,
      pph23: pph23,
      tenantNet: tenantNet,
      roundingAdjustment: roundingAdjustment,
    );
  }
}
