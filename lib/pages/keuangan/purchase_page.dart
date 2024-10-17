import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/pages/keuangan/form_purchase_page.dart';
import 'package:simandika/pages/pdf_preview.dart';
import 'package:simandika/pages/keuangan/purchase_detail_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/purchase_pdf_generator.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  PurchasePageState createState() => PurchasePageState();
}

class PurchasePageState extends State<PurchasePage> {
  late Future<List<PurchaseModel>> _purchaseData;
  List<PurchaseModel> _purchases = [];
  List<PurchaseModel> _filteredPurchases = [];
  // ignore: unused_field
  String _searchQuery = ''; // For future search filter
  String reportType = 'Pembelian Ayam'; // For future search filter
  final TextEditingController _searchController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _purchaseData = PurchaseService().getAllPurchases(token);
      _purchaseData.then((data) {
        setState(() {
          _purchases = data..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _filteredPurchases = _purchases;
        });
      });
    } else {
      _purchaseData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterPurchases);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPurchases() {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      setState(() {
        _purchaseData = PurchaseService().getAllPurchases(token);
        _purchaseData.then((data) {
          setState(() {
            _purchases = data
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _filteredPurchases = _purchases;
          });
        });
      });
    }
  }

  void _filterPurchases() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        final supplierNameLower = purchase.supplier?.name.toLowerCase() ?? '';
        final dateLower =
            DateFormat('yyyy-MM-dd').format(purchase.createdAt).toLowerCase();

        return supplierNameLower.contains(query) || dateLower.contains(query);
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
    if (_purchases.isEmpty) {
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

    final pdfBytes = await generatePurchasePDF(
        _purchases, _startDate, _endDate, token, reportType);
    final fileName =
        'purchases_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(
          pdfBytes: pdfBytes,
          fileName: fileName,
          reportTitle: 'Laporan Pembelian',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Pembelian',
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama supplier atau tanggal pembelian ...',
                suffixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<PurchaseModel>>(
                future: _purchaseData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data Kosong'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredPurchases.length,
                      itemBuilder: (context, index) {
                        var purchase = _filteredPurchases[index];
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(purchase.createdAt);
                        return ListTile(
                          title: Text(
                            'Pembelian #${purchase.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier: ${purchase.supplier?.name ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${NumberFormat.currency(locale: 'id_ID', decimalDigits: 2).format(purchase.totalPrice)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseDetailPage(
                                  purchaseId: purchase.id,
                                ),
                              ),
                            );
                            if (result == true) {
                              _refreshPurchases();
                            }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormPurchasePage(),
            ),
          );
          if (result == true) {
            _refreshPurchases();
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Image.asset(
          'assets/icon_tambah.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
