import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/transaction_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/transaction_service.dart';
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

  List<DateTime> _availableMonths(List<TransactionModel> transactions) {
    final months = <DateTime>{
      for (final t in transactions) DateTime(t.date.year, t.date.month),
    };
    if (months.isEmpty) {
      final now = DateTime.now();
      months.add(DateTime(now.year, now.month));
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: TransactionService().watchTransactions(uid),
          builder: (context, snapshot) {
            final transactions = snapshot.data ?? const <TransactionModel>[];
            final availableMonths = _availableMonths(transactions);
            final selectedMonth = _selectedMonth ?? availableMonths.first;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pemasukan dan Pengeluaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur ekspor PDF akan segera hadir')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
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
