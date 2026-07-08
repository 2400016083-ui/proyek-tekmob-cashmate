import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/models/transaction_model.dart';
import '../../core/widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

enum _TransactionFilter { all, income, expense }

const _indonesianMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  _TransactionFilter _filter = _TransactionFilter.all;
  String _query = '';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameDay(date, now)) return 'Hari Ini';
    if (_sameDay(date, yesterday)) return 'Kemarin';
    return '${date.day} ${_indonesianMonths[date.month - 1]} ${date.year}';
  }

  List<TransactionModel> _filtered(List<TransactionModel> source) {
    return source.where((t) {
      final matchesFilter = switch (_filter) {
        _TransactionFilter.all => true,
        _TransactionFilter.income => t.type == TransactionType.income,
        _TransactionFilter.expense => t.type == TransactionType.expense,
      };
      final matchesQuery =
          _query.isEmpty || t.title.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Map<String, List<TransactionModel>> _grouped(List<TransactionModel> source) {
    final map = <String, List<TransactionModel>>{};
    for (final t in _filtered(source)) {
      map.putIfAbsent(_dateLabel(t.date), () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Cari Transaksi',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    selected: _filter == _TransactionFilter.all,
                    onTap: () => setState(() => _filter = _TransactionFilter.all),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Pemasukan',
                    selected: _filter == _TransactionFilter.income,
                    onTap: () =>
                        setState(() => _filter = _TransactionFilter.income),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Pengeluaran',
                    selected: _filter == _TransactionFilter.expense,
                    onTap: () =>
                        setState(() => _filter = _TransactionFilter.expense),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<TransactionModel>>(
                valueListenable: DummyData.transactionsNotifier,
                builder: (context, source, _) {
                  final grouped = _grouped(source);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final t in entry.value)
                          TransactionTile(transaction: t),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
