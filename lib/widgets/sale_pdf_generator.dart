import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:simandika/models/sale_model.dart';
import 'package:simandika/services/sale_service.dart';

Future<Uint8List> generateSalesPDF(List<SaleModel> sales, DateTime startDate,
    DateTime endDate, String token, String reportType) async {
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

  SaleService saleService = SaleService();
  List<SaleModel> allSales = await saleService.getAllLaporanSales(token);
  List<SaleModel> filteredSales = allSales
      .where((sale) =>
          sale.createdAt.isAfter(startDate.subtract(Duration(days: 1))) &&
          sale.createdAt.isBefore(endDate.add(Duration(days: 1))))
      .toList();

  print('Debug: Number of filtered sales: ${filteredSales.length}');

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
                    'Jl. Lambung Mangkurat Ps. Rahmat Los 1 No. 140, Samarinda. (Hp. 0812 5716 0808)',
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

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildHeader(),
          pw.Table.fromTextArray(
            headers: [
              'ID Sales',
              'Tanggal',
              'Nama Customer',
              'Quantity',
              'Price per Unit',
              'Total Harga'
            ],
            data: filteredSales.map((sale) {
              return [
                sale.id.toString(),
                DateFormat('dd/MM/yyyy').format(sale.createdAt),
                sale.customer?.name ?? 'Unknown',
                sale.quantity.toString(),
                'Rp ${NumberFormat('#,##0', 'id_ID').format(sale.pricePerUnit)}',
                'Rp ${NumberFormat('#,##0', 'id_ID').format(sale.totalPrice)}',
              ];
            }).toList(),
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Total Penjualan: ${filteredSales.length}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total Nilai Penjualan: Rp ${NumberFormat('#,##0', 'id_ID').format(filteredSales.fold(0.0, (sum, sale) => sum + sale.totalPrice))}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ];
      },
      footer: _buildFooter,
    ),
  );

  return pdf.save();
}
