import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const CashMateApp());
}

class CashMateApp extends StatelessWidget {
  const CashMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CashMate",
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}