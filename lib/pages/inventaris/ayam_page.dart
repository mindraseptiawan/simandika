import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/pages/inventaris/form_kandang_page.dart'; // Import FormAyamPage
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/header_widget.dart'; // Import Header widget

class AyamPage extends StatefulWidget {
  const AyamPage({super.key});

  @override
  AyamPageState createState() => AyamPageState();
}

class AyamPageState extends State<AyamPage> {
  final KandangService kandangService = KandangService();
  List<KandangModel> kandangs = [];

  @override
  void initState() {
    super.initState();
    getKandangs();
  }

  Future<void> getKandangs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      kandangs = await kandangService.getKandangs(token!);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _navigateToFormPage({KandangModel? kandang}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormKandangPage(kandang: kandang),
      ),
    );

    if (result == true) {
      getKandangs(); // Refresh the list if successful

      showCustomSnackBar(
          context,
          kandang == null
              ? 'Kandang added successfully'
              : 'Kandang updated successfully',
          SnackBarType.success);
    } else if (result == false) {
      showCustomSnackBar(
          context,
          'Failed to ${kandang == null ? 'add' : 'update'} kandang!',
          SnackBarType.success);
    }
  }

  Future<void> addKandang() async {
    _navigateToFormPage();
  }

  Future<void> editKandang(KandangModel kandang) async {
    _navigateToFormPage(kandang: kandang);
  }

  Future<void> deleteKandang(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      await kandangService.deleteKandang(id, token!);
      getKandangs();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Icon _statusIcon(bool isActive) {
    return Icon(
      isActive ? Icons.check_circle : Icons.cancel,
      color: isActive ? const Color.fromARGB(255, 237, 241, 237) : Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Kandang Ayam',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kandang list view
            Expanded(
              child: ListView.builder(
                itemCount: kandangs.length,
                itemBuilder: (context, index) {
                  KandangModel kandang = kandangs[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical spacing between each container
                      horizontal:
                          8, // Horizontal spacing between container and screen edges
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor, // Background color
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: ListTile(
                      title: Text(
                        kandang.namaKandang,
                        style: judulTextStyle, // Apply text style
                      ),
                      subtitle: Text(
                        'Operator: ${kandang.operator}',
                        style: primaryTextStyle, // Apply text style to subtitle
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Add status icon
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                            onPressed: () {
                              editKandang(kandang);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.white,
                            onPressed: () {
                              deleteKandang(kandang.id);
                            },
                          ),
                          _statusIcon(kandang.status),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addKandang,
        backgroundColor:
            Colors.transparent, // Remove the default background color
        elevation: 0,
        child: Image.asset(
          'assets/icon_tambah.png',
          fit: BoxFit.cover, // Ensure the image fits properly
        ), // Remove shadow if desired
      ),
    );
  }
}
