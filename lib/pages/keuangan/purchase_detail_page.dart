import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';

class PurchaseDetailPage extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailPage({Key? key, required this.purchaseId})
      : super(key: key);

  @override
  _PurchaseDetailPageState createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  late Future<PurchaseModel> _purchaseFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _purchaseFuture =
          PurchaseService().getPurchaseById(widget.purchaseId, token);
    } else {
      _purchaseFuture = Future.error('Invalid token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Purchase',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<PurchaseModel>(
        future: _purchaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Pembelian tidak ditemukan'));
          } else {
            final purchase = snapshot.data!;
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
                        'Pembelian',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('ID Pembelian', '#${purchase.id}'),
                      _buildDetailRow(
                          'Tanggal',
                          DateFormat('dd MMMM yyyy, HH:mm')
                              .format(purchase.createdAt)),
                      _buildDetailRow(
                          'Supplier', purchase.supplier?.name ?? 'Unknown'),
                      _buildDetailRow(
                          'Jumlah',
                          NumberFormat.currency(
                                  locale: 'id_ID ', decimalDigits: 2)
                              .format(purchase.totalPrice)),
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
