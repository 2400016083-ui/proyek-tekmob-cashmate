import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/transaction_service.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/report_calculator.dart';
import '../../core/widgets/action_button.dart';
import '../../core/widgets/balance_card.dart';
import '../../core/widgets/summary_card.dart';
import '../../core/widgets/transaction_tile.dart';
import '../transaction/add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  void _openAddTransaction(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: TransactionService().watchTransactions(uid),
          builder: (context, snapshot) {
            final transactions = snapshot.data ?? const <TransactionModel>[];
            final summary = calculateDashboardSummary(transactions);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                StreamBuilder<UserModel?>(
                  stream: UserService().watchUserProfile(uid),
                  builder: (context, userSnapshot) {
                    final name = userSnapshot.data?.name ?? '...';
                    return Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $name!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Update Keuanganmu Sekarang!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => onNavigateToTab?.call(4),
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                BalanceCard(
                  balance: summary.totalBalance,
                  percent: summary.balancePercent,
                  onScanTap: () => onNavigateToTab?.call(2),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Pemasukan',
                        amount: summary.income,
                        percent: summary.incomePercent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Pengeluaran',
                        amount: summary.expense,
                        percent: summary.expensePercent,
                        backgroundColor: const Color(0xFFFCE8E8),
                        labelColor: AppColors.expense,
                        bordered: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Keuntungan',
                        amount: summary.profit,
                        percent: summary.profitPercent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Akses Cepat'),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Tambah\nPemasukan',
                      backgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      onTap: () =>
                          _openAddTransaction(context, TransactionType.income),
                    ),
                    ActionButton(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Tambah\nPengeluaran',
                      backgroundColor: const Color(0xFFFCE8E8),
                      iconColor: AppColors.expense,
                      onTap: () => _openAddTransaction(
                          context, TransactionType.expense),
                    ),
                    ActionButton(
                      icon: Icons.crop_free,
                      label: 'Scan\nStruk',
                      backgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      onTap: () => onNavigateToTab?.call(2),
                    ),
                    ActionButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Laporan',
                      backgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      onTap: () => onNavigateToTab?.call(3),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Transaksi Terbaru',
                  onSeeAll: () => onNavigateToTab?.call(1),
                ),
                const SizedBox(height: 14),
                for (final transaction in transactions.take(4))
                  TransactionTile(transaction: transaction),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
