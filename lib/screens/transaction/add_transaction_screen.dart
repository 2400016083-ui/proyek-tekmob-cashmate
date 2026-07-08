import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart' show DummyData;
import '../../core/models/transaction_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/transaction_service.dart';

const _indonesianMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.income,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type = widget.initialType;
  late String? _category = _categoriesFor(_type).first;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  final _formatter = NumberFormat.decimalPattern('id_ID');

  List<String> _categoriesFor(TransactionType type) {
    return type == TransactionType.income
        ? DummyData.incomeCategories
        : DummyData.expenseCategories;
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      _category = _categoriesFor(type).first;
    });
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty ? '' : _formatter.format(int.parse(digits));
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  bool _isSaving = false;

  Future<void> _save() async {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (_category == null || digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori dan jumlah terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = AuthService().currentUser!.uid;
      await TransactionService().addTransaction(
        uid,
        TransactionModel(
          id: '',
          title: _category!,
          category: _category!,
          type: _type,
          amount: double.parse(digits),
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
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
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesFor(_type);
    final typeLabel = _type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambahkan Transaksi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TypeToggleButton(
                      label: 'Pemasukan',
                      selected: _type == TransactionType.income,
                      onTap: () => _onTypeChanged(TransactionType.income),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeToggleButton(
                      label: 'Pengeluaran',
                      selected: _type == TransactionType.expense,
                      onTap: () => _onTypeChanged(TransactionType.expense),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(typeLabel, style: const _FieldLabelStyle()),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: [
                  for (final c in categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (value) => setState(() => _category = value),
                decoration: _fieldDecoration(),
              ),
              const SizedBox(height: 24),
              const Text('Jumlah', style: _FieldLabelStyle()),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onAmountChanged,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                decoration: _fieldDecoration(
                  hintText: 'Rp. 0',
                  prefixText: 'Rp. ',
                ),
              ),
              const SizedBox(height: 24),
              const Text('Tanggal', style: _FieldLabelStyle()),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _fieldDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_date.day} ${_indonesianMonths[_date.month - 1]} ${_date.year}',
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Catatan (Opsional)', style: _FieldLabelStyle()),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: _fieldDecoration(hintText: 'Tulis catatan tambahan'),
              ),
              const SizedBox(height: 32),
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
                          'Simpan Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
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
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        );
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
