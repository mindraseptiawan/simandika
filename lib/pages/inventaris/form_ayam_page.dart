// lib/pages/form_tambah_ayam_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/header_widget.dart';

class FormTambahAyamPage extends StatefulWidget {
  const FormTambahAyamPage({super.key});

  @override
  _FormTambahAyamPageState createState() => _FormTambahAyamPageState();
}

class _FormTambahAyamPageState extends State<FormTambahAyamPage> {
  final KandangService _kandangService = KandangService();
  List<KandangModel> _kandangs = [];
  KandangModel? _selectedKandang;
  final TextEditingController _jumlahTambahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKandangs();
  }

  Future<void> _loadKandangs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      final kandangs = await _kandangService.getKandangs(token!);
      setState(() {
        _kandangs = kandangs;
      });
    } catch (e) {
      // Handle error
      print('Failed to load kandangs: $e');
    }
  }

  Future<void> _tambahAyam() async {
    if (_selectedKandang == null || _jumlahTambahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih kandang dan masukkan jumlah ayam')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      await _kandangService.tambahAyam(
        _selectedKandang!.id,
        int.parse(_jumlahTambahController.text),
        token!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil menambahkan ayam')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ayam: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Tambah Ayam',
                        style: primaryTextStyle.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<KandangModel>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Kandang',
                        labelStyle: inputTextStyle,
                        filled: true,
                        fillColor: backgroundColor22,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedKandang,
                      items: _kandangs
                          .where((kandang) => kandang.status == true)
                          .map((KandangModel kandang) {
                        return DropdownMenuItem<KandangModel>(
                          value: kandang,
                          child: Text(
                            '${kandang.namaKandang} (${kandang.jumlahReal}/${kandang.kapasitas})',
                            style: inputTextStyle,
                          ),
                        );
                      }).toList(),
                      onChanged: (KandangModel? newValue) {
                        setState(() {
                          _selectedKandang = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _jumlahTambahController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Ayam',
                        labelStyle: primaryTextStyle,
                        hintText: 'Masukkan jumlah ayam ditambahkan',
                        hintStyle: subtitleTextStyle,
                        filled: true,
                        fillColor: backgroundColor22,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: primaryTextStyle,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: _tambahAyam,
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tambah Ayam',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }
}
