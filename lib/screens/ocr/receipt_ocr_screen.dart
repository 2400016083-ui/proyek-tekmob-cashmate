import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/models/transaction_model.dart';
import '../../core/services/ocr_service.dart';

const _indonesianMonths = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember', //
];

class ReceiptOcrScreen extends StatefulWidget {
  const ReceiptOcrScreen({super.key});

  @override
  State<ReceiptOcrScreen> createState() => _ReceiptOcrScreenState();
}

class _ReceiptOcrScreenState extends State<ReceiptOcrScreen> {
  final _ocrService = OcrService();
  final _formatter = NumberFormat.decimalPattern('id_ID');

  final _storeNameController = TextEditingController();
  final _totalController = TextEditingController();

  File? _pickedImage;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _flashOn = false;
  DateTime? _date;
  String? _category;

  @override
  void dispose() {
    _ocrService.dispose();
    _storeNameController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _isProcessing = true;
      _storeNameController.clear();
      _totalController.clear();
      _date = null;
      _category = null;
    });

    try {
      final result = await _ocrService.recognize(_pickedImage!);
      if (!mounted) return;
      setState(() {
        _storeNameController.text = result.storeName ?? '';
        _date = result.date ?? DateTime.now();
        _totalController.text = result.total != null
            ? _formatter.format(result.total!.round())
            : '';
        _category = DummyData.expenseCategories.first;
      });
      if (result.storeName == null && result.total == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teks struk tidak terbaca jelas, lengkapi manual ya'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _date = DateTime.now();
        _category = DummyData.expenseCategories.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memindai gambar, isi datanya manual')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _onTotalChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty ? '' : _formatter.format(int.parse(digits));
    _totalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _saveTransaction() async {
    final storeName = _storeNameController.text.trim();
    final digits = _totalController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (storeName.isEmpty || digits.isEmpty || _category == null || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi nama toko, total, dan kategori dulu')),
      );
      return;
    }

    setState(() => _isSaving = true);
    DummyData.addTransaction(
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: storeName,
        category: _category!,
        type: TransactionType.expense,
        amount: double.parse(digits),
        date: _date!,
        note: 'Hasil scan struk',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi dari hasil scan berhasil disimpan')),
    );
    setState(() {
      _pickedImage = null;
      _isSaving = false;
      _storeNameController.clear();
      _totalController.clear();
      _date = null;
      _category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _pickedImage != null && !_isProcessing;

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
                    if (_isProcessing)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text(
                                    'Memindai struk...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
              const SizedBox(height: 4),
              const Text(
                'Hasil scan otomatis bisa dikoreksi manual sebelum disimpan.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              if (!hasResult)
                Text(
                  _pickedImage == null
                      ? 'Ambil atau pilih foto struk dulu.'
                      : 'Menunggu hasil pemindaian...',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                )
              else ...[
                const Text('Nama Toko', style: _FieldLabelStyle()),
                const SizedBox(height: 8),
                TextField(
                  controller: _storeNameController,
                  decoration: _fieldDecoration(hintText: 'Nama toko'),
                ),
                const SizedBox(height: 16),
                const Text('Tanggal', style: _FieldLabelStyle()),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: _fieldDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _date == null
                              ? 'Pilih tanggal'
                              : '${_date!.day} ${_indonesianMonths[_date!.month - 1]} ${_date!.year}',
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Total', style: _FieldLabelStyle()),
                const SizedBox(height: 8),
                TextField(
                  controller: _totalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _onTotalChanged,
                  decoration: _fieldDecoration(hintText: 'Rp. 0', prefixText: 'Rp. '),
                ),
                const SizedBox(height: 16),
                const Text('Kategori', style: _FieldLabelStyle()),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: [
                    for (final c in DummyData.expenseCategories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                  decoration: _fieldDecoration(),
                ),
              ],
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

  InputDecoration _fieldDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

class _FieldLabelStyle extends TextStyle {
  const _FieldLabelStyle()
      : super(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
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
