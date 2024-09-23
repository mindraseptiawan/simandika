import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/theme.dart';

class DetailPemeliharaanPage extends StatelessWidget {
  final PemeliharaanModel pemeliharaan;

  const DetailPemeliharaanPage({super.key, required this.pemeliharaan});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final String formattedDate = dateFormat.format(
      DateTime.parse(
          pemeliharaan.createdAt ?? DateTime.now().toIso8601String()),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pemeliharaan', style: primaryTextStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(defaultMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: $formattedDate',
              style: inputTextStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Umur: ${pemeliharaan.umur} hari',
              style: inputTextStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Jumlah Ayam: ${pemeliharaan.jumlahAyam}',
              style: inputTextStyle.copyWith(fontSize: 16),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
