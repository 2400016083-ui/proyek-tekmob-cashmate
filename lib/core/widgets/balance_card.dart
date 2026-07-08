import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'chart_card.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double percent;
  final VoidCallback? onScanTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.percent,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: 110,
              height: 50,
              child: MiniSparkline(color: Colors.white.withValues(alpha: 0.35)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: onScanTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.crop_free,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                CurrencyFormatter.format(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${CurrencyFormatter.formatPercent(percent)} dari bulan lalu',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
