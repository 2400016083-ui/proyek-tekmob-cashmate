import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../data/dummy_data.dart'
    show DashboardSummary, FinancialReport, CategoryBreakdown, MonthlyChartPoint;
import '../models/transaction_model.dart';

/// Fixed category -> color mapping so a given category always renders with
/// the same color regardless of how many other categories appear in a given
/// month (rather than assigning colors purely by rank, which made colors
/// shift/disappear as the set of categories changed).
const _categoryColors = <String, Color>{
  'Bahan Baku': Color(0xFF16A34A),
  'Operasional': Color(0xFF3B82F6),
  'Pemasaran': Color(0xFFDC2626),
  'Lainnya': Color(0xFFF59E0B),
};

Color _colorForCategory(String category, int fallbackIndex) {
  return _categoryColors[category] ??
      AppColors.chartPalette[fallbackIndex % AppColors.chartPalette.length];
}

const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des', //
];

const _monthFull = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember', //
];

/// All transactions (income and expense) dated within [month].
List<TransactionModel> transactionsForMonth(
  List<TransactionModel> all,
  DateTime month,
) {
  final (start, end) = _monthRange(month);
  return all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
      .toList();
}

(DateTime, DateTime) _monthRange(DateTime month) {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);
  return (start, end);
}

double _sumByType(
  List<TransactionModel> transactions,
  TransactionType type,
  DateTime start,
  DateTime end,
) {
  return transactions
      .where((t) =>
          t.type == type && !t.date.isBefore(start) && t.date.isBefore(end))
      .fold(0.0, (sum, t) => sum + t.amount);
}

double _percentChange(double current, double previous) {
  if (previous == 0) return current == 0 ? 0 : 100;
  return ((current - previous) / previous) * 100;
}

/// Computes the Dashboard summary (total balance + this-month vs last-month
/// income/expense/profit) from the full transaction list.
DashboardSummary calculateDashboardSummary(List<TransactionModel> all) {
  final now = DateTime.now();
  final (curStart, curEnd) = _monthRange(now);
  final (prevStart, prevEnd) =
      _monthRange(DateTime(now.year, now.month - 1, 1));

  final income = _sumByType(all, TransactionType.income, curStart, curEnd);
  final prevIncome =
      _sumByType(all, TransactionType.income, prevStart, prevEnd);
  final expense = _sumByType(all, TransactionType.expense, curStart, curEnd);
  final prevExpense =
      _sumByType(all, TransactionType.expense, prevStart, prevEnd);
  final profit = income - expense;
  final prevProfit = prevIncome - prevExpense;

  final totalBalance = all.fold<double>(
    0,
    (sum, t) =>
        sum + (t.type == TransactionType.income ? t.amount : -t.amount),
  );
  final balanceLastMonth = totalBalance - profit;

  return DashboardSummary(
    totalBalance: totalBalance,
    balancePercent: _percentChange(totalBalance, balanceLastMonth),
    income: income,
    incomePercent: _percentChange(income, prevIncome),
    expense: expense,
    expensePercent: _percentChange(expense, prevExpense),
    profit: profit,
    profitPercent: _percentChange(profit, prevProfit),
  );
}

/// Computes the Financial Report for [month]: income/expense/profit vs the
/// previous month, expense category breakdown, and a 5-month bar chart
/// series ending at [month].
FinancialReport calculateMonthlyReport(
  List<TransactionModel> all,
  DateTime month,
) {
  final (curStart, curEnd) = _monthRange(month);
  final (prevStart, prevEnd) =
      _monthRange(DateTime(month.year, month.month - 1, 1));

  final income = _sumByType(all, TransactionType.income, curStart, curEnd);
  final prevIncome =
      _sumByType(all, TransactionType.income, prevStart, prevEnd);
  final expense = _sumByType(all, TransactionType.expense, curStart, curEnd);
  final prevExpense =
      _sumByType(all, TransactionType.expense, prevStart, prevEnd);
  final profit = income - expense;
  final prevProfit = prevIncome - prevExpense;

  final expenseTotalsByCategory = <String, double>{};
  for (final t in all) {
    if (t.type != TransactionType.expense) continue;
    if (t.date.isBefore(curStart) || !t.date.isBefore(curEnd)) continue;
    expenseTotalsByCategory[t.category] =
        (expenseTotalsByCategory[t.category] ?? 0) + t.amount;
  }
  final totalExpenseForBreakdown =
      expenseTotalsByCategory.values.fold<double>(0, (a, b) => a + b);
  final sortedCategories = expenseTotalsByCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final categoryBreakdown = [
    for (var i = 0; i < sortedCategories.length; i++)
      CategoryBreakdown(
        label: sortedCategories[i].key,
        percent: totalExpenseForBreakdown == 0
            ? 0
            : (sortedCategories[i].value / totalExpenseForBreakdown) * 100,
        color: _colorForCategory(sortedCategories[i].key, i),
      ),
  ];

  final monthlyChart = [
    for (var i = 4; i >= 0; i--)
      _chartPointFor(all, DateTime(month.year, month.month - i, 1)),
  ];

  return FinancialReport(
    period: '${_monthFull[month.month - 1]} ${month.year}',
    income: income,
    incomePercent: _percentChange(income, prevIncome),
    expense: expense,
    expensePercent: _percentChange(expense, prevExpense),
    profit: profit,
    profitPercent: _percentChange(profit, prevProfit),
    categoryBreakdown: categoryBreakdown,
    monthlyChart: monthlyChart,
  );
}

MonthlyChartPoint _chartPointFor(List<TransactionModel> all, DateTime month) {
  final (start, end) = _monthRange(month);
  return MonthlyChartPoint(
    month: _monthAbbrev[month.month - 1],
    income: _sumByType(all, TransactionType.income, start, end),
    expense: _sumByType(all, TransactionType.expense, start, end),
  );
}
