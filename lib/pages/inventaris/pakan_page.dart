import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/pakan_model.dart';
import 'package:simandika/pages/inventaris/form_pakan_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/pakan_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class PakanPage extends StatefulWidget {
  const PakanPage({super.key});

  @override
  PakanPageState createState() => PakanPageState();
}

class PakanPageState extends State<PakanPage> {
  final PakanService pakanService = PakanService();
  List<PakanModel> pakans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPakan();
  }

  Future<void> getPakan() async {
    setState(() {
      isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      pakans = await pakanService.getPakan(token!);
    } catch (e) {
      showCustomSnackBar(context, 'Failed to load pakan!', SnackBarType.error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePakan(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      await pakanService.deletePakan(id, token!);
      getPakan();
    } catch (e) {
      showCustomSnackBar(
          context, 'Failed to delete pakan!', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Pakan',
            style: primaryTextStyle.copyWith(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: backgroundColor1, // Atur warna latar belakang di sini
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Menambahkan jarak di atas item pertama
                    const SizedBox(
                        height: 8), // Atur tinggi jarak sesuai kebutuhan
                    Expanded(
                      child: ListView.builder(
                        itemCount: pakans.length,
                        itemBuilder: (context, index) {
                          final pakan = pakans[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(pakan.jenis,
                                  style: primaryTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: bold,
                                      fontSize: 20)),
                              subtitle: Text('${pakan.sisa} Kg',
                                  style: primaryTextStyle.copyWith(
                                      color: Colors.white)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FormPakanPage(pakan: pakan),
                                        ),
                                      );
                                      if (result == true) {
                                        getPakan(); // Refresh the list if data was updated
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () => deletePakan(pakan.id),
                                  ),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormPakanPage(),
            ),
          );
          if (result == true) {
            getPakan(); // Refresh the list if data was saved
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Image.asset(
          'assets/icon_tambah.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
