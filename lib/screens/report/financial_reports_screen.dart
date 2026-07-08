import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/models/transaction_model.dart';
import '../../core/services/pdf_export_service.dart';
import '../../core/utils/report_calculator.dart';
import '../../core/widgets/chart_card.dart';
import '../../core/widgets/summary_card.dart';

const _monthFullNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember', //
];

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  DateTime? _selectedMonth;
  bool _isExporting = false;

  List<DateTime> _availableMonths(List<TransactionModel> transactions) {
    final months = <DateTime>{
      for (final t in transactions) DateTime(t.date.year, t.date.month),
    };
    // Always offer at least the last 6 months so the dropdown doesn't look
    // sparse even if only a couple of months actually have transactions.
    final now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      months.add(DateTime(now.year, now.month - i));
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Defaults to the month of the most recently dated transaction (so a
  /// freshly added/scanned transaction shows up immediately) instead of
  /// always jumping to today's real calendar month, which may have no
  /// transactions at all if e.g. a scanned receipt is dated earlier.
  DateTime _defaultMonth(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    final latest =
        transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);
    return DateTime(latest.year, latest.month);
  }

  Future<void> _exportPdf(
    FinancialReport report,
    List<TransactionModel> transactionsInMonth,
  ) async {
    setState(() => _isExporting = true);
    try {
      await PdfExportService().exportFinancialReport(
        report: report,
        transactionsInMonth: transactionsInMonth,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat PDF, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: SafeArea(
        child: ValueListenableBuilder<List<TransactionModel>>(
          valueListenable: DummyData.transactionsNotifier,
          builder: (context, transactions, _) {
            final availableMonths = _availableMonths(transactions);
            final selectedMonth = _selectedMonth ?? _defaultMonth(transactions);
            final report = calculateMonthlyReport(transactions, selectedMonth);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<DateTime>(
                  initialValue: selectedMonth,
                  items: [
                    for (final month in availableMonths)
                      DropdownMenuItem(
                        value: month,
                        child: Text(
                          '${_monthFullNames[month.month - 1]} ${month.year}',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedMonth = value);
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Pemasukan',
                        amount: report.income,
                        percent: report.incomePercent,
                        backgroundColor: AppColors.primaryLight,
                        bordered: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        label: 'Pengeluaran',
                        amount: report.expense,
                        percent: report.expensePercent,
                        backgroundColor: const Color(0xFFFCE8E8),
                        labelColor: AppColors.expense,
                        bordered: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  label: 'Laba Bersih',
                  amount: report.profit,
                  percent: report.profitPercent,
                  backgroundColor: AppColors.primaryLight,
                  bordered: false,
                  trailing: const SizedBox(
                    width: 90,
                    height: 40,
                    child: MiniSparkline(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Pengeluaran Berdasarkan Kategori',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (report.categoryBreakdown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Belum ada pengeluaran di bulan ini.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  )
                else
                  Row(
                    children: [
                      CategoryDonutChart(data: report.categoryBreakdown),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            for (final item in report.categoryBreakdown)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: item.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${item.percent.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pemasukan dan Pengeluaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _LegendDot(color: AppColors.income, label: 'Pemasukan'),
                        SizedBox(width: 10),
                        _LegendDot(color: AppColors.expense, label: 'Pengeluaran'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MonthlyBarChart(data: report.monthlyChart),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isExporting
                        ? null
                        : () => _exportPdf(
                              report,
                              transactionsForMonth(transactions, selectedMonth),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                      'Ekspor PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
