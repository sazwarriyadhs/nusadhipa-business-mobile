import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/financial_report.dart';
import '../../services/api_service.dart';
import '../../services/report_service.dart';

class FinancialReportPage extends StatefulWidget {
  final Business? business;

  const FinancialReportPage({super.key, required this.business});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  Uint8List? pdfBytes;
  bool loading = true;
  String? error;
  FinancialReport? report;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1. Fetch dari API
      final data = await ApiService().getFinancialReport();

      // 2. Generate PDF
      final bytes = await ReportService.generateFinancialReport(
        business: widget.business,
        report: data,
      );

      if (!mounted) return;
      setState(() {
        report = data;
        pdfBytes = bytes;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _share() async {
    if (pdfBytes == null) return;
    try {
      await Printing.sharePdf(
        bytes: pdfBytes!,
        filename:
            "Laporan-Keuangan-${DateTime.now().toIso8601String().substring(0, 10)}.pdf",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal share: $e")));
    }
  }

  Future<void> _print() async {
    if (pdfBytes == null) return;
    try {
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes!,
        name: "Laporan Keuangan",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal print: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Laporan Keuangan",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              "Ringkasan performa bisnis",
              style: TextStyle(
                fontSize: 11,
                color: muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (pdfBytes != null)
            IconButton(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded),
              tooltip: "Share",
            ),
        ],
      ),
      body: loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: brandRed),
                  SizedBox(height: 16),
                  Text(
                    "Membuat laporan...",
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            )
          : error != null
          ? _ErrorState(message: error!, onRetry: _generate)
          : Column(
              children: [
                if (report != null) _QuickSummary(report: report!),
                Expanded(
                  child: PdfPreview(
                    build: (_) async => pdfBytes!,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowSharing: false,
                    allowPrinting: false,
                    loadingWidget: const Center(
                      child: CircularProgressIndicator(color: brandRed),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                _ActionBar(
                  onShare: _share,
                  onPrint: _print,
                  onRegenerate: _generate,
                ),
              ],
            ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  final FinancialReport report;

  const _QuickSummary({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statCol(
              "PENDAPATAN",
              "Rp ${_fmt(report.summary.totalRevenue)}",
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _statCol("TOTAL ORDER", "${report.summary.totalOrders}"),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(child: _statCol("PRODUK", "${report.topProducts.length}")),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onRegenerate;

  const _ActionBar({
    required this.onShare,
    required this.onPrint,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Refresh"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: const BorderSide(color: line),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: brandRed.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onShare,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Download & Share",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: brandRed, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              "Gagal membuat laporan",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Coba lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
