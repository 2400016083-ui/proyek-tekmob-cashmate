import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../models/user_model.dart';

class CategoryBreakdown {
  final String label;
  final double percent;
  final Color color;

  const CategoryBreakdown({
    required this.label,
    required this.percent,
    required this.color,
  });
}

class MonthlyChartPoint {
  final String month;
  final double income;
  final double expense;

  const MonthlyChartPoint({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class FinancialReport {
  final String period;
  final double income;
  final double incomePercent;
  final double expense;
  final double expensePercent;
  final double profit;
  final double profitPercent;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<MonthlyChartPoint> monthlyChart;

  const FinancialReport({
    required this.period,
    required this.income,
    required this.incomePercent,
    required this.expense,
    required this.expensePercent,
    required this.profit,
    required this.profitPercent,
    required this.categoryBreakdown,
    required this.monthlyChart,
  });
}

class DashboardSummary {
  final double totalBalance;
  final double balancePercent;
  final double income;
  final double incomePercent;
  final double expense;
  final double expensePercent;
  final double profit;
  final double profitPercent;

  const DashboardSummary({
    required this.totalBalance,
    required this.balancePercent,
    required this.income,
    required this.incomePercent,
    required this.expense,
    required this.expensePercent,
    required this.profit,
    required this.profitPercent,
  });
}

/// Central place for dummy/mock data. Every field is shaped the way a real
/// API response would be (typed amounts, ISO dates, id-based models) so the
/// screens can later be repointed at a real repository/API without changing
/// their widget code.
class DummyData {
  DummyData._();

  static final UserModel currentUser = const UserModel(
    id: 'u1',
    name: 'Arul Budiman',
    email: 'arul.budiman@cashmate.app',
    role: 'Small Business Owner',
    businessName: 'Toko Makanan & Minuman',
    isPremium: true,
  );

  static const DashboardSummary dashboardSummary = DashboardSummary(
    totalBalance: 12450000,
    balancePercent: 19.5,
    income: 17500000,
    incomePercent: 15.2,
    expense: 6300000,
    expensePercent: -9.4,
    profit: 12450000,
    profitPercent: 16.6,
  );

  static const List<String> incomeCategories = [
    'Penjualan Produk',
    'Pemasukan Cabang',
    'Pemasukan Lainnya',
  ];

  static const List<String> expenseCategories = [
    'Bahan Baku',
    'Operasional',
    'Pemasaran',
    'Lainnya',
  ];

  static final DateTime _today = DateTime.now();
  static final DateTime _yesterday = _today.subtract(const Duration(days: 1));
  static final DateTime _fixedPastDate = DateTime(2026, 5, 20);

  /// Mutable so Add Transaksi / Scan Struk can insert new dummy entries and
  /// have the list screens reflect them immediately without a backend.
  /// Screens read [transactionsNotifier] so they rebuild automatically;
  /// use [addTransaction] instead of mutating [transactions] directly.
  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 't1',
      title: 'Penjualan Produk',
      category: 'Penjualan Produk',
      type: TransactionType.income,
      amount: 500000,
      date: DateTime(_today.year, _today.month, _today.day, 20, 30),
    ),
    TransactionModel(
      id: 't2',
      title: 'Pembelian Bahan Pokok',
      category: 'Bahan Baku',
      type: TransactionType.expense,
      amount: 200000,
      date: DateTime(_today.year, _today.month, _today.day, 18, 46),
    ),
    TransactionModel(
      id: 't3',
      title: 'Penjualan Produk',
      category: 'Penjualan Produk',
      type: TransactionType.income,
      amount: 350000,
      date: DateTime(_today.year, _today.month, _today.day, 16, 55),
    ),
    TransactionModel(
      id: 't4',
      title: 'Pembelian Token Listrik',
      category: 'Operasional',
      type: TransactionType.expense,
      amount: 150000,
      date: DateTime(_today.year, _today.month, _today.day, 14, 0),
    ),
    TransactionModel(
      id: 't5',
      title: 'Penjualan Produk',
      category: 'Penjualan Produk',
      type: TransactionType.income,
      amount: 450000,
      date: DateTime(_yesterday.year, _yesterday.month, _yesterday.day, 16, 55),
    ),
    TransactionModel(
      id: 't6',
      title: 'Pemasukan Cabang',
      category: 'Pemasukan Cabang',
      type: TransactionType.income,
      amount: 1450000,
      date: DateTime(_yesterday.year, _yesterday.month, _yesterday.day, 16, 55),
    ),
    TransactionModel(
      id: 't7',
      title: 'Perbaikan Alat Dapur',
      category: 'Operasional',
      type: TransactionType.expense,
      amount: 300000,
      date: DateTime(_yesterday.year, _yesterday.month, _yesterday.day, 16, 55),
    ),
    TransactionModel(
      id: 't8',
      title: 'Penjualan Produk',
      category: 'Penjualan Produk',
      type: TransactionType.income,
      amount: 450000,
      date: DateTime(_fixedPastDate.year, _fixedPastDate.month, _fixedPastDate.day, 12, 55),
    ),
    TransactionModel(
      id: 't9',
      title: 'Pemeliharaan Tempat',
      category: 'Operasional',
      type: TransactionType.expense,
      amount: 300000,
      date: DateTime(_fixedPastDate.year, _fixedPastDate.month, _fixedPastDate.day, 12, 55),
    ),
  ];

  static final ValueNotifier<List<TransactionModel>> transactionsNotifier =
      ValueNotifier(List.unmodifiable(transactions));

  static void addTransaction(TransactionModel transaction) {
    transactions.insert(0, transaction);
    transactionsNotifier.value = List.unmodifiable(transactions);
  }

  static final FinancialReport monthlyReport = FinancialReport(
    period: 'Mei 2025',
    income: 18750000,
    incomePercent: 15.2,
    expense: 6300000,
    expensePercent: -8.4,
    profit: 12450000,
    profitPercent: 18.6,
    categoryBreakdown: const [
      CategoryBreakdown(label: 'Pemasaran', percent: 50, color: Color(0xFFDC2626)),
      CategoryBreakdown(label: 'Bahan Baku', percent: 35, color: Color(0xFF16A34A)),
      CategoryBreakdown(label: 'Operasional', percent: 15, color: Color(0xFF3B82F6)),
    ],
    monthlyChart: const [
      MonthlyChartPoint(month: 'Jan', income: 3000000, expense: 1800000),
      MonthlyChartPoint(month: 'Feb', income: 3200000, expense: 1600000),
      MonthlyChartPoint(month: 'Mar', income: 2600000, expense: 1700000),
      MonthlyChartPoint(month: 'Apr', income: 2800000, expense: 1500000),
      MonthlyChartPoint(month: 'Mei', income: 4200000, expense: 1900000),
    ],
  );

  static const List<String> availableMonths = ['Mei 2025', 'April 2025'];
}
