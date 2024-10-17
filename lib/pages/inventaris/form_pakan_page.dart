import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/pakan_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/pakan_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class FormPakanPage extends StatefulWidget {
  final PakanModel? pakan;

  const FormPakanPage({super.key, this.pakan});

  @override
  FormPakanPageState createState() => FormPakanPageState();
}

class FormPakanPageState extends State<FormPakanPage> {
  late TextEditingController _jenisController;
  late TextEditingController _sisaController;
  late TextEditingController _keteranganController;

  @override
  void initState() {
    super.initState();

    _jenisController = TextEditingController(
      text: widget.pakan?.jenis ?? '',
    );
    _sisaController = TextEditingController(
      text: widget.pakan?.sisa.toString() ?? '',
    );
    _keteranganController = TextEditingController(
      text: widget.pakan?.keterangan ?? '',
    );
  }

  Future<void> _savePakan() async {
    final pakanService = PakanService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    final newPakan = PakanModel(
      id: widget.pakan?.id ?? 0,
      jenis: _jenisController.text,
      sisa: int.parse(_sisaController.text),
      keterangan: _keteranganController.text,
    );

    try {
      if (widget.pakan == null) {
        await pakanService.addPakan(newPakan, token!);

        showCustomSnackBar(
            context, 'Pakan berhasil ditambahkan!', SnackBarType.success);
        Navigator.pop(context, true);
      } else {
        await pakanService.updatePakan(newPakan.id, newPakan, token!);

        showCustomSnackBar(
            context, 'Pakan berhasil diperbarui!', SnackBarType.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      showCustomSnackBar(
          context, 'Gagal menyimpan data pakan!', SnackBarType.error);
      Navigator.pop(context, false);
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: _savePakan,
        style: TextButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.pakan == null ? 'Tambah' : 'Update',
          style: primaryTextStyle.copyWith(fontSize: 16, fontWeight: bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(
            widget.pakan == null ? 'Form Pakan Ayam' : 'Edit Pakan Ayam',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.pakan == null ? 'Informasi Pakan' : 'Edit Pakan',
                    style: primaryTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Jenis Pakan',
                  controller: _jenisController,
                  hintText: 'Jenis Pakan',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Sisa Pakan',
                  controller: _sisaController,
                  hintText: 'Sisa Pakan',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Keterangan',
                  controller: _keteranganController,
                  hintText: 'Keterangan',
                  iconPath: 'assets/icon_name.png',
                ),

                const SizedBox(height: 50),
                _buildSaveButton(), // Use the custom button here
              ],
            ),
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
                Image.asset(iconPath, width: 17, color: iconColor)
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
