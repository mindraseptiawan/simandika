import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/transaksi_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/transaksi_service.dart';
import 'package:simandika/theme.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      _transactionData = TransaksiService().getAllTransactions(token);
      _transactionData.then((data) {
        setState(() {
          _transactions = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi', style: TextStyle(color: Colors.white)),
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
            // Search bar for future search/filter
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Filtering is handled by listener
              },
              decoration: InputDecoration(
                hintText: 'Cari transaksi ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
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
                          subtitle: Text(
                            '$formattedDate - ${transaksi.type == 'sale' ? 'Pendapatan' : 'Pengeluaran'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            transaksi.amount != null
                                ? 'Rp ${transaksi.amount!.toStringAsFixed(2)}'
                                : 'Proses',
                            style: TextStyle(
                              color: transaksi.amount != null
                                  ? Colors.black
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            // Handle transaction tap
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
