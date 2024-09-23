import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/theme.dart';

class DetailOrderPage extends StatefulWidget {
  final String customerName;
  final int customerId;
  const DetailOrderPage(
      {super.key, required this.customerId, required this.customerName});

  @override
  DetailOrderPageState createState() => DetailOrderPageState();
}

class DetailOrderPageState extends State<DetailOrderPage> {
  late Future<List<OrderModel>> _orderData;
  List<OrderModel> _orders = []; // To store all Orders
  List<OrderModel> _filteredOrders = [];
  // ignore: unused_field
  final String _searchQuery = '';
  final TextEditingController _searchController =
      TextEditingController(); // For future search filter

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _orderData =
          OrderService().getOrdersByCustomerId(token, widget.customerId);
      _orderData.then((data) {
        setState(() {
          data.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          _orders = data;
          _filteredOrders = data;
        });
      });
    } else {
      _orderData = Future.error('Invalid token');
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
      _filteredOrders = _orders.where((order) {
        final dateString = '${order.day}-${order.month}-${order.year}';
        final statusLower = order.status.toLowerCase();
        return dateString.contains(query) || statusLower.contains(query);
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
      appBar: AppBar(
        title: Text(widget.customerName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              // Action for PDF button
            },
            child: const Text('PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                hintText: 'Cari order ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Display the transaction list
            Expanded(
              child: FutureBuilder<List<OrderModel>>(
                future: _orderData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data Kosong'));
                  } else {
                    // Display all orders for now

                    return ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];

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
                                            order.day.toString(),
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _formatMonth(order.month),
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${order.year}',
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
                                          '${order.day} ${_formatMonth(order.month)} ${order.year}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          order.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Jumlah Ayam: ${order.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [

                                  //   ],
                                  // ),
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
