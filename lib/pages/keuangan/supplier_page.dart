import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/supplier_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/supplier_service.dart';
import 'package:simandika/theme.dart';

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
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier', style: TextStyle(color: Colors.white)),
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
                hintText: 'Cari supplier ...',
                prefixIcon: const Icon(Icons.search),
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
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data Kosong'));
                  } else {
                    // Display filtered customers
                    return ListView.builder(
                      itemCount: _filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        var customer = _filteredSuppliers[index];
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
                          onTap: () {},
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
