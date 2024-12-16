import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/transaksi_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/transaksi_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class FormTransaksiPage extends StatefulWidget {
  final TransaksiModel? transaksi;
  const FormTransaksiPage({super.key, this.transaksi});

  @override
  FormTransaksiPageState createState() => FormTransaksiPageState();
}

class FormTransaksiPageState extends State<FormTransaksiPage> {
  late TextEditingController _amountController;
  late TextEditingController _keteranganController;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _keteranganController = TextEditingController();

    if (widget.transaksi != null) {
      _amountController.text = widget.transaksi!.amount.toString();
      _keteranganController.text = widget.transaksi!.keterangan ?? '';
      _selectedType = widget.transaksi!.type;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(
            widget.transaksi != null
                ? 'Perbarui Transaksi'
                : 'Tambah Transaksi',
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
                    'Informasi Transaksi',
                    style: primaryTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Tipe Transaksi',
                    labelStyle: inputTextStyle,
                    filled: true,
                    fillColor: backgroundColor22,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('Purchase'),
                      value: 'purchase',
                    ),
                    DropdownMenuItem(
                      child: Text('Salary'),
                      value: 'salary',
                    ),
                    DropdownMenuItem(
                      child: Text('Sale'),
                      value: 'sale',
                    ),
                    DropdownMenuItem(
                      child: Text('Other'),
                      value: 'other',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Jumlah',
                  controller: _amountController,
                  hintText: 'Jumlah',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Keterangan',
                  controller: _keteranganController,
                  hintText: 'Keterangan',
                  iconPath: 'assets/icon_name.png',
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.transaksi != null) {
                        await updateTransaksi();
                      } else {
                        await createTransaksi();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.transaksi != null ? 'Update' : 'Tambah',
                      style: primaryTextStyle.copyWith(
                          fontSize: 16, fontWeight: bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (widget.transaksi != null)
                  ElevatedButton(
                    onPressed: () async {
                      await deleteTransaksi();
                    },
                    child: Text('Hapus'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createTransaksi() async {
    final transaksiService = TransaksiService();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    final transaksi = TransaksiModel(
      id: widget.transaksi?.id ?? 0,
      userId: Provider.of<AuthProvider>(context, listen: false).user.id,
      type: _selectedType!,
      amount: double.parse(_amountController.text),
      keterangan: _keteranganController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    try {
      await transaksiService.createTransaction(transaksi, token!);

      showCustomSnackBar(
          context, 'Transaksi berhasil dibuat', SnackBarType.success);
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error: $e');

      showCustomSnackBar(
          context, 'Gagal membuat transaksi', SnackBarType.error);
      Navigator.pop(context, true);
    }
  }

  Future<void> updateTransaksi() async {
    final transaksiService = TransaksiService();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    final transaksi = TransaksiModel(
      id: widget.transaksi!.id,
      userId: widget.transaksi!.userId,
      type: _selectedType!,
      amount: double.parse(_amountController.text),
      keterangan: _keteranganController.text,
      createdAt: widget.transaksi!.createdAt,
      updatedAt: DateTime.now(),
    );
    await transaksiService.updateTransaction(
        widget.transaksi!.id, transaksi, token!);
    Navigator.pop(context);
  }

  Future<void> deleteTransaksi() async {
    final transaksiService = TransaksiService();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    await transaksiService.deleteTransaction(widget.transaksi!.id, token!);
    Navigator.pop(context);
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
