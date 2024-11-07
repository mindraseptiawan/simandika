import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/services/pakan_service.dart';
import 'package:simandika/services/kandang_service.dart';
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
  late TextEditingController _umurController;
  late TextEditingController _jumlahAyamController;
  late TextEditingController _jumlahPakanController;
  late TextEditingController _matiController;
  late TextEditingController _keteranganController;

  String? _selectedJenisPakan;
  List<PakanModel> _pakanList = [];
  int? _stokPakan;
  int? _kapasitasKandang;

  @override
  void initState() {
    super.initState();
    _umurController = TextEditingController(
      text: widget.pemeliharaan?.umur.toString() ?? '',
    );
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

    // Load pakan data
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

          // Debugging: Print selected pakan and stock
          debugPrint('Selected Jenis Pakan: $_selectedJenisPakan');
          debugPrint('Stok Pakan: $_stokPakan');
        }
      });
    } catch (e) {
      debugPrint('Failed to load pakan data: $e');

      showCustomSnackBar(
          context, 'Failed to load pakan data!', SnackBarType.error);
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
    final jumlahAyam = int.tryParse(_jumlahAyamController.text) ?? 0;
    final kapasitasKandang = _kapasitasKandang ?? 0;
    final jumlahPakan = int.tryParse(_jumlahPakanController.text) ?? 0;

    // Debugging: Print jumlahAyam, kapasitasKandang, and jumlahPakan
    debugPrint('Jumlah Ayam: $jumlahAyam');
    debugPrint('Kapasitas Kandang: $kapasitasKandang');
    debugPrint('Jumlah Pakan: $jumlahPakan');

    if (jumlahAyam > kapasitasKandang) {
      showCustomSnackBar(context, 'Jumlah ayam melebihi kapasitas kandang!',
          SnackBarType.error);
      return;
    }

    final selectedPakan = _pakanList.firstWhere(
      (pakan) => pakan.jenis == _selectedJenisPakan,
      orElse: () => PakanModel(id: 0, jenis: ''),
    );

    // Check if the selected pakan is sufficient
    final sisaPakan = selectedPakan.sisa ?? 0;

    // Debugging: Print available pakan stock
    debugPrint('Sisa Pakan: $sisaPakan');

    if (jumlahPakan > sisaPakan) {
      showCustomSnackBar(
          context, 'Stok pakan tidak cukup!', SnackBarType.error);
      return;
    }

    final pemeliharaanService = PemeliharaanService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    if (widget.kandangId == null || widget.kandangId == 0) {
      showCustomSnackBar(context, 'Invalid kandang ID!', SnackBarType.error);
      return;
    }

    // Format current date as string
    final now = DateTime.now().toIso8601String();

    final newPemeliharaan = PemeliharaanModel(
      id: widget.pemeliharaan?.id ?? 0,
      kandangId: widget.kandangId!,
      umur: int.parse(_umurController.text),
      jumlahAyam: jumlahAyam,
      jumlahPakan: jumlahPakan,
      jenisPakanId: selectedPakan.id,
      mati: int.tryParse(_matiController.text),
      keterangan: _keteranganController.text,
      // Use existing timestamps if updating, create new ones if adding
      createdAt: widget.pemeliharaan?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.pemeliharaan == null) {
        await pemeliharaanService.addPemeliharaan(newPemeliharaan, token!);
        Navigator.pop(context, true);
      } else {
        await pemeliharaanService.updatePemeliharaan(
            newPemeliharaan.id, newPemeliharaan, token!);
        Navigator.pop(context, true);
      }
    } catch (e) {
      showCustomSnackBar(
          context,
          'Failed to ${widget.pemeliharaan == null ? 'add' : 'update'} pemeliharaan!',
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
                  _buildInputField(
                    label: 'Umur',
                    controller: _umurController,
                    hintText: 'Umur',
                    keyboardType: TextInputType.number,
                    iconPath: 'assets/ayama.png',
                  ),
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
