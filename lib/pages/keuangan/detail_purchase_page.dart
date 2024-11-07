import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';

class DetailPurchasePage extends StatefulWidget {
  final String supplierName;
  final int supplierId;
  const DetailPurchasePage(
      {super.key, required this.supplierId, required this.supplierName});

  @override
  DetailPurchasePageState createState() => DetailPurchasePageState();
}

class DetailPurchasePageState extends State<DetailPurchasePage> {
  late Future<List<PurchaseModel>> _purchaseData;
  List<PurchaseModel> _purchases = []; // To store all Orders
  List<PurchaseModel> _filteredPurchases = [];
  // ignore: unused_field
  final String _searchQuery = '';
  final TextEditingController _searchController =
      TextEditingController(); // For future search filter

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _purchaseData =
          PurchaseService().getPurchaseBySupplierId(token, widget.supplierId);
      _purchaseData.then((data) {
        setState(() {
          data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _purchases = data;
          _filteredPurchases = data;
        });
      });
    } else {
      _purchaseData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        final dateString = '${purchase.day}-${purchase.month}-${purchase.year}';

        return dateString.contains(query);
      }).toList();
    });
  }

  String _formatMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(widget.supplierName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar for future search/filter
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Filtering is handled by listener
              },
              decoration: InputDecoration(
                hintText: 'Cari purchase ...',
                suffixIcon: const Icon(Icons.search),
                filled: true, // Enable filling
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Display the transaction list
            Expanded(
              child: FutureBuilder<List<PurchaseModel>>(
                future: _purchaseData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Data Kosong',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)));
                  } else {
                    // Display all orders for now

                    return ListView.builder(
                      itemCount: _filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _filteredPurchases[index];

                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         DetailPemeliharaanPage(pemeliharaan: pemeliharaan),
                            //   ),
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            purchase.day.toString(),
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _formatMonth(purchase.month),
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${purchase.year}',
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${purchase.day} ${_formatMonth(purchase.month)} ${purchase.year}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Jumlah Ayam: ${purchase.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Total Price: ${NumberFormat.currency(locale: 'id_ID', decimalDigits: 2).format(purchase.totalPrice)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
