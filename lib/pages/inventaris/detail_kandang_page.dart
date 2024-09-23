import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/pages/inventaris/detail_pemeliharaan_page.dart';
import 'package:simandika/pages/inventaris/form_pemeliharaan_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/theme.dart';

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
    } else {
      _kandangData = Future.error('Invalid token or kandang ID');
      _pemeliharaanData = Future.error('Invalid token or kandang ID');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pemeliharaan == null
              ? 'Pemeliharaan added successfully'
              : 'Pemeliharaan updated successfully'),
        ),
      );
      await onSuccess(); // Call the callback to refresh data
      _tabController.animateTo(1); // Switch to the Data Harian tab
    } else if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${pemeliharaan == null ? 'add' : 'update'} pemeliharaan'),
        ),
      );
    }
  }

  Future<bool> _deletePemeliharaan(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false)
        .user
        .token; // Fetch your token from storage or state
    try {
      return await PemeliharaanService().deletePemeliharaan(id, token!);
    } catch (e) {
      debugPrint('Failed to delete pemeliharaan: $e');
      return false;
    }
  }

  Future<void> _addPemeliharaan() async {
    await _navigateToFormPage(
      kandangId: widget.kandangId,
      onSuccess: _refreshPemeliharaanData, // Pass the callback
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
            Tab(text: 'Penjualan'),
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
            _buildPenjualanTab(),
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
              child:
                  Text('No data found', style: TextStyle(color: Colors.white)));
        } else {
          final kandang = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(
                top: 16, right: 16, bottom: 300, left: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                maxWidth: 400, // Optional: Set a maximum width if needed
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nama Kandang: ${kandang.namaKandang}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Operator: ${kandang.operator}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Lokasi: ${kandang.lokasi}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Kapasitas: ${kandang.kapasitas}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Jumlah Real: ${kandang.jumlahReal ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Status: ${kandang.status ? 'Active' : 'Inactive'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white)),
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
              child:
                  Text('No data found', style: TextStyle(color: Colors.white)));
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
                      builder: (context) =>
                          DetailPemeliharaanPage(pemeliharaan: pemeliharaan),
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
                                'Umur ${pemeliharaan.umur} hari',
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Pemeliharaan deleted successfully')),
                                  );
                                  _refreshPemeliharaanData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to delete pemeliharaan')),
                                  );
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

  Widget _buildPenjualanTab() {
    return const Center(
        child: Text('Penjualan tab content',
            style: TextStyle(color: Colors.white)));
  }
}
