import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/models/stock_model.dart';
import 'package:simandika/pages/inventaris/detail_pemeliharaan_page.dart';
import 'package:simandika/pages/inventaris/form_pemeliharaan_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/services/stock_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class DetailPage extends StatefulWidget {
  final String kandangName;
  final int kandangId;

  const DetailPage({
    super.key,
    required this.kandangName,
    required this.kandangId,
  });

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<KandangModel> _kandangData;
  late Future<List<PurchaseModel>> _batchData;
  late Future<List<StockMovementModel>> _stockData;
  late Future<List<PemeliharaanModel>> _pemeliharaanData;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          _showFab = _tabController.index == 1; // Show FAB on Data Harian tab
        });
      });

    // Ambil token dari AuthProvider
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    if (widget.kandangId > 0 && token != null) {
      _kandangData = KandangService().getKandangById(widget.kandangId, token);
      _pemeliharaanData = PemeliharaanService()
          .getPemeliharaansByKandang(widget.kandangId, token);
      _stockData = StockService().getStockByKandangId(widget.kandangId, token);
      _batchData =
          PurchaseService().getPurchaseByKandangId(widget.kandangId, token);
    } else {
      _kandangData = Future.error('Invalid token or kandang ID');
      _pemeliharaanData = Future.error('Invalid token or kandang ID');
      _stockData = Future.error('Invalid token or kandang ID');
      _batchData = Future.error('Invalid token or kandang ID');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshPemeliharaanData() async {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (widget.kandangId > 0 && token != null) {
      setState(() {
        _pemeliharaanData = PemeliharaanService()
            .getPemeliharaansByKandang(widget.kandangId, token);
        _stockData =
            StockService().getStockByKandangId(widget.kandangId, token);
      });
    }
  }

  Future<void> _navigateToFormPage({
    PemeliharaanModel? pemeliharaan,
    required int kandangId,
    required Future<void> Function() onSuccess,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPemeliharaanPage(
          pemeliharaan: pemeliharaan,
          kandangId: kandangId,
        ),
      ),
    );

    if (result == true) {
      showCustomSnackBar(
          context,
          pemeliharaan == null
              ? 'Berhasil Menambahkan Data Pemeliharaan'
              : 'Berhasil Memperbarui Data Pemeliharaan',
          SnackBarType.success);
      await onSuccess(); // Call the callback to refresh data
      _tabController.animateTo(1); // Switch to the Data Harian tab
    } else if (result == false) {
      showCustomSnackBar(
          context,
          'Gagal ${pemeliharaan == null ? 'tambah' : 'perbarui'} pemeliharaan',
          SnackBarType.success);
    }
  }

  Future<bool> _deletePemeliharaan(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false)
        .user
        .token; // Fetch your token from storage or state
    try {
      return await PemeliharaanService().deletePemeliharaan(id, token!);
    } catch (e) {
      debugPrint('Gagal Menghapus pemeliharaan: $e');
      return false;
    }
  }

  Future<void> _addPemeliharaan() async {
    await _navigateToFormPage(
      kandangId: widget.kandangId,
      onSuccess: _refreshPemeliharaanData,
      // Pass the callback
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kandangName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor, // Set AppBar background color
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Data Harian'),
            Tab(text: 'Stok Ayam'),
          ],
          labelColor: Colors.white, // Set Tab label color
          unselectedLabelColor:
              Colors.white70, // Set Tab unselected label color
        ),
      ),
      body: Container(
        color: backgroundColor1, // Set the background color
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRingkasanTab(),
            _buildDataHarianTab(),
            _buildStokAyamTab(),
          ],
        ),
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: _addPemeliharaan,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset(
                'assets/icon_tambah.png',
                fit: BoxFit.cover,
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white), // Set value text color to white
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanTab() {
    return FutureBuilder<KandangModel>(
      future: _kandangData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData) {
          return const Center(
              child: Text('Tidak ada Data',
                  style: TextStyle(color: Colors.white)));
        } else {
          final kandang = snapshot.data!;
          final token =
              Provider.of<AuthProvider>(context, listen: false).user.token;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Kandang Details Card
                  Card(
                    elevation: 4,
                    color: primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          _buildDetailRow(
                              'Nama Kandang', '${kandang.namaKandang}'),
                          _buildDetailRow('Operator', '${kandang.operator}'),
                          _buildDetailRow('Lokasi', '${kandang.lokasi}'),
                          _buildDetailRow('Kapasitas', '${kandang.kapasitas}'),
                          _buildDetailRow(
                              'Jumlah Real', '${kandang.jumlahReal}'),
                          _buildDetailRow('Status',
                              '${kandang.status ? 'Active' : 'Inactive'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Purchase Information Card
                  if (token != null)
                    FutureBuilder<List<PurchaseModel>>(
                      future: PurchaseService()
                          .getPurchaseByKandangId(kandang.id, token),
                      builder: (context, purchaseSnapshot) {
                        if (purchaseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (purchaseSnapshot.hasError) {
                          return Center(
                              child: Text('Tidak Ada Batch Ayam',
                                  style: const TextStyle(color: Colors.white)));
                        } else if (!purchaseSnapshot.hasData ||
                            purchaseSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Data Pembelian Tidak Ditemukan',
                                  style: TextStyle(color: Colors.white)));
                        } else {
                          final filteredPurchases = purchaseSnapshot.data!
                              .where((purchase) =>
                                  purchase.currentStock != null &&
                                  purchase.currentStock! > 0)
                              .toList();
                          return Card(
                            elevation: 4,
                            color: primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasi Pembelian',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Table(columnWidths: const {
                                    0: FlexColumnWidth(1.2), // Purchase ID
                                    1: FlexColumnWidth(1.2), // Quantity
                                    2: FlexColumnWidth(1.2), // Current Stock
                                    3: FlexColumnWidth(1.5), // Age
                                  }, children: [
                                    const TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              ' Batch ID',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              'Jumlah',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              'Jumlah saat ini',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              'Umur',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ...filteredPurchases.map((purchase) {
                                      final age = DateTime.now()
                                          .difference(purchase.createdAt)
                                          .inDays;
                                      return TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                '#${purchase.id}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                '${purchase.quantity}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                '${purchase.currentStock ?? 0}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                '$age hari',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String _formatMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  Widget _buildDataHarianTab() {
    return FutureBuilder<List<PemeliharaanModel>>(
      future: _pemeliharaanData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('Tidak Ada Data',
                  style: TextStyle(color: Colors.white)));
        } else {
          final pemeliharaans = snapshot.data!;

          // Sort the list by `createdAt` in descending order (newest first)
          pemeliharaans.sort((a, b) {
            final aDate =
                DateTime.parse(a.createdAt ?? DateTime.now().toIso8601String());
            final bDate =
                DateTime.parse(b.createdAt ?? DateTime.now().toIso8601String());
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            itemCount: pemeliharaans.length,
            itemBuilder: (context, index) {
              final pemeliharaan = pemeliharaans[index];
              final createdAt = DateTime.parse(
                  pemeliharaan.createdAt ?? DateTime.now().toIso8601String());

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPemeliharaanPage(
                        pemeliharaanId: pemeliharaan.id,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  createdAt.day.toString(),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatMonth(createdAt.month),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${createdAt.year}',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${createdAt.day} ${_formatMonth(createdAt.month)} ${createdAt.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Batch Ayam #${pemeliharaan.purchaseId}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Jumlah Ayam: ${pemeliharaan.jumlahAyam}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () async {
                                final success =
                                    await _deletePemeliharaan(pemeliharaan.id);
                                if (success) {
                                  showCustomSnackBar(
                                      context,
                                      'Pemeliharaan Berhasil dihapus',
                                      SnackBarType.success);
                                  _refreshPemeliharaanData();
                                } else {
                                  showCustomSnackBar(
                                      context,
                                      'Gagal Menghapus Data Pemeliharaan!',
                                      SnackBarType.error);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildStokAyamTab() {
    return FutureBuilder<List<StockMovementModel>>(
      future: _stockData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('Tidak Ada Data',
                  style: TextStyle(color: Colors.white)));
        } else {
          final stocks = snapshot.data!;
          stocks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];

              return ListTile(
                title: Text(stock.notes,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text('Jumlah: ${stock.quantity}',
                    style: const TextStyle(color: Colors.white)),
              );
            },
          );
        }
      },
    );
  }
}
