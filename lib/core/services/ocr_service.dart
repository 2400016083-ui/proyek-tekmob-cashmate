import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Result of scanning a receipt image. [storeName], [date] and [total] are
/// best-effort guesses parsed from the recognized text — always let the
/// user review/edit them before saving, since receipt layouts vary a lot.
class OcrResult {
  final String rawText;
  final String? storeName;
  final DateTime? date;
  final double? total;

  const OcrResult({
    required this.rawText,
    this.storeName,
    this.date,
    this.total,
  });
}

class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognize(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _recognizer.processImage(inputImage);
    final rawText = recognizedText.text;

    return OcrResult(
      rawText: rawText,
      storeName: _extractStoreName(rawText),
      date: _extractDate(rawText),
      total: _extractTotal(rawText),
    );
  }

  void dispose() => _recognizer.close();

  /// Receipts almost always print the store name on the first printed line.
  String? _extractStoreName(String text) {
    final lines = _lines(text);
    return lines.isEmpty ? null : lines.first;
  }

  static final _datePattern =
      RegExp(r'(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})');

  DateTime? _extractDate(String text) {
    final match = _datePattern.firstMatch(text);
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    var year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    try {
      return DateTime(year, month, day);
    } on ArgumentError {
      return null;
    }
  }

  double? _extractTotal(String text) {
    final lines = _lines(text);

    // Prefer a line that says "total" but not "subtotal".
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('total') && !lower.contains('subtotal')) {
        final amount = _lastAmountOnLine(line);
        if (amount != null) return amount;
      }
    }
    // Fall back to any line mentioning total/subtotal.
    for (final line in lines) {
      if (line.toLowerCase().contains('total')) {
        final amount = _lastAmountOnLine(line);
        if (amount != null) return amount;
      }
    }
    // Last resort: the largest number anywhere on the receipt.
    final amounts = [
      for (final line in lines) ?_lastAmountOnLine(line),
    ];
    if (amounts.isEmpty) return null;
    amounts.sort();
    return amounts.last;
  }

  static final _amountPattern = RegExp(r'\d[\d.,]*\d|\d');

  double? _lastAmountOnLine(String line) {
    final matches = _amountPattern.allMatches(line).toList();
    if (matches.isEmpty) return null;
    final raw = matches.last.group(0)!;
    // Indonesian receipts use '.' or ',' as thousand separators.
    final digitsOnly = raw.replaceAll(RegExp(r'[.,]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  List<String> _lines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}
