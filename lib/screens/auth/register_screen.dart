import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/models/user_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/auth_error_mapper.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color green = Color(0xFF168A4A);

  final _authService = AuthService();
  final _userService = UserService();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final businessName = _businessNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final error = Validators.required(name, message: 'Nama lengkap wajib diisi') ??
        Validators.required(businessName, message: 'Nama bisnis wajib diisi') ??
        Validators.email(email) ??
        Validators.required(password, message: 'Password wajib diisi');

    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _authService.registerWithEmail(email, password);
      final uid = credential.user!.uid;
      await _userService.createUserProfile(
        UserModel(
          id: uid,
          name: name,
          email: email,
          role: 'Small Business Owner',
          businessName: businessName,
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } on FirebaseAuthException catch (e) {
      _showMessage(firebaseAuthErrorMessage(e));
    } catch (_) {
      _showMessage('Terjadi kesalahan, silakan coba lagi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.logo, width: 64),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "CashMate",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: green,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "SMART BUSINESS FINANCE",
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: .7,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Daftar untuk mulai mengelola\nkeuangan bisnismu.",
                style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              _FieldLabel('Nama Lengkap'),
              const SizedBox(height: 12),
              _RoundedTextField(controller: _nameController, hintText: 'Nama Anda'),
              const SizedBox(height: 20),
              _FieldLabel('Nama Bisnis'),
              const SizedBox(height: 12),
              _RoundedTextField(
                controller: _businessNameController,
                hintText: 'Contoh: Toko Makanan & Minuman',
              ),
              const SizedBox(height: 20),
              _FieldLabel('Email'),
              const SizedBox(height: 12),
              _RoundedTextField(
                controller: _emailController,
                hintText: 'contoh@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _FieldLabel('Password'),
              const SizedBox(height: 12),
              _RoundedTextField(
                controller: _passwordController,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Daftar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Sudah punya akun? ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: "Masuk",
                          style: TextStyle(color: green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _RoundedTextField({
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
