import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/pages/keuangan/form_purchase_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

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
    _loadPurchase();
  }

  void _loadPurchase() {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _purchaseFuture =
          PurchaseService().getPurchaseById(widget.purchaseId, token);
    } else {
      _purchaseFuture = Future.error('Invalid token');
    }
  }

  Future<void> _editPurchase(PurchaseModel purchase) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormPurchasePage(purchase: purchase),
      ),
    );

    if (result == true) {
      showCustomSnackBar(
          context, 'Purchase updated successfully', SnackBarType.success);
      setState(() {
        _loadPurchase();
      });
    }
  }

  Future<void> _deletePurchase(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this purchase?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).user.token;
      if (token != null) {
        try {
          await PurchaseService().deletePurchase(id, token);

          showCustomSnackBar(
              context, 'Purchase deleted successfully', SnackBarType.success);
          Navigator.of(context).pop(true); // Return to previous screen
        } catch (e) {
          showCustomSnackBar(
              context, 'Failed to delete purchase: $e', SnackBarType.error);
        }
      }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
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
                          _buildDetailRow('Quantity', '${purchase.quantity}'),
                          _buildDetailRow(
                              'Total Harga',
                              NumberFormat.currency(
                                      locale: 'id_ID ', decimalDigits: 2)
                                  .format(purchase.totalPrice)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _editPurchase(purchase),
                        child: Text('Edit'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                      ElevatedButton(
                        onPressed: () => _deletePurchase(purchase.id),
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
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
