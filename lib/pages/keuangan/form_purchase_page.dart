import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class FormPurchasePage extends StatefulWidget {
  final PurchaseModel? purchase;
  const FormPurchasePage({Key? key, this.purchase}) : super(key: key);

  @override
  FormPurchasePageState createState() => FormPurchasePageState();
}

class FormPurchasePageState extends State<FormPurchasePage> {
  late TextEditingController _supplierNameController;
  late TextEditingController _supplierPhoneController;
  late TextEditingController _quantityController;
  late TextEditingController _alamatController;
  late TextEditingController _priceController;
  KandangModel? _selectedKandang;
  List<KandangModel> _kandangs = [];
  final KandangService _kandangService = KandangService();

  @override
  void initState() {
    super.initState();
    _loadKandangs();
    _supplierNameController =
        TextEditingController(text: widget.purchase?.supplier?.name ?? '');
    _supplierPhoneController =
        TextEditingController(text: widget.purchase?.supplier?.phone ?? '');
    _quantityController =
        TextEditingController(text: widget.purchase?.quantity.toString() ?? '');
    _alamatController =
        TextEditingController(text: widget.purchase?.supplier?.alamat ?? '');
    _priceController = TextEditingController(
        text: widget.purchase?.pricePerUnit.toString() ?? '');
  }

  Future<void> _loadKandangs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      final kandangs = await _kandangService.getKandangs(token!);
      setState(() {
        _kandangs = kandangs;
        if (widget.purchase != null && _kandangs.isNotEmpty) {
          _selectedKandang = _kandangs.firstWhere(
            (kandang) => kandang.id == widget.purchase!.kandangId,
            orElse: () => _kandangs.first,
          );
        }
      });
    } catch (e) {
      print('Failed to load kandangs: $e');
    }
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierPhoneController.dispose();
    _quantityController.dispose();
    _alamatController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    if (_selectedKandang == null) {
      showCustomSnackBar(context, 'Pilih kandang dan masukkan jumlah ayam',
          SnackBarType.error);
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    // Validate and parse input
    int? quantity = int.tryParse(_quantityController.text);
    double? pricePerUnit = double.tryParse(_priceController.text);

    if (quantity == null || pricePerUnit == null) {
      showCustomSnackBar(context, 'Jumlah dan harga harus berupa angka valid',
          SnackBarType.error);
      return;
    }

    final purchaseData = {
      'supplier_name': _supplierNameController.text,
      'supplier_phone': _supplierPhoneController.text,
      'quantity': quantity,
      'alamat': _alamatController.text,
      'price_per_unit': pricePerUnit,
      'kandang_id': _selectedKandang!.id,
    };

    try {
      if (widget.purchase == null) {
        await PurchaseService().createPurchase(purchaseData, token!);

        showCustomSnackBar(
            context, 'Pembelian berhasil dibuat', SnackBarType.success);
      } else {
        final updatedPurchase = await PurchaseService()
            .updatePurchase(widget.purchase!.id, purchaseData, token!);
        debugPrint(
            'Updated purchase: $updatedPurchase'); // Log pembelian yang diperbarui
        showCustomSnackBar(
            context, 'Order berhasil diperbarui', SnackBarType.success);
      }
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error: $e');

      showCustomSnackBar(
          context,
          'Gagal ${widget.purchase == null ? 'membuat' : 'memperbarui'} order: ${e.toString()}',
          SnackBarType.error);
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
        title: Text(
            widget.purchase == null
                ? 'Form Pembelian Ayam'
                : 'Edit Pembelian Ayam',
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
                    widget.purchase == null
                        ? 'Informasi Purchase'
                        : 'Edit Purchase',
                    style: primaryTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Nama supplier',
                  controller: _supplierNameController,
                  hintText: 'Nama supplier',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'No Telepon supplier',
                  controller: _supplierPhoneController,
                  hintText: 'No Telepon supplier',
                  iconPath: 'assets/icon_name.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Alamat supplier',
                  controller: _alamatController,
                  hintText: 'Alamat supplier',
                  iconPath: 'assets/alamat.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Jumlah Ayam',
                  controller: _quantityController,
                  hintText: 'Jumlah Order',
                  iconPath: 'assets/jumlah.png',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Harga Per Ayam',
                  controller: _priceController,
                  hintText: 'Harga Ayam',
                  iconPath: 'assets/jumlah.png',
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
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _savePurchase,
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.purchase == null
                          ? 'Masukkan Pembelian Ayam'
                          : 'Perbarui Pembelian Ayam',
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
