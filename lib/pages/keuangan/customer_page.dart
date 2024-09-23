import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/customer_model.dart';
import 'package:simandika/pages/keuangan/detail_order_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/customer_service.dart';
import 'package:simandika/theme.dart';

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
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              // Action for PDF button
            },
            child: const Text('PDF', style: TextStyle(color: Colors.white)),
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
                prefixIcon: const Icon(Icons.search),
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
                            style: const TextStyle(color: Colors.grey),
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
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                // Add customer action
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Customer',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
