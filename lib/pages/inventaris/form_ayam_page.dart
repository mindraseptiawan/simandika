import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/header_widget.dart';

class FormAyamPage extends StatefulWidget {
  final KandangModel? kandang;

  const FormAyamPage({super.key, this.kandang});

  @override
  FormAyamPageState createState() => FormAyamPageState();
}

class FormAyamPageState extends State<FormAyamPage> {
  late TextEditingController _namaKandangController;
  late TextEditingController _operatorController;
  late TextEditingController _lokasiController;
  late TextEditingController _kapasitasController;
  late TextEditingController _jumlahRealController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _namaKandangController = TextEditingController(
      text: widget.kandang?.namaKandang ?? '',
    );
    _operatorController = TextEditingController(
      text: widget.kandang?.operator ?? '',
    );
    _lokasiController = TextEditingController(
      text: widget.kandang?.lokasi ?? '',
    );
    _kapasitasController = TextEditingController(
      text: widget.kandang?.kapasitas.toString() ?? '',
    );
    _jumlahRealController = TextEditingController(
      text: widget.kandang?.jumlahReal.toString() ?? '',
    );
    _isActive = widget.kandang?.status ?? true;
  }

  Future<void> _saveKandang() async {
    final kandangService = KandangService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    final newKandang = KandangModel(
      id: widget.kandang?.id ?? 0,
      namaKandang: _namaKandangController.text,
      operator: _operatorController.text,
      lokasi: _lokasiController.text,
      kapasitas: int.parse(_kapasitasController.text),
      jumlahReal: int.parse(_jumlahRealController.text),
      status: _isActive,
    );

    try {
      if (widget.kandang == null) {
        await kandangService.addKandang(newKandang, token!);
        Navigator.pop(context, true);
      } else {
        await kandangService.updateKandang(newKandang.id, newKandang, token!);
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint(
          'Failed to ${widget.kandang == null ? 'add' : 'update'} kandang: $e');
      Navigator.pop(context, false);
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: _saveKandang,
        style: TextButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.kandang == null ? 'Tambah' : 'Update',
          style: primaryTextStyle.copyWith(fontSize: 16, fontWeight: bold),
        ),
      ),
    );
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
                        'Informasi Kandang',
                        style: primaryTextStyle.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Nama Kandang',
                      controller: _namaKandangController,
                      hintText: 'Nama Kandang',
                      iconPath: 'assets/icon_name.png',
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Operator',
                      controller: _operatorController,
                      hintText: 'Operator',
                      iconPath: 'assets/icon_name.png',
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                        label: 'Lokasi',
                        controller: _lokasiController,
                        hintText: 'Lokasi',
                        icon: const Icon(Icons.location_on),
                        Color: iconColor
                        // iconPath: 'assets/icon_name.png',
                        ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Kapasitas',
                      controller: _kapasitasController,
                      hintText: 'Kapasitas',
                      iconPath: 'assets/ayam.png',
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                        label: 'Jumlah Real',
                        controller: _jumlahRealController,
                        hintText: 'Jumlah Real',
                        icon: const Icon(Icons.numbers)
                        // iconPath: 'assets/icon_name.png',
                        ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Status',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.redAccent,
                        ),
                        Text(
                          _isActive ? 'Aktif' : 'Tidak Aktif',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: medium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    _buildSaveButton(), // Use the custom button here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? iconPath, // Make this optional
    Icon? icon, // Make this optional
    Color? Color, // Add this parameter
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(fontSize: 16, fontWeight: medium),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor22,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (iconPath != null)
                Image.asset(
                  iconPath,
                  width: 17,
                  color: iconColor, // Apply color to iconPath if needed
                )
              else if (icon != null)
                Icon(
                  icon.icon, // Use the icon data
                  color: iconColor, // Apply color to icon if provided
                ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: subtitleTextStyle,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
