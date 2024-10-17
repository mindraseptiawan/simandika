import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/customer_model.dart';
import 'package:simandika/pages/keuangan/detail_order_page.dart';
import 'package:simandika/pages/pdf_preview.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/customer_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/customer_pdf_generator.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  CustomerPageState createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  late Future<List<CustomerModel>> _customerData;
  List<CustomerModel> _customers = []; // To store all customers
  List<CustomerModel> _filteredCustomers = []; // To store filtered customers
  // ignore: unused_field
  final String _searchQuery = '';
  String reportType = 'Daftar Customer';
  final TextEditingController _searchController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _customerData = CustomerService().getAllCustomers(token);
      _customerData.then((data) {
        setState(() {
          _customers = data;
          _filteredCustomers = data;
        });
      });
    } else {
      _customerData = Future.error('Invalid token');
    }
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final nameLower = customer.name.toLowerCase();
        final phoneLower = customer.phone?.toLowerCase() ?? '';
        final alamatLower = customer.alamat?.toLowerCase() ?? '';
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
    if (_customers.isEmpty) {
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

    final pdfBytes = await generateCustomerPDF(
        _customers, _startDate, _endDate, token, reportType);
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
        title: const Text('Customer',
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
                hintText: 'Cari customer ...',
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
              child: FutureBuilder<List<CustomerModel>>(
                future: _customerData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data Kosong'));
                  } else {
                    // Display filtered customers
                    return ListView.builder(
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        var customer = _filteredCustomers[index];
                        return ListTile(
                          title: Text(
                            customer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            '${customer.phone ?? 'No Phone'} - ${customer.alamat ?? 'No Address'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            // Navigate to DetailOrderPage with customer ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailOrderPage(
                                    customerId: customer.id,
                                    customerName: customer
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
