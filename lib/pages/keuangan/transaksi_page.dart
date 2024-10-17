import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/transaksi_model.dart';
import 'package:simandika/pages/keuangan/form_transaksi_page.dart';
import 'package:simandika/pages/keuangan/pdf_preview.dart';
import 'package:simandika/pages/keuangan/transaksi_detail_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/transaksi_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/transaksi_pdf_generator.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  late Future<List<TransaksiModel>> _transactionData;
  List<TransaksiModel> _transactions = [];
  List<TransaksiModel> _filteredTransactions = [];
  // ignore: unused_field
  String _searchQuery = ''; // For future search filter
  String reportType = 'Transaksi'; // For future search filter
  final TextEditingController _searchController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _transactionData = TransaksiService().getAllTransactions(token);
      _transactionData.then((data) {
        setState(() {
          _transactions = data
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _filteredTransactions = data;
        });
      });
    } else {
      _transactionData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        final typeLower = transaction.type.toLowerCase();

        return typeLower.contains(query);
      }).toList();
    });
  }

  void _refreshTransactions() {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      setState(() {
        _transactionData = TransaksiService().getAllTransactions(token);
        _transactionData.then((data) {
          setState(() {
            _transactions = data;
            _filteredTransactions = data;
          });
        });
      });
    }
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
    if (_transactions.isEmpty) {
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

    final pdfBytes = await generateTransactionPDF(
        _transactions, _startDate, _endDate, token, reportType);
    final fileName =
        'transactions_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(
          pdfBytes: pdfBytes,
          fileName: fileName,
          reportTitle: 'Laporan Transaksi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar for future search/filter
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Filtering is handled by listener
              },
              decoration: InputDecoration(
                hintText: 'Cari Transaksi ...',
                suffixIcon:
                    const Icon(Icons.search, color: Colors.black), // Icon color
                filled: true, // Enable filling
                fillColor: Colors.white, // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white), // Border color
                ),
              ),
              style: const TextStyle(color: Colors.black), // Text color
            ),
            const SizedBox(height: 16.0),
            // Display the transaction list
            Expanded(
              child: FutureBuilder<List<TransaksiModel>>(
                  future: _transactionData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Data Kosong'));
                    } else {
                      // Display all transactions for now
                      return ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            var transaksi = _filteredTransactions[index];
                            String formattedDate = DateFormat('yyyy-MM-dd')
                                .format(transaksi.createdAt);
                            return ListTile(
                              title: Text(
                                transaksi.type == 'sale'
                                    ? 'Penjualan #${transaksi.id}'
                                    : 'Pembelian #${transaksi.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${transaksi.keterangan}',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              trailing: Text(
                                transaksi.amount != null
                                    ? '${NumberFormat.currency(locale: 'id_ID', decimalDigits: 2).format(transaksi.amount)}'
                                    : 'Proses',
                                style: TextStyle(
                                  color: transaksi.amount != null
                                      ? Colors.white
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransaksiDetailPage(
                                        transactionId: transaksi.id),
                                  ),
                                );
                              },
                            );
                          });
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormTransaksiPage(),
            ),
          );
          if (result == true) {
            _refreshTransactions();
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
