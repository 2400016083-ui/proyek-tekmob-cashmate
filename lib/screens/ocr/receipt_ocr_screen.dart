import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/transaction_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/transaction_service.dart';

/// Dummy OCR result shaped like what a real OCR API would return.
/// TODO: replace with a real OCR service call (see lib/core/services/ocr_service.dart)
/// once a receipt-recognition API/package is integrated.
class _DummyOcrResult {
  final String storeName;
  final DateTime date;
  final double total;
  final String category;

  const _DummyOcrResult({
    required this.storeName,
    required this.date,
    required this.total,
    required this.category,
  });
}

final _dummyOcrResult = _DummyOcrResult(
  storeName: 'Toko Sejahtera',
  date: DateTime(2025, 5, 30),
  total: 68000,
  category: 'Bahan Baku',
);

class ReceiptOcrScreen extends StatefulWidget {
  const ReceiptOcrScreen({super.key});

  @override
  State<ReceiptOcrScreen> createState() => _ReceiptOcrScreenState();
}

class _ReceiptOcrScreenState extends State<ReceiptOcrScreen> {
  File? _pickedImage;
  bool _flashOn = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  bool _isSaving = false;

  Future<void> _saveTransaction() async {
    setState(() => _isSaving = true);
    try {
      final uid = AuthService().currentUser!.uid;
      await TransactionService().addTransaction(
        uid,
        TransactionModel(
          id: '',
          title: _dummyOcrResult.storeName,
          category: _dummyOcrResult.category,
          type: TransactionType.expense,
          amount: _dummyOcrResult.total,
          date: _dummyOcrResult.date,
          note: 'Hasil scan struk',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dari hasil scan berhasil disimpan')),
      );
      setState(() => _pickedImage = null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan transaksi, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _pickedImage != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Struk'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.crop_free, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: AppColors.primaryLight,
                          child: _pickedImage == null
                              ? const Center(
                                  child: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 56,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Image.file(_pickedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const Positioned.fill(child: _CornerBrackets(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),
              const Text(
                'Hasil OCR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _OcrField(
                label: 'Nama Toko',
                value: hasResult ? _dummyOcrResult.storeName : '-',
              ),
              const SizedBox(height: 12),
              _OcrField(
                label: 'Tanggal',
                value: hasResult
                    ? '${_dummyOcrResult.date.day} Mei ${_dummyOcrResult.date.year}'
                    : '-',
              ),
              const SizedBox(height: 12),
              _OcrField(
                label: 'Total',
                value: hasResult ? 'Rp${_dummyOcrResult.total.toInt()}' : '-',
              ),
              const SizedBox(height: 12),
              _OcrField(
                label: 'Kategori',
                value: hasResult ? _dummyOcrResult.category : '-',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (hasResult && !_isSaving) ? _saveTransaction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleIconButton(
                    icon: Icons.image_outlined,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _CircleIconButton(
                    icon: Icons.circle,
                    size: 64,
                    filled: true,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _CircleIconButton(
                    icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: () => setState(() => _flashOn = !_flashOn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OcrField extends StatelessWidget {
  final String label;
  final String value;

  const _OcrField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  final Color color;

  const _CornerBrackets({required this.color});

  @override
  Widget build(BuildContext context) {
    Widget corner({required bool top, required bool left}) {
      return Positioned(
        top: top ? 10 : null,
        bottom: top ? null : 10,
        left: left ? 10 : null,
        right: left ? null : 10,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            border: Border(
              top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
              bottom: !top ? BorderSide(color: color, width: 3) : BorderSide.none,
              left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
              right: !left ? BorderSide(color: color, width: 3) : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(top: true, left: true),
        corner(top: true, left: false),
        corner(top: false, left: true),
        corner(top: false, left: false),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool filled;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.primary : Colors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : AppColors.textPrimary,
          size: filled ? 28 : 22,
        ),
      ),
    );
  }
}
