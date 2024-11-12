import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:simandika/models/transaksi_model.dart';
import 'package:simandika/services/transaksi_service.dart';

Future<Uint8List> generateTransactionPDF(
    List<TransaksiModel> transactions,
    DateTime startDate,
    DateTime endDate,
    String token,
    String reportType) async {
  final font = pw.Font.ttf(
      await rootBundle.load("assets/Open_Sans/OpenSans-SemiBold.ttf"));
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/logo_new.png')).buffer.asUint8List(),
  );
  final pdf = pw.Document(
    theme: pw.ThemeData(
      defaultTextStyle: pw.TextStyle(font: font),
    ),
  );

  TransaksiService transactionService = TransaksiService();
  List<TransaksiModel> allTransactions =
      await transactionService.getAllLaporanTransactions(token);

  List<TransaksiModel> filteredTransactions = allTransactions
      .where((transaction) =>
          transaction.createdAt
              .isAfter(startDate.subtract(Duration(days: 1))) &&
          transaction.createdAt.isBefore(endDate.add(Duration(days: 1))))
      .toList();

  // Function to create header
  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logoImage), // Use the logoImage MemoryImage here
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'UD. ANDIKA',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'SUPPLIER DAGING, AYAM',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Text(
                    'Pintu air, Kec. Pulo Gadung, Kota Jakarta Timur, Daerah Khusus Ibukota Jakarta 14240',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Laporan $reportType',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Rentang Tanggal: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // Function to create footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        'Halaman ${context.pageNumber} dari ${context.pagesCount}',
        style: pw.Theme.of(context)
            .defaultTextStyle
            .copyWith(color: PdfColors.grey),
      ),
    );
  }

  // Create pages with paginated content
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildHeader(),
          pw.Table.fromTextArray(
            headers: ['ID', 'Tanggal', 'PIC', 'Jenis', 'Jumlah', 'Keterangan'],
            data: filteredTransactions
                .map((transaction) => [
                      transaction.id.toString(),
                      DateFormat('dd/MM/yyyy').format(transaction.createdAt),
                      transaction.user?.name ?? 'Unknown',
                      transaction.type == 'sale' ? 'Penjualan' : 'Pembelian',
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.amount)}',
                      transaction.keterangan,
                    ])
                .toList(),
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
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
        ];
      },
      footer: _buildFooter,
    ),
  );

  return pdf.save();
}
