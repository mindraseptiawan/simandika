import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:simandika/models/stock_model.dart';
import 'package:simandika/services/stock_service.dart';

Future<Uint8List> generateStockMovementPDF(
  List<StockMovementModel> stocks,
  DateTime startDate,
  DateTime endDate,
  String token,
  String reportType,
  int? kandangId,
) async {
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

  StockService stockService = StockService();
  List<StockMovementModel> allstocks =
      await stockService.getAllLaporanStocks(token);

  List<StockMovementModel> filteredStocks = allstocks.where((stock) {
    final isWithinDateRange =
        stock.createdAt.isAfter(startDate.subtract(Duration(days: 1))) &&
            stock.createdAt.isBefore(endDate.add(Duration(days: 1)));

    final matchesKandang = kandangId == null || stock.kandang?.id == kandangId;

    return isWithinDateRange && matchesKandang;
  }).toList();

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
              child: pw.Image(logoImage),
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

  // Calculate totals
  int totalPurchase = filteredStocks
      .where((stock) =>
          stock.type == 'in' && stock.referenceType == 'App\\Models\\Purchase')
      .fold(0, (sum, stock) => sum + stock.quantity);

  int totalSales = filteredStocks
      .where((stock) =>
          stock.type == 'out' && stock.referenceType == 'App\\Models\\Sale')
      .fold(0, (sum, stock) => sum + stock.quantity);

  int totalDead = filteredStocks
      .where((stock) =>
          stock.type == 'out' &&
          stock.referenceType == 'App\\Models\\Pemeliharaan')
      .fold(0, (sum, stock) => sum + stock.quantity);

  // Create pages with improved table formatting
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildHeader(),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(30), // ID
              1: const pw.FixedColumnWidth(80), // Date
              2: const pw.FixedColumnWidth(70), // Kandang
              3: const pw.FixedColumnWidth(40), // Type
              4: const pw.FixedColumnWidth(50), // Qty
              5: const pw.FlexColumnWidth(2.5), // Notes - flexible width
            },
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  'ID',
                  'Date',
                  'Kandang',
                  'Type',
                  'Qty',
                  'Notes',
                ]
                    .map((header) => pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
              // Data rows
              ...filteredStocks.map((stock) => pw.TableRow(
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(stock.id.toString(),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          DateFormat('dd/MM/yyyy').format(stock.createdAt),
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          stock.kandang?.namaKandang ?? '-',
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          stock.type.toString(),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          stock.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          stock.notes.toString(),
                          textAlign: pw.TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ringkasan:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total Stock Masuk (Purchase): ${totalPurchase}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total Stock Keluar (Sale): ${totalSales}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total Ayam Mati (Pemeliharaan): ${totalDead}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ];
      },
      footer: _buildFooter,
    ),
  );

  return pdf.save();
}
