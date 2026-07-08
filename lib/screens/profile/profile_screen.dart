import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/models/user_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/user_avatar.dart';
import 'business_info_screen.dart';
import 'cloud_backup_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'security_privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini akan segera hadir')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<UserModel>(
          valueListenable: DummyData.currentUserNotifier,
          builder: (context, user, _) {
            return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  UserAvatar(avatarUrl: user.avatarUrl, radius: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name}!',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (user.isPremium) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusinessInfoScreen()),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_outlined, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Business',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            user.businessName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.person_outline,
              label: 'Edit Profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.storefront_outlined,
              label: 'Informasi Usaha',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusinessInfoScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notifikasi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: DummyData.cloudBackupActiveNotifier,
              builder: (context, isBackupActive, _) {
                return _MenuTile(
                  icon: Icons.cloud_outlined,
                  label: 'Cadangan Cloud',
                  trailingText: isBackupActive ? 'Active' : 'Nonaktif',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CloudBackupScreen()),
                  ),
                );
              },
            ),
            _MenuTile(
              icon: Icons.shield_outlined,
              label: 'Keamanan & Privasi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Pusat Bantuan',
              onTap: () => _showComingSoon(context),
            ),
            _MenuTile(
              icon: Icons.info_outline_rounded,
              label: 'Tentang CashMate',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.expense),
                    SizedBox(width: 14),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        color: AppColors.expense,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
