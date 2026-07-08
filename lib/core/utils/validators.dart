class Validators {
  Validators._();

  static String? required(String? value, {String message = 'Wajib diisi'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah wajib diisi';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty || num.tryParse(cleaned) == null) {
      return 'Jumlah harus berupa angka';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }
}
