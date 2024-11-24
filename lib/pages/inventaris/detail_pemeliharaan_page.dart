import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/theme.dart';

class DetailPemeliharaanPage extends StatefulWidget {
  final int pemeliharaanId;

  const DetailPemeliharaanPage({super.key, required this.pemeliharaanId});
  @override
  _DetailPemeliharaanPageState createState() => _DetailPemeliharaanPageState();
}

class _DetailPemeliharaanPageState extends State<DetailPemeliharaanPage> {
  late Future<PemeliharaanModel> _pemeliharaamFuture;

  @override
  void initState() {
    super.initState();
    _loadPemeliharaan();
  }

  void _loadPemeliharaan() {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _pemeliharaamFuture = PemeliharaanService()
          .getPemeliharaanById(widget.pemeliharaanId, token);
    } else {
      _pemeliharaamFuture = Future.error('Invalid token');
    }
  }

  String _formatValue(dynamic value) {
    if (value is DateTime) {
      return DateFormat('dd MMMM yyyy, HH:mm').format(value);
    } else if (value is String) {
      return value;
    } else {
      return value.toString(); // Fallback for other types
    }
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              _formatValue(value),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor1,
        appBar: AppBar(
          title: Text('Detail Pemeliharaan',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<PemeliharaanModel>(
            future: _pemeliharaamFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Pembelian tidak ditemukan'));
              } else {
                final pemeliharaan = snapshot.data!;
                return Padding(
                    padding: EdgeInsets.all(defaultMargin),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            color: primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pemeliharaan',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow('Batch',
                                      '#${pemeliharaan.purchaseId ?? ''}'),
                                  _buildDetailRow('Jumlah Ayam',
                                      '${pemeliharaan.jumlahAyam}'),
                                  _buildDetailRow('Jumlah Ayam Mati',
                                      '${pemeliharaan.mati ?? ''}'),
                                  _buildDetailRow('Keterangan',
                                      pemeliharaan.keterangan ?? 'Unknown'),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          )
                        ]));
              }
            }));
  }
}
