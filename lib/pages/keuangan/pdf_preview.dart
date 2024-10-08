import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PDFPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PDFPreviewPage(
      {Key? key, required this.pdfBytes, required this.fileName})
      : super(key: key);

  Future<void> _savePDF() async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Transaksi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _savePDF,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowSharing: false,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: fileName,
      ),
    );
  }
}
