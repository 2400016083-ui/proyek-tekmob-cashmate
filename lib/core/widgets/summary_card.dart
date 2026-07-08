import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final double percent;
  final Color backgroundColor;
  final Color labelColor;
  final bool bordered;
  final Widget? trailing;

  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.percent,
    this.backgroundColor = Colors.white,
    this.labelColor = AppColors.textPrimary,
    this.bordered = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percent >= 0;
    final percentColor = isPositive ? AppColors.income : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: bordered ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(amount),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatPercent(percent),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: percentColor,
            ),
          ),
        ],
      ),
    );
  }
}
