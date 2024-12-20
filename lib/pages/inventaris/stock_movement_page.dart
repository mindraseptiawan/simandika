import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/stock_model.dart';
import 'package:simandika/pages/pdf_preview.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/stock_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/stock_pdf_generator.dart';

class StockMovementPage extends StatefulWidget {
  const StockMovementPage({Key? key}) : super(key: key);

  @override
  StockMovementPageState createState() => StockMovementPageState();
}

class StockMovementPageState extends State<StockMovementPage> {
  late Future<List<StockMovementModel>> _stockMovementData;
  List<StockMovementModel> _stockMovements = [];
  List<StockMovementModel> _filteredStockMovements = [];
  List<KandangModel> _kandangs = [];
  String reportType = 'Stock Ayam';
  // ignore: unused_field
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  KandangModel? _selectedKandang;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _stockMovementData = StockService().getAllStocks(token);
      _stockMovementData.then((data) {
        setState(() {
          _stockMovements = data
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _filteredStockMovements = _stockMovements;
        });
      });
      KandangService().getKandangs(token).then((data) {
        setState(() {
          _kandangs = data;
        });
      });
    } else {
      _stockMovementData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterStockMovements);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStockMovements() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStockMovements = _stockMovements.where((movement) {
        // Debug print to track supplier information
        print("Movement ID: ${movement.id}");
        print("Reference Type: ${movement.referenceType}");

        final typeLower = movement.type.toLowerCase();
        final reasonLower = movement.reason.toLowerCase();
        final dateLower =
            DateFormat('yyyy-MM-dd').format(movement.createdAt).toLowerCase();

        // Handle kandang filter
        final kandangFilter = _selectedKandang == null ||
            movement.kandangId == _selectedKandang!.id;

        return (typeLower.contains(query) ||
                reasonLower.contains(query) ||
                dateLower.contains(query)) &&
            kandangFilter;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateAndPreviewPDF() async {
    if (_stockMovements.isEmpty) {
      showCustomSnackBar(context, 'Tidak ada pergerakan stok untuk dibuat PDF!',
          SnackBarType.error);
      return;
    }

    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token == null) {
      showCustomSnackBar(
          context, 'Tidak dapat mengakses token!', SnackBarType.error);
      return;
    }

    final pdfBytes = await generateStockMovementPDF(_stockMovements, _startDate,
        _endDate, token, reportType, _selectedKandang?.id);
    final fileName =
        'stock_movements_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(
          pdfBytes: pdfBytes,
          fileName: fileName,
          reportTitle: 'Laporan Pergerakan Stok',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Pergerakan Stok',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () async {
              await _selectDateRange();
              await _generateAndPreviewPDF();
            },
            child: const Text('PDF',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<KandangModel>(
              decoration: InputDecoration(
                labelText: 'Pilih Kandang',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              value: _selectedKandang,
              items: _kandangs.map((kandang) {
                return DropdownMenuItem<KandangModel>(
                  value: kandang,
                  child: Text(kandang.namaKandang),
                );
              }).toList(),
              onChanged: (KandangModel? value) {
                setState(() {
                  _selectedKandang = value;
                  _filterStockMovements();
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tipe, alasan, atau tanggal pergerakan stok ...',
                suffixIcon: const Icon(Icons.search),
                filled: true, // Enable filling
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<StockMovementModel>>(
                future: _stockMovementData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data Kosong'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredStockMovements.length,
                      itemBuilder: (context, index) {
                        var movement = _filteredStockMovements[index];
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(movement.createdAt);
                        return ListTile(
                          title: Text(
                            'Pergerakan Stok #${movement.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipe: ${movement.type}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Alasan: ${movement.reason}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${movement.quantity}',
                            style: TextStyle(
                              color: movement.type == 'in'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {},
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
