import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/pages/inventaris/ayam_page.dart';
import 'package:simandika/pages/inventaris/stock_movement_page.dart';
import 'package:simandika/pages/keuangan/activity_log_page.dart';
import 'package:simandika/pages/keuangan/customer_page.dart';
import 'package:simandika/pages/inventaris/pakan_page.dart';
import 'package:simandika/pages/keuangan/dashboard_page.dart';
import 'package:simandika/pages/keuangan/dashboard_inventaris.dart';
import 'package:simandika/pages/keuangan/order_page.dart';
import 'package:simandika/pages/keuangan/purchase_page.dart';
import 'package:simandika/pages/keuangan/supplier_page.dart';
import 'package:simandika/pages/keuangan/transaksi_page.dart';
import 'package:simandika/pages/user_management_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/header_widget.dart';

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  LayananPageState createState() => LayananPageState();
}

class LayananPageState extends State<LayananPage> {
  Future<bool> _onWillPop() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfimasi Keluar'),
          content: const Text('Apakah anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pop(true);
                } catch (e) {
                  // Handle error (e.g., show a message to the user)
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

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _navigateToPage(context, index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              _getIconForIndex(index),
                              const SizedBox(width: 16),
                              Text(
                                _getTextForIndex(index),
                                style: primaryTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DashboardPage()));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SupplierAverageSusutPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TransaksiPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const OrderPage()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PurchasePage()));
        break;
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AyamPage()));
        break;
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StockMovementPage()));
        break;
      case 7:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PakanPage()));
        break;
      case 8:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerPage()));
        break;
      case 9:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SupplierPage()));
        break;
      case 10:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementPage()));
      case 11:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ActivityLogPage()));
        break;
      case 12:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementPage()));
        break;
    }
  }

  Widget _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Image.asset(
          'assets/dashboard.png',
          width: 30.0,
          height: 30.0,
        );
      case 1:
        return Image.asset(
          'assets/dashboard.png',
          width: 30.0,
          height: 30.0,
        );
      case 2:
        return Image.asset(
          'assets/transaksi.png',
          width: 30.0,
          height: 30.0,
        );
      case 3:
        return Image.asset(
          'assets/order.png',
          width: 30.0,
          height: 30.0,
        );
      case 4:
        return Image.asset(
          'assets/purchase.png',
          width: 30.0,
          height: 30.0,
        );
      case 5:
        return Image.asset(
          'assets/kandang.png',
          width: 30.0,
          height: 30.0,
        );
      case 6:
        return Image.asset(
          'assets/ayamo.png',
          width: 30.0,
          height: 30.0,
        );
      case 7:
        return Image.asset(
          'assets/stokpakan.png',
          width: 30.0,
          height: 30.0,
        );
      case 8:
        return Image.asset(
          'assets/customer.png',
          width: 30.0,
          height: 30.0,
        );
      case 9:
        return Image.asset(
          'assets/customer.png',
          width: 30.0,
          height: 30.0,
        );
      case 10:
        return Image.asset(
          'assets/stokpakan.png',
          width: 30.0,
          height: 30.0,
        );
      case 11:
        return Icon(Icons.account_balance_wallet);
      case 12:
        return Icon(Icons.assignment_add);
      default:
        return Icon(Icons.help);
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard Keuangan';
      case 1:
        return 'Dashboard Inventaris';
      case 2:
        return 'Transaksi';
      case 3:
        return 'Order';
      case 4:
        return 'Pembelian';
      case 5:
        return 'Kandang Ayam';
      case 6:
        return 'Stok Ayam';
      case 7:
        return 'Pakan';
      case 8:
        return 'Customer';
      case 9:
        return 'Supplier';
      case 10:
        return 'Pengaturan User';
      case 11:
        return 'Log Aktivitas';
      case 12:
        return 'Laporan Inventaris';
      default:
        return 'Menu';
    }
  }
}
