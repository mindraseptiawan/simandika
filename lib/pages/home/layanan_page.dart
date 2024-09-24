import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/pages/keuangan/customer_page.dart';
import 'package:simandika/pages/inventaris/pakan_page.dart';
import 'package:simandika/pages/keuangan/order_page.dart';
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
                    itemCount: 8,
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
                              Icon(
                                _getIconForIndex(index),
                                color: Colors.white,
                                size: 40,
                              ),
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
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const Page1()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TransaksiPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const OrderPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PakanPage()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerPage()));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementPage()));
      case 6:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementPage()));
        break;
      case 7:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementPage()));
        break;
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.bar_chart;
      case 1:
        return Icons.access_time;
      case 2:
        return Icons.add_box;
      case 3:
        return Icons.add_box;
      case 4:
        return Icons.add_box;
      case 5:
        return Icons.supervised_user_circle;
      case 6:
        return Icons.account_balance_wallet;
      case 7:
        return Icons.assignment_add;
      default:
        return Icons.help;
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Transaksi';
      case 2:
        return 'Order';
      case 3:
        return 'Pakan';
      case 4:
        return 'Customer';
      case 5:
        return 'User Settings';
      case 6:
        return 'Laporan Keuangan';
      case 7:
        return 'Laporan Inventaris';
      default:
        return 'Menu';
    }
  }
}
