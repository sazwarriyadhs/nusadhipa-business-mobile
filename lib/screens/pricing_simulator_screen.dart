import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_provider.dart';
import '../services/pricing_calculator.dart';

class PricingSimulatorScreen extends StatefulWidget {
  const PricingSimulatorScreen({super.key});

  @override
  State<PricingSimulatorScreen> createState() => _PricingSimulatorScreenState();
}

class _PricingSimulatorScreenState extends State<PricingSimulatorScreen> {
  final TextEditingController _targetNetController = TextEditingController(text: '48000');
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<PaymentProvider> _providers = [
    PaymentProvider(id: 1, code: 'xendit_va_bca', name: 'Xendit VA BCA', feeType: 'percentage', feePercentage: 0.007, feeFlat: 0, taxPercentage: 0.11),
    PaymentProvider(id: 2, code: 'xendit_qris', name: 'Xendit QRIS', feeType: 'percentage', feePercentage: 0.007, feeFlat: 0, taxPercentage: 0.11),
    PaymentProvider(id: 3, code: 'midtrans_va_bca', name: 'Midtrans VA BCA', feeType: 'flat', feePercentage: 0.0, feeFlat: 4000, taxPercentage: 0.11),
  ];

  PaymentProvider? _selectedProvider;
  PricingResult? _result;

  @override
  void initState() {
    super.initState();
    _selectedProvider = _providers[1]; // Default QRIS
    _calculate();
  }

  void _calculate() {
    final target = int.tryParse(_targetNetController.text) ?? 0;
    if (target <= 0 || _selectedProvider == null) return;

    final res = PricingCalculator.calculate(
      targetNet: target,
      commissionRate: 0.02,
      commissionPpnRate: 0.11,
      feePercentage: _selectedProvider!.feePercentage,
      feeFlat: _selectedProvider!.feeFlat,
      taxPercentage: _selectedProvider!.taxPercentage,
    );

    setState(() {
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simulasi Harga Jual')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _targetNetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Bersih Diinginkan (Rp)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculate(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<PaymentProvider>(
              initialValue: _selectedProvider,
              decoration: InputDecoration(labelText: 'Metode Pembayaran', border: OutlineInputBorder()),
              items: _providers.map((p) {
                return DropdownMenuItem(value: p, child: Text(p.name));
              }).toList(),
              onChanged: (val) {
                setState(() { _selectedProvider = val; });
                _calculate();
              },
            ),
            SizedBox(height: 24),
            if (_result != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Harga Jual ke Pembeli', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text(_currencyFormat.format(_result!.sellingPrice), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('Rincian Biaya:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _row('Komisi Platform (2%)', _result!.commission + _result!.commissionPpn),
              _row('Biaya Payment Gateway', _result!.paymentFee + _result!.paymentPpn),
              _row('PPN', _result!.commissionPpn + _result!.paymentPpn),
              Divider(),
              _row('Harga Bersih Anda', _result!.tenantNet, isBold: true),
            ]
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(_currencyFormat.format(amount), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
