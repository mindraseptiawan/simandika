import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/models/sale_model.dart';
import 'package:simandika/pages/keuangan/form_order_page.dart';
import 'package:simandika/pages/keuangan/order_detail_page.dart';
import 'package:simandika/pages/pdf_preview.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/sale_pdf_generator.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late Future<List<OrderModel>> _orderData;
  List<OrderModel> _orders = [];
  List<SaleModel> filteredSales = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _priceSetOrders = [];
  List<OrderModel> _awaitingPaymentOrders = [];
  List<OrderModel> _paymentVerificationsOrders = [];
  List<OrderModel> _completedOrders = [];
  bool _showFab = true;
  String reportType = 'Penjualan';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateAndPreviewPDF() async {
    if (_orders.isEmpty) {
      showCustomSnackBar(
          context, 'Tidak ada order untuk dibuat PDF', SnackBarType.error);
      return;
    }

    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token == null) {
      showCustomSnackBar(
          context, 'Tidak dapat mengakses token', SnackBarType.error);
      return;
    }

    final pdfBytes = await generateSalesPDF(
        filteredSales, _startDate, _endDate, token, reportType);
    final fileName =
        'orders_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(
          pdfBytes: pdfBytes,
          fileName: fileName,
          reportTitle: 'Laporan Order',
        ),
      ),
    );
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

  final statusMap = {
    'awaiting_payment': 'Awaiting Payment',
    'payment_verification': 'Verification Payment',
    'price_set': 'Price Set',
    'pending': 'Pending',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

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
                          'Order ID #${order.id}',
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
                          statusMap[order.status] ?? order.status,
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
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Order List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () async {
              await _selectDateRange();
              await _generateAndPreviewPDF();
            },
            child: const Text('PDF',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Order ...',
                suffixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
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
