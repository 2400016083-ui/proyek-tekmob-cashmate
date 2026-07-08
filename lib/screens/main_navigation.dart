import 'package:flutter/material.dart';

import '../core/widgets/bottom_nav_bar.dart';
import 'home/dashboard_screen.dart';
import 'ocr/receipt_ocr_screen.dart';
import 'profile/profile_screen.dart';
import 'report/financial_reports_screen.dart';
import 'transaction/transaction_history_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex = widget.initialIndex;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateToTab: _goToTab),
      const TransactionHistoryScreen(),
      const ReceiptOcrScreen(),
      const FinancialReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}
