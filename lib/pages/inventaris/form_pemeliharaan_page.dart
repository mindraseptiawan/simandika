import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/services/pakan_service.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/models/pakan_model.dart';

class FormPemeliharaanPage extends StatefulWidget {
  final PemeliharaanModel? pemeliharaan;
  final KandangModel? kandang;
  final int? kandangId;

  const FormPemeliharaanPage(
      {super.key, this.pemeliharaan, this.kandangId, this.kandang});

  @override
  FormPemeliharaanPageState createState() => FormPemeliharaanPageState();
}

class FormPemeliharaanPageState extends State<FormPemeliharaanPage> {
  late TextEditingController _jumlahAyamController;
  late TextEditingController _jumlahPakanController;
  late TextEditingController _matiController;
  late TextEditingController _keteranganController;

  String? _selectedJenisPakan;
  int? _selectedPurchase;
  List<PakanModel> _pakanList = [];
  List<PurchaseModel> _purchaseList = [];
  int? _stokPakan;
  int? _kapasitasKandang;

  @override
  void initState() {
    super.initState();
    _jumlahAyamController = TextEditingController(
      text: widget.pemeliharaan?.jumlahAyam.toString() ?? '',
    );
    _jumlahPakanController = TextEditingController(
      text: widget.pemeliharaan?.jumlahPakan?.toString() ?? '',
    );
    _matiController = TextEditingController(
      text: widget.pemeliharaan?.mati?.toString() ?? '',
    );
    _keteranganController = TextEditingController(
      text: widget.pemeliharaan?.keterangan ?? '',
    );

    if (widget.pemeliharaan == null && widget.kandang != null) {
      _jumlahAyamController.text = widget.kandang!.jumlahReal.toString();
    }

    if (widget.kandang != null) {
      setState(() {
        _kapasitasKandang = widget.kandang!.kapasitas;
      });
    }

    _loadPurchaseData();
    _loadPakanData();
    if (widget.kandang == null && widget.kandangId != null) {
      _loadKandangData();
    }
  }

  Future<void> _loadPakanData() async {
    try {
      final pakanService = PakanService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user.token;
      final pakanList = await pakanService.getPakan(token!);

      // Debugging: Print pakan data
      debugPrint(
          'Pakan List: ${pakanList.map((pakan) => '${pakan.jenis}: ${pakan.sisa}').toList()}');
      if (!mounted) return;
      setState(() {
        _pakanList = pakanList;

        if (_pakanList.isEmpty) {
          showCustomSnackBar(context, 'Anda Belum menambahkan Stok pakan!',
              SnackBarType.error);
        }

        if (widget.pemeliharaan != null) {
          _selectedJenisPakan = _pakanList
              .firstWhere(
                  (pakan) => pakan.id == widget.pemeliharaan?.jenisPakanId,
                  orElse: () => PakanModel(id: 0, jenis: ''))
              .jenis;
          _stokPakan = _pakanList
              .firstWhere((pakan) => pakan.jenis == _selectedJenisPakan,
                  orElse: () => PakanModel(id: 0, jenis: ''))
              .sisa;
          debugPrint('Selected Jenis Pakan: $_selectedJenisPakan');
        }
      });
    } catch (e) {
      debugPrint('Failed to load pakan data: $e');
      if (mounted) {
        showCustomSnackBar(
            context, 'Failed to load pakan data!', SnackBarType.error);
      }
    }
  }

  Future<void> _loadPurchaseData() async {
    try {
      final purchaseService = PurchaseService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user.token;
      final purchaseList = await purchaseService.getPurchaseByKandangId(
          widget.kandangId!, token!);

      debugPrint(
          'Batch List: ${purchaseList.map((purchase) => '${purchase.id}: ${purchase.currentStock}').toList()}');
      if (!mounted) return;
      setState(() {
        _purchaseList = purchaseList;

        if (_purchaseList.isEmpty) {
          showCustomSnackBar(context, 'Anda Belum menambahkan Batch Ayam!',
              SnackBarType.error);
        }

        if (widget.pemeliharaan != null) {
          _selectedPurchase = _purchaseList
              .firstWhere(
                  (purchase) => purchase.id == widget.pemeliharaan?.purchaseId,
                  orElse: () => PurchaseModel(
                      id: 0,
                      transactionId: 0,
                      kandangId: 0,
                      supplierId: 0,
                      quantity: 0,
                      pricePerUnit: 0,
                      totalPrice: 0,
                      createdAt: DateTime.now(),
                      currentStock: 0,
                      updatedAt: DateTime.now()))
              .id;
        }
      });
    } catch (e) {
      debugPrint('Failed to load batch data: $e');
      if (mounted) {
        showCustomSnackBar(
            context, 'Failed to load batch data!', SnackBarType.error);
      }
    }
  }

  Future<void> _loadKandangData() async {
    if (widget.kandangId == null) return;

    try {
      final kandangService = KandangService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user.token;
      final kandangData =
          await kandangService.getKandangById(widget.kandangId!, token!);

      setState(() {
        _kapasitasKandang = kandangData.kapasitas;
        // Set jumlah ayam to jumlah real if this is a new pemeliharaan
        if (widget.pemeliharaan == null) {
          _jumlahAyamController.text = kandangData.jumlahReal.toString();
        }
      });
      debugPrint('Kapasitas Kandang set to: $_kapasitasKandang');
      debugPrint('Jumlah Real set to: ${kandangData.jumlahReal}');
    } catch (e) {
      debugPrint('Failed to load kandang data: $e');

      showCustomSnackBar(
          context, 'Failed to load kandang data!', SnackBarType.error);
    }
  }

  Future<void> _savePemeliharaan() async {
    // Basic validation
    if (_selectedPurchase == null) {
      showCustomSnackBar(context, 'Pilih Batch Ayam!', SnackBarType.error);
      return;
    }

    if (_jumlahAyamController.text.isEmpty) {
      showCustomSnackBar(
          context, 'Jumlah ayam harus diisi!', SnackBarType.error);
      return;
    }

    // Validate jenis pakan if jumlah pakan is filled
    if (_jumlahPakanController.text.isNotEmpty) {
      if (_selectedJenisPakan == null) {
        showCustomSnackBar(
            context, 'Pilih jenis pakan terlebih dahulu!', SnackBarType.error);
        return;
      }

      final jumlahPakan = int.tryParse(_jumlahPakanController.text);
      if (jumlahPakan != null && jumlahPakan < 1) {
        showCustomSnackBar(
            context, 'Jumlah pakan minimal 1!', SnackBarType.error);
        return;
      }
    }

    final jumlahAyam = int.tryParse(_jumlahAyamController.text) ?? 0;
    final kapasitasKandang = _kapasitasKandang ?? 0;
    final jumlahPakan = int.tryParse(_jumlahPakanController.text) ?? 0;

    // Validate kandang capacity
    if (jumlahAyam > kapasitasKandang) {
      showCustomSnackBar(context, 'Jumlah ayam melebihi kapasitas kandang!',
          SnackBarType.error);
      return;
    }

    // Get selected pakan
    final selectedPakan = _selectedJenisPakan != null
        ? _pakanList.firstWhere((pakan) => pakan.jenis == _selectedJenisPakan,
            orElse: () => PakanModel(id: 0, jenis: ''))
        : PakanModel(id: 0, jenis: '');

    // Check pakan stock if jumlah pakan is provided
    if (jumlahPakan > 0) {
      final sisaPakan = selectedPakan.sisa ?? 0;
      if (jumlahPakan > sisaPakan) {
        showCustomSnackBar(
            context, 'Stok pakan tidak cukup!', SnackBarType.error);
        return;
      }
    }

    final selectedPurchase = _selectedPurchase != null
        ? _purchaseList.firstWhere(
            (purchase) => purchase.id == _selectedPurchase,
            orElse: () => PurchaseModel(
                id: 0,
                transactionId: 0,
                kandangId: 0,
                supplierId: 0,
                quantity: 0,
                pricePerUnit: 0,
                totalPrice: 0,
                createdAt: DateTime.now(),
                currentStock: 0,
                updatedAt: DateTime.now()))
        : PurchaseModel(
            id: 0,
            transactionId: 0,
            kandangId: 0,
            supplierId: 0,
            quantity: 0,
            pricePerUnit: 0,
            totalPrice: 0,
            createdAt: DateTime.now(),
            currentStock: 0,
            updatedAt: DateTime.now());

    // Prepare pemeliharaan data
    final now = DateTime.now().toIso8601String();

    final newPemeliharaan = PemeliharaanModel(
      id: widget.pemeliharaan?.id ?? 0,
      kandangId: widget.kandangId!,
      purchaseId: selectedPurchase.id,
      jumlahAyam: jumlahAyam,
      jumlahPakan: jumlahPakan > 0 ? jumlahPakan : null,
      jenisPakanId: jumlahPakan > 0 ? selectedPakan.id : null,
      mati: int.tryParse(_matiController.text),
      keterangan: _keteranganController.text,
      createdAt: widget.pemeliharaan?.createdAt ?? now,
      updatedAt: now,
    );
    print('Payload Data: ${newPemeliharaan.toJson()}');
    try {
      final pemeliharaanService = PemeliharaanService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user.token;

      if (widget.pemeliharaan == null) {
        await pemeliharaanService.addPemeliharaan(newPemeliharaan, token!);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        await pemeliharaanService.updatePemeliharaan(
            newPemeliharaan.id, newPemeliharaan, token!);
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      showCustomSnackBar(
          context,
          'Failed to ${widget.pemeliharaan == null ? 'add' : 'update'} pemeliharaan: ${e.toString()}',
          SnackBarType.error);
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: _savePemeliharaan,
        style: TextButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.pemeliharaan == null ? 'Tambah' : 'Update',
          style: primaryTextStyle.copyWith(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildJenisPakanDropdown() {
    // Debugging: Print dropdown values and selected value
    debugPrint(
        'Dropdown Values: ${_pakanList.map((pakan) => pakan.jenis).toList()}');
    debugPrint('Selected Value: $_selectedJenisPakan');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Pakan',
          style: primaryTextStyle.copyWith(
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor22,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedJenisPakan,
            items: _pakanList
                .map((pakan) => DropdownMenuItem(
                      value: pakan.jenis,
                      child: Text(pakan.jenis, style: blackTextStyle),
                    ))
                .toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedJenisPakan = newValue;
                _stokPakan = _pakanList
                    .firstWhere((pakan) => pakan.jenis == _selectedJenisPakan,
                        orElse: () => PakanModel(id: 0, jenis: ''))
                    .sisa;
              });
            },
            decoration: InputDecoration.collapsed(
              hintText: 'Pilih jenis pakan',
              hintStyle: subtitleTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchDropdown() {
    debugPrint(
        'Dropdown Values: ${_purchaseList.map((purchase) => purchase.currentStock).toList()}');
    debugPrint('Selected Value: $_selectedPurchase');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Ayam',
          style: primaryTextStyle.copyWith(
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor22,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedPurchase,
            items: _purchaseList
                .map((purchase) => DropdownMenuItem(
                      value: purchase.id,
                      child: Text(
                        'Batch #${purchase.id} (Stock: ${purchase.currentStock})',
                        style: blackTextStyle,
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedPurchase = newValue;
              });
            },
            decoration: InputDecoration.collapsed(
              hintText: 'Pilih Batch Ayam',
              hintStyle: subtitleTextStyle,
            ),
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
              widget.pemeliharaan == null
                  ? 'Form Pemeliharaan Ayam'
                  : 'Edit Pemeliharaan Ayam',
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
                      widget.pemeliharaan == null
                          ? 'Informasi Pemeliharaan'
                          : 'Edit Pemeliharaan',
                      style: primaryTextStyle.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBatchDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Jumlah Ayam',
                    controller: _jumlahAyamController,
                    hintText: 'Jumlah Ayam',
                    keyboardType: TextInputType.number,
                    iconPath: 'assets/ayama.png',
                  ),
                  const SizedBox(height: 24),
                  _buildJenisPakanDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Jumlah Pakan',
                    hintText: 'Jumlah Pakan',
                    controller: _jumlahPakanController,
                    keyboardType: TextInputType.number,
                    iconPath: 'assets/ayama.png',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Mati',
                    hintText: 'Mati',
                    controller: _matiController,
                    keyboardType: TextInputType.number,
                    iconPath: 'assets/ayama.png',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    keyboardType: TextInputType.text,
                    label: 'Keterangan',
                    hintText: 'Keterangan',
                    controller: _keteranganController,
                    iconPath: 'assets/ayama.png',
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    required TextInputType keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(
              fontSize: 16, fontWeight: FontWeight.w500),
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
              Image.asset(iconPath, width: 17),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: inputTextStyle,
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: subtitleTextStyle,
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
