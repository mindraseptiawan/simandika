import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/pages/inventaris/detail_kandang_page.dart';
import 'package:simandika/pages/inventaris/form_ayam_page.dart';
import 'package:simandika/pages/keuangan/form_purchase_page.dart';
// import 'package:simandika/pages/functional_menu.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/pages/inventaris/form_kandang_page.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/models/kandang_model.dart';

class KandangPage extends StatefulWidget {
  const KandangPage({super.key});

  @override
  State<KandangPage> createState() => _KandangPageState();
}

class _KandangPageState extends State<KandangPage> {
  List<KandangModel> kandangData = [];
  final KandangService _kandangService = KandangService();

  @override
  void initState() {
    super.initState();
    getKandangs();
    _setStatusBarColor();
  }

  Future<void> getKandangs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    try {
      List<KandangModel> kandangs = await _kandangService.getKandangs(token!);
      if (!mounted) return;
      setState(() {
        kandangData = kandangs;
      });
    } catch (e) {
      if (mounted) {
        // Handle errors and refresh token if needed
        debugPrint('Failed to load kandangs: $e');
        // Optionally show a message or refresh token if needed
      }
    }
  }

  Future<void> refreshKandangs() async {
    await getKandangs();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void navigateToFormKandangPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormKandangPage(),
      ),
    ).then((result) {
      if (result == true) {
        getKandangs();
      }
    });
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
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    Widget header() {
      // Ensure the URL does not start with a /
      // String imageUrl = user.profilePhotoUrl?.replaceFirst(RegExp(r'^/'), '') ??
      //     'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&color=7F9CF5&background=EBF4FF';

      // // Debug debugPrint statement to ensure URL is correct
      // debugPrint('Image URL: $imageUrl');

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

    Widget kandangNull() {
      return Center(
        // Center the widget horizontally in the available space
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(
              maxWidth: 400, // Optional: Set a maximum width if needed
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Make sure the container fits the content
              children: [
                const Text(
                  'Belum Memiliki Kandang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan kandang Anda untuk dikelola',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: navigateToFormKandangPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[300],
                    ),
                  ),
                  child: const Text('Tambah Kandang'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget kandangList(List<KandangModel> kandangData) {
      var activeKandangData =
          kandangData.where((kandang) => kandang.status).toList();

      return Container(
        margin: const EdgeInsets.only(top: 14),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: activeKandangData.length,
          itemBuilder: (context, index) {
            var kandang = activeKandangData[index];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          kandangName: kandang.namaKandang,
                          kandangId: kandang.id,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(
                      10), // Border radius for ripple effect
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6, // Vertical spacing between each container
                      horizontal:
                          8, // Horizontal spacing between container and screen edges
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor, // Menggunakan secondaryColor
                      borderRadius: BorderRadius.circular(
                          10), // Mengatur borderRadius menjadi 10
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kandang.namaKandang,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/aktif.png',
                                  width: 30.0,
                                  height: 30.0,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Aktif",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Image.asset(
                                  'assets/ayamo.png',
                                  width: 30.0,
                                  height: 30.0,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  kandang.jumlahReal.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Jarak antar list item
              ],
            );
          },
        ),
      );
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: backgroundColor1,
          body: SafeArea(
            child: Column(
              children: [
                header(),
                Expanded(
                  child: kandangData.isEmpty
                      ? kandangNull()
                      : kandangList(kandangData),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormPurchasePage(),
                ),
              );

              if (result == true) {
                refreshKandangs(); // Refresh kandang list
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Image.asset(
              'assets/icon_tambah.png',
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}
