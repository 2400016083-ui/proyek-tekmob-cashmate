import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';

const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des', //
];

class CloudBackupScreen extends StatelessWidget {
  const CloudBackupScreen({super.key});

  String _formatDateTime(DateTime date) {
    final day = date.day;
    final month = _monthAbbrev[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month ${date.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cadangan Cloud')),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: DummyData.cloudBackupActiveNotifier,
          builder: (context, isActive, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryLight : AppColors.background,
                          shape: BoxShape.circle,
                          border: isActive ? null : Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isActive ? 'Cadangan Cloud Aktif' : 'Cadangan Cloud Nonaktif',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive
                            ? 'Data usaha Anda aman di cloud.'
                            : 'Aktifkan untuk mengamankan data usahamu di cloud.',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (isActive)
                  ValueListenableBuilder<DateTime>(
                    valueListenable: DummyData.lastBackupAtNotifier,
                    builder: (context, lastBackupAt, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _infoRow('Status', 'Active', valueColor: AppColors.primary),
                            const Divider(),
                            _infoRow('Terakhir Dicadangkan', _formatDateTime(lastBackupAt)),
                            const Divider(),
                            _infoRow('Ukuran Data', '24,6 MB'),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: isActive
                      ? OutlinedButton.icon(
                          onPressed: () {
                            DummyData.lastBackupAtNotifier.value = DateTime.now();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cadangan berhasil diperbarui')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                          label: const Text(
                            'Cadangan Cloud Aktif',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            DummyData.cloudBackupActiveNotifier.value = true;
                            DummyData.lastBackupAtNotifier.value = DateTime.now();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cadangan cloud diaktifkan')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                          label: const Text(
                            'Aktifkan Cadangan Cloud',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        DummyData.cloudBackupActiveNotifier.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cadangan cloud dinonaktifkan')),
                        );
                      },
                      child: const Text(
                        'Nonaktifkan Cadangan',
                        style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
