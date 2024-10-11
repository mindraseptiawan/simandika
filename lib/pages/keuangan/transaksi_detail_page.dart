import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/transaksi_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/transaksi_service.dart';
import 'package:simandika/theme.dart';

class TransaksiDetailPage extends StatefulWidget {
  final int transactionId;

  const TransaksiDetailPage({Key? key, required this.transactionId})
      : super(key: key);

  @override
  _TransaksiDetailPageState createState() => _TransaksiDetailPageState();
}

class _TransaksiDetailPageState extends State<TransaksiDetailPage> {
  late Future<TransaksiModel> _transactionFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _transactionFuture =
          TransaksiService().getTransactionById(widget.transactionId, token);
    } else {
      _transactionFuture = Future.error('Invalid token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<TransaksiModel>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          } else {
            final transaction = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.type == 'sale' ? 'Penjualan' : 'Pembelian',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('ID Transaksi', '#${transaction.id}'),
                      _buildDetailRow(
                          'Tanggal',
                          DateFormat('dd MMMM yyyy, HH:mm')
                              .format(transaction.createdAt)),
                      _buildDetailRow('Jumlah',
                          'Rp ${transaction.amount?.toStringAsFixed(2) ?? 'N/A'}'),
                      _buildDetailRow(
                          'Tipe',
                          transaction.type == 'sale'
                              ? 'Penjualan'
                              : 'Pembelian'),
                      _buildDetailRow('Keterangan',
                          transaction.keterangan ?? 'Tidak ada keterangan'),
                      if (transaction.user != null) ...[
                        const SizedBox(height: 16),
                        Text('Informasi Pengguna',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        _buildDetailRow('Nama', transaction.user!.name),
                        _buildDetailRow('Email', transaction.user!.email),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
