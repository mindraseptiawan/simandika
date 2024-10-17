import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class FormOrderPage extends StatefulWidget {
  final OrderModel? order;
  const FormOrderPage({super.key, this.order});

  @override
  FormOrderPageState createState() => FormOrderPageState();
}

class FormOrderPageState extends State<FormOrderPage> {
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _quantityController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();

    _customerNameController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _quantityController = TextEditingController();
    _alamatController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _quantityController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    final orderData = {
      'customer_name': _customerNameController.text,
      'customer_phone': _customerPhoneController.text,
      'quantity': int.parse(_quantityController.text),
      'alamat': _alamatController.text,
    };

    try {
      await OrderService().createOrder(orderData, token!);
      showCustomSnackBar(
          context, 'Order berhasil dibuat', SnackBarType.success);
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error: $e');
      showCustomSnackBar(context, 'Gagal mmmembuat order!', SnackBarType.error);
      Navigator.pop(context, true);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Form Tambah Order',
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
                    'Informasi Order',
                    style: primaryTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Nama Customer',
                  controller: _customerNameController,
                  hintText: 'Nama Customer',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'No Telepon Customer',
                  controller: _customerPhoneController,
                  hintText: 'No Telepon Customer',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Alamat Customer',
                  controller: _alamatController,
                  hintText: 'Alamat Customer',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Jumlah Ayam',
                  controller: _quantityController,
                  hintText: 'Jumlah Order',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _saveOrder,
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kirim Order',
                      style: primaryTextStyle.copyWith(
                          fontSize: 16, fontWeight: bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
