import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/dummy_data.dart' show FinancialReport;
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';

class PdfExportService {
  Future<void> exportFinancialReport({
    required FinancialReport report,
    required List<TransactionModel> transactionsInMonth,
  }) async {
    final doc = pw.Document();
    final sortedTransactions = [...transactionsInMonth]
      ..sort((a, b) => b.date.compareTo(a.date));

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'CashMate - Laporan Keuangan',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Periode: ${report.period}'),
          pw.Text(
            'Diekspor: ${_formatDate(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Ringkasan'),
          pw.SizedBox(height: 8),
          _summaryTable(report),
          pw.SizedBox(height: 20),
          _sectionTitle('Pengeluaran Berdasarkan Kategori'),
          pw.SizedBox(height: 8),
          _categoryTable(report),
          pw.SizedBox(height: 20),
          _sectionTitle('Daftar Transaksi'),
          pw.SizedBox(height: 8),
          _transactionTable(sortedTransactions),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileSuffix = report.period
        .toLowerCase()
        .replaceAll(' ', '-');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'laporan-keuangan-$fileSuffix.pdf',
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _summaryTable(FinancialReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(1),
      },
      children: [
        _summaryRow(
          'Pemasukan',
          CurrencyFormatter.format(report.income),
          CurrencyFormatter.formatPercent(report.incomePercent),
        ),
        _summaryRow(
          'Pengeluaran',
          CurrencyFormatter.format(report.expense),
          CurrencyFormatter.formatPercent(report.expensePercent),
        ),
        _summaryRow(
          'Laba Bersih',
          CurrencyFormatter.format(report.profit),
          CurrencyFormatter.formatPercent(report.profitPercent),
        ),
      ],
    );
  }

  pw.TableRow _summaryRow(String label, String amount, String percent) {
    return pw.TableRow(
      children: [
        _cell(label, bold: true),
        _cell(amount),
        _cell(percent),
      ],
    );
  }

  pw.Widget _categoryTable(FinancialReport report) {
    if (report.categoryBreakdown.isEmpty) {
      return pw.Text('Belum ada pengeluaran di bulan ini.');
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(children: [
          _cell('Kategori', bold: true),
          _cell('Persentase', bold: true),
        ]),
        for (final item in report.categoryBreakdown)
          pw.TableRow(children: [
            _cell(item.label),
            _cell('${item.percent.toStringAsFixed(1)}%'),
          ]),
      ],
    );
  }

  pw.Widget _transactionTable(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return pw.Text('Tidak ada transaksi di bulan ini.');
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(children: [
          _cell('Tanggal', bold: true),
          _cell('Judul', bold: true),
          _cell('Kategori', bold: true),
          _cell('Jumlah', bold: true),
        ]),
        for (final t in transactions)
          pw.TableRow(children: [
            _cell(_formatDate(t.date)),
            _cell(t.title),
            _cell(t.category),
            _cell(
              CurrencyFormatter.formatSigned(
                t.amount,
                isIncome: t.type == TransactionType.income,
              ),
            ),
          ]),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
