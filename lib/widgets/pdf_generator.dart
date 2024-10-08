// File: lib/utils/pdf_generator.dart

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:simandika/models/transaksi_model.dart';

Future<Uint8List> generateTransactionPDF(List<TransaksiModel> transactions,
    DateTime startDate, DateTime endDate) async {
  final pdf = pw.Document();

  final filteredTransactions = transactions
      .where((transaction) =>
          transaction.createdAt.isAfter(startDate) &&
          transaction.createdAt.isBefore(endDate.add(const Duration(days: 1))))
      .toList();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Laporan Transaksi',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Rentang Tanggal: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['ID', 'Jenis', 'Jumlah', 'Tanggal'],
              data: filteredTransactions
                  .map((transaction) => [
                        transaction.id.toString(),
                        transaction.type == 'sale' ? 'Penjualan' : 'Pembelian',
                        'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.amount)}',
                        DateFormat('dd/MM/yyyy').format(transaction.createdAt),
                      ])
                  .toList(),
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Transaksi: ${filteredTransactions.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Total Jumlah: Rp ${NumberFormat('#,##0', 'id_ID').format(filteredTransactions.fold(0.0, (sum, item) => sum + (item.amount ?? 0)))}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
