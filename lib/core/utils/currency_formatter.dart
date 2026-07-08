import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  /// Formats [amount] as "Rp. 500.000".
  static String format(num amount) {
    return 'Rp. ${_formatter.format(amount)}';
  }

  /// Formats [amount] as "+Rp. 500.000" / "-Rp. 200.000".
  static String formatSigned(num amount, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount.abs())}';
  }

  /// Formats a percentage change like "+15,2%" / "-9,4%".
  static String formatPercent(num percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1).replaceAll('.', ',')}%';
  }
}
