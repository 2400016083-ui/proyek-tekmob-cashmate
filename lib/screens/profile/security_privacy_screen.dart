import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _twoFactorEnabled = false;
  final List<String> _connectedDevices = ['HP ini (Android)', 'Chrome di Windows'];

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini akan segera hadir')),
    );
  }

  Future<void> _changePassword() async {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Password minimal 6 karakter')),
                );
                return;
              }
              if (newPasswordController.text != confirmController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Konfirmasi password tidak cocok')),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );
    }
  }

  Future<void> _toggleTwoFactor() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_twoFactorEnabled ? 'Nonaktifkan 2FA?' : 'Aktifkan 2FA?'),
        content: Text(
          _twoFactorEnabled
              ? 'Akun akan lebih rentan tanpa autentikasi dua faktor.'
              : 'Setiap login akan meminta kode verifikasi tambahan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _twoFactorEnabled = !_twoFactorEnabled);
    }
  }

  Future<void> _showConnectedDevices() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perangkat Terhubung',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    for (final device in _connectedDevices)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.devices_outlined, color: AppColors.textSecondary),
                        title: Text(device),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() => _connectedDevices.remove(device));
                            setModalState(() {});
                          },
                          child: const Text('Keluar', style: TextStyle(color: AppColors.expense)),
                        ),
                      ),
                    if (_connectedDevices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Tidak ada perangkat lain yang terhubung.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Semua data usaha dan transaksi akan hilang permanen. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Keamanan & Privasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Keamanan Akun', style: _SectionStyle()),
            const SizedBox(height: 4),
            _SecurityTile(
              icon: Icons.lock_outline,
              label: 'Ubah Password',
              onTap: _changePassword,
            ),
            _SecurityTile(
              icon: Icons.lock_outline,
              label: 'Autentikasi Dua Faktor',
              trailingText: _twoFactorEnabled ? 'Aktif' : 'Nonaktif',
              onTap: _toggleTwoFactor,
            ),
            _SecurityTile(
              icon: Icons.devices_outlined,
              label: 'Perangkat Terhubung',
              trailingText: '${_connectedDevices.length} perangkat',
              onTap: _showConnectedDevices,
            ),
            const SizedBox(height: 20),
            const Text('Privasi', style: _SectionStyle()),
            const SizedBox(height: 4),
            _SecurityTile(
              icon: Icons.description_outlined,
              label: 'Kelola Data',
              onTap: _showComingSoon,
            ),
            _SecurityTile(
              icon: Icons.shield_outlined,
              label: 'Pengaturan Privasi',
              onTap: _showComingSoon,
            ),
            _SecurityTile(
              icon: Icons.delete_outline,
              label: 'Hapus Akun',
              destructive: true,
              showChevron: false,
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionStyle extends TextStyle {
  const _SectionStyle()
      : super(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        );
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool destructive;
  final bool showChevron;
  final VoidCallback onTap;

  const _SecurityTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.destructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.expense : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: destructive ? AppColors.expense : AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (showChevron)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
