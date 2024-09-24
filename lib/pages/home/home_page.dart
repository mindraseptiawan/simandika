import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/pages/inventaris/ayam_page.dart';
import 'package:simandika/pages/inventaris/pakan_page.dart';
import 'package:simandika/pages/keuangan/customer_page.dart';
import 'package:simandika/pages/keuangan/order_page.dart';
import 'package:simandika/pages/keuangan/transaksi_page.dart';
import 'package:simandika/pages/user_management_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pendingCount = 0;
  var _waitCount = 0;
  var _completedCount = 0;
  final OrderService _orderService = OrderService();
  @override
  void initState() {
    super.initState();
    _setStatusBarColor();
    _loadOrdersByStatus();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pop(true);
                } catch (e) {
                  debugPrint('Logout failed: $e');
                  Navigator.of(context).pop(false);
                }
              },
            ),
          ],
        );
      },
    );
    return shouldLogout ?? false;
  }

  Future<void> _loadOrdersByStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    List<OrderModel> pendingOrders =
        await _orderService.getOrdersByStatus(token!, 'pending');
    List<OrderModel> waitOrders =
        await _orderService.getOrdersByStatus(token, 'awaiting_payment');
    List<OrderModel> completedOrders =
        await _orderService.getOrdersByStatus(token, 'completed');

    int pendingCount = pendingOrders.length;
    int waitCount = waitOrders.length;
    int completedCount = completedOrders.length;

    // Update UI dengan jumlah order yang diterima
    setState(() {
      _pendingCount = pendingCount;
      _waitCount = waitCount;
      _completedCount = completedCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    Widget header() {
      return Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logo_text.png', width: 200),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(user.name,
                        style: primaryTextStyle.copyWith(fontSize: 16)),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/notif.png',
              width: 30.0,
              height: 30.0,
            )
          ],
        ),
      );
    }

    Widget dashboard() {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard',
                style: primaryTextStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 75, 73, 73),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Status',
                            style: primaryTextStyle.copyWith(
                                fontSize: 16, fontWeight: bold)),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: _pendingCount
                                      .toDouble(), // Gunakan nilai _pendingCount
                                  color: Colors.blue,
                                  title: 'Pending:$_pendingCount',
                                  titleStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                PieChartSectionData(
                                  value: _completedCount
                                      .toDouble(), // Gunakan nilai _completedCount
                                  color: Colors.green,
                                  title: 'Completed:$_completedCount',
                                  titleStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                PieChartSectionData(
                                  value: _waitCount
                                      .toDouble(), // Gunakan nilai _cancelledCount
                                  color: Colors.red,
                                  title: 'Waiting,$_waitCount',
                                  titleStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chicken Count',
                            style: primaryTextStyle.copyWith(fontSize: 16)),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: [
                                BarChartGroupData(
                                    x: 0, barRods: [BarChartRodData(toY: 100)]),
                                BarChartGroupData(
                                    x: 1, barRods: [BarChartRodData(toY: 150)]),
                                BarChartGroupData(
                                    x: 2, barRods: [BarChartRodData(toY: 200)]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget menuItem(String title, Widget icon, VoidCallback onTap) {
      return ListTile(
        leading: icon,
        title: Text(title, style: primaryTextStyle),
        onTap: onTap,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await _onWillPop();
        if (value) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                header(),
                dashboard(),
                menuItem('Dashboard',
                    Icon(Icons.dashboard, color: primaryColor), () {}),
                menuItem(
                    'Transaksi', Icon(Icons.access_time, color: primaryColor),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransaksiPage()),
                  );
                }),
                menuItem('Order', Icon(Icons.add_box, color: primaryColor), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderPage()),
                  );
                }),
                menuItem('Ayam',
                    Image.asset('assets/ayama.png', width: 24, height: 24), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AyamPage()),
                  );
                }),
                menuItem('Pakan', Icon(Icons.grass, color: primaryColor), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PakanPage()),
                  );
                }),
                menuItem('Customer', Icon(Icons.people, color: primaryColor),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomerPage()),
                  );
                }),
                menuItem(
                    'User Settings', Icon(Icons.settings, color: primaryColor),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserManagementPage()),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
