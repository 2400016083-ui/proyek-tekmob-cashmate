import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shows the picked profile photo (a local file path from Edit Profil) or a
/// placeholder icon when none has been set.
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;

  const UserAvatar({super.key, required this.avatarUrl, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: FileImage(File(url)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Icon(Icons.person, color: AppColors.primary, size: radius),
    );
  }
}
