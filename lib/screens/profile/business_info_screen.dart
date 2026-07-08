import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/utils/validators.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  late final _nameController =
      TextEditingController(text: DummyData.currentUser.businessName);
  late final _categoryController =
      TextEditingController(text: DummyData.currentUser.businessCategory ?? '');
  late final _descriptionController = TextEditingController(
      text: DummyData.currentUser.businessDescription ?? '');
  late final _addressController =
      TextEditingController(text: DummyData.currentUser.businessAddress ?? '');
  late final _phoneController =
      TextEditingController(text: DummyData.currentUser.businessPhone ?? '');

  late String? _logoPath = DummyData.currentUser.businessLogoUrl;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _logoPath = picked.path);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final error = Validators.required(name, message: 'Nama usaha wajib diisi');
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isSaving = true);

    DummyData.updateCurrentUser(
      DummyData.currentUser.copyWith(
        businessName: name,
        businessCategory: _categoryController.text.trim(),
        businessDescription: _descriptionController.text.trim(),
        businessAddress: _addressController.text.trim(),
        businessPhone: _phoneController.text.trim(),
        businessLogoUrl: _logoPath,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informasi usaha berhasil diperbarui')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Informasi Usaha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _pickLogo,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                          image: _logoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_logoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _logoPath == null
                            ? const Icon(
                                Icons.storefront_outlined,
                                color: AppColors.primary,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickLogo,
                      child: const Text(
                        'Ubah Logo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Nama Usaha', style: _FieldLabelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _fieldDecoration(),
              ),
              const SizedBox(height: 16),
              const Text('Kategori Usaha', style: _FieldLabelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: _fieldDecoration(hintText: 'Contoh: Makanan & Minuman'),
              ),
              const SizedBox(height: 16),
              const Text('Deskripsi Usaha', style: _FieldLabelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _fieldDecoration(hintText: 'Ceritakan tentang usahamu'),
              ),
              const SizedBox(height: 16),
              const Text('Alamat Usaha', style: _FieldLabelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: _fieldDecoration(),
              ),
              const SizedBox(height: 16),
              const Text('Nomor Telepon', style: _FieldLabelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration(hintText: '+62 812-3456-7890'),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
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
