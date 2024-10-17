import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/supplier_model.dart';
import 'package:simandika/pages/keuangan/detail_purchase_page.dart';
import 'package:simandika/pages/pdf_preview.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/supplier_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/supplier_pdf_generator.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  SupplierPageState createState() => SupplierPageState();
}

class SupplierPageState extends State<SupplierPage> {
  late Future<List<SupplierModel>> _supplierData;
  List<SupplierModel> _suppliers = []; // To store all suppliers
  List<SupplierModel> _filteredSuppliers = []; // To store filtered suppliers
  // ignore: unused_field
  final String _searchQuery = '';
  String reportType = 'Daftar Supplier';
  final TextEditingController _searchController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _supplierData = SupplierService().getAllSuppliers(token);
      _supplierData.then((data) {
        setState(() {
          _suppliers = data;
          _filteredSuppliers = data;
        });
      });
    } else {
      _supplierData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterSuppliers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSuppliers = _suppliers.where((supplier) {
        final nameLower = supplier.name.toLowerCase();
        final phoneLower = supplier.phone?.toLowerCase() ?? '';
        final alamatLower = supplier.alamat?.toLowerCase() ?? '';
        return nameLower.contains(query) ||
            phoneLower.contains(query) ||
            alamatLower.contains(query);
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
    if (_suppliers.isEmpty) {
      showCustomSnackBar(
          context, 'Tidak ada transaksi untuk dibuat PDF', SnackBarType.error);
      return;
    }

    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token == null) {
      showCustomSnackBar(
          context, 'Tidak dapat mengakses token', SnackBarType.error);
      return;
    }

    final pdfBytes = await generateSupplierPDF(
        _suppliers, _startDate, _endDate, token, reportType);
    final fileName =
        'purchases_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(
          pdfBytes: pdfBytes,
          fileName: fileName,
          reportTitle: 'Laporan Customer',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Supplier',
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
            // Search bar for filtering
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Filtering is handled by listener
              },
              decoration: InputDecoration(
                hintText: 'Cari supplier ...',
                suffixIcon: const Icon(Icons.search),
                filled: true, // Enable filling
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Display the order list
            Expanded(
              child: FutureBuilder<List<SupplierModel>>(
                future: _supplierData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error: ${snapshot.error},style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Data Kosong',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)));
                  } else {
                    // Display filtered suppliers
                    return ListView.builder(
                      itemCount: _filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        var supplier = _filteredSuppliers[index];
                        return ListTile(
                          title: Text(
                            supplier.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            '${supplier.phone ?? 'No Phone'} - ${supplier.alamat ?? 'No Address'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            // Navigate to DetailOrderPage with customer ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPurchasePage(
                                    supplierId: supplier.id,
                                    supplierName: supplier
                                        .name), //HARUS HUBUNNGIN KE TABEL ORDER
                              ),
                            );
                          },
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
