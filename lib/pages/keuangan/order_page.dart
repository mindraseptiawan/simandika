import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/pages/keuangan/form_order_page.dart';
import 'package:simandika/pages/keuangan/order_detail_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/theme.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late Future<List<OrderModel>> _orderData;
  List<OrderModel> _orders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _priceSetOrders = [];
  List<OrderModel> _awaitingPaymentOrders = [];
  List<OrderModel> _paymentVerificationsOrders = [];
  List<OrderModel> _completedOrders = [];
  bool _showFab = true;

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showFab = _tabController.index == 0;
      });
    });

    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _orderData = OrderService().getAllOrders(token);
      _orderData.then((data) {
        setState(() {
          data.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          _orders = data;
          _filterOrders();
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
    _tabController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _pendingOrders = _filterOrdersByStatus('pending', query);
      _priceSetOrders = _filterOrdersByStatus('price_set', query);
      _awaitingPaymentOrders = _filterOrdersByStatus('awaiting_payment', query);
      _paymentVerificationsOrders =
          _filterOrdersByStatus('payment_verification', query);
      _completedOrders = _filterOrdersByStatus('completed', query);
    });
  }

  List<OrderModel> _filterOrdersByStatus(String status, String query) {
    return _orders.where((order) {
      final dateString = '${order.day}-${order.month}-${order.year}';
      final statusLower = order.status.toLowerCase();
      return (dateString.contains(query) || statusLower.contains(query)) &&
          order.status == status;
    }).toList();
  }

  void _refreshOrders() {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      setState(() {
        _orderData = OrderService().getAllOrders(token);
        _orderData.then((data) {
          setState(() {
            data.sort((a, b) => b.orderDate.compareTo(a.orderDate));
            _orders = data;
            _filterOrders();
          });
        });
      });
    }
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

  Widget _buildOrderList(List<OrderModel> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(orderId: order.id),
              ),
            );
            if (result == true) {
              _refreshOrders();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order List', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Price Set'),
            Tab(text: 'Awaiting Payment'),
            Tab(text: 'Verification Payment'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Order',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_pendingOrders),
                _buildOrderList(_priceSetOrders),
                _buildOrderList(_awaitingPaymentOrders),
                _buildOrderList(_paymentVerificationsOrders),
                _buildOrderList(_completedOrders),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormOrderPage(),
                  ),
                );
                if (result == true) {
                  _refreshOrders();
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset(
                'assets/icon_tambah.png',
                fit: BoxFit.cover,
              ),
            )
          : null,
    );
  }
}
