import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Map<String, bool> _settings = {
    'Ringkasan Harian': true,
    'Pengingat Pembayaran': true,
    'Pemasukan': true,
    'Pengeluaran': true,
    'Promo & Tips': true,
    'Berita Produk': false,
  };

  static const _descriptions = {
    'Ringkasan Harian': 'Terima ringkasan transaksi harian',
    'Pengingat Pembayaran': 'Pengingat jatuh tempo pembayaran',
    'Pemasukan': 'Notifikasi setiap ada pemasukan',
    'Pengeluaran': 'Notifikasi setiap ada pengeluaran',
    'Promo & Tips': 'Info promo dan tips keuangan',
    'Berita Produk': 'Update terbaru dari CashMate',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifikasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (final key in _settings.keys)
              _NotificationToggle(
                title: key,
                subtitle: _descriptions[key]!,
                value: _settings[key]!,
                onChanged: (value) => setState(() => _settings[key] = value),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
