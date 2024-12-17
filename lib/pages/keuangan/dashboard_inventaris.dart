import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/purchase_model.dart';
import 'package:simandika/models/supplier_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/purchase_service.dart';
import 'package:simandika/services/supplier_service.dart';
import 'package:simandika/theme.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart untuk PieChart

class SupplierAverageSusutPage extends StatefulWidget {
  @override
  State<SupplierAverageSusutPage> createState() =>
      _SupplierAverageSusutPageState();
}

class _SupplierAverageSusutPageState extends State<SupplierAverageSusutPage> {
  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _selectedSuppliers = [];
  Map<int, double> _averageSusut = {};
  Map<int, List<PurchaseModel>> supplierPurchases =
      {}; // Menyimpan data pembelian
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    if (token != null) {
      try {
        final suppliers = await SupplierService().getAllSuppliers(token);
        setState(() {
          _suppliers = suppliers;
        });
      } catch (e) {
        debugPrint('Failed to load suppliers: $e');
      }
    }
  }

  Future<void> _fetchPurchasesForSuppliers() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    _averageSusut.clear();
    supplierPurchases.clear(); // Reset data

    if (token != null) {
      for (var supplier in _selectedSuppliers) {
        try {
          final purchases = await PurchaseService()
              .getPurchaseBySupplierId(token, supplier.id);

          // Filter berdasarkan rentang tanggal
          final filteredPurchases = purchases.where((purchase) {
            return purchase.createdAt.isAfter(_startDate) &&
                purchase.createdAt.isBefore(_endDate);
          }).toList();

          supplierPurchases[supplier.id] = filteredPurchases;

          // Hitung rata-rata susut perjalanan
          if (filteredPurchases.isNotEmpty) {
            double totalSusut = filteredPurchases
                .map((purchase) => purchase.susutPerjalanan)
                .fold(0, (prev, element) => prev + element!);
            double averageSusut = totalSusut / filteredPurchases.length;

            setState(() {
              _averageSusut[supplier.id] = averageSusut;
            });
          } else {
            setState(() {
              _averageSusut[supplier.id] = 0.0;
            });
          }
        } catch (e) {
          debugPrint(
              'Failed to fetch purchases for supplier ${supplier.id}: $e');
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // Helper function untuk mendapatkan total susutPerjalanan untuk supplier tertentu
  double _getTotalSusutPerSupplier(int supplierId) {
    final purchases = supplierPurchases[supplierId] ?? [];
    return purchases.fold(0.0, (previousValue, purchase) {
      return previousValue + (purchase.susutPerjalanan ?? 0);
    });
  }

  // Helper function untuk mendapatkan jumlah pembelian untuk supplier tertentu
  int _getTotalQuantityForSupplier(int supplierId) {
    final purchases = supplierPurchases[supplierId] ?? [];
    return purchases.fold(0, (previousValue, purchase) {
      return previousValue + purchase.quantity;
    });
  }

  // Helper function untuk memformat angka agar tidak ada desimal jika bulat
  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  // Helper function untuk memformat tanggal hanya dengan tanggal, bulan, dan tahun
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy')
        .format(date); // Format tanggal: dd MMM yyyy
  }

  // Fungsi untuk membuat data PieChart
  List<PieChartSectionData> _getPieChartSections() {
    return _averageSusut.entries.map((entry) {
      final supplier =
          _suppliers.firstWhere((supplier) => supplier.id == entry.key);
      return PieChartSectionData(
        color: Colors.primaries[entry.key % Colors.primaries.length],
        value: entry.value,
        title: '${supplier.name}: ${_formatNumber(entry.value)}%',
        radius: 70, // Menambah radius untuk ukuran grafik yang lebih besar
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rata-rata Susut Perjalanan',
          style:
              TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF6750A4),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            color: Colors.white,
            onPressed: _selectDateRange,
          )
        ],
      ),
      body: SingleChildScrollView(
        // Membungkus dengan SingleChildScrollView agar layar bisa di-scroll
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Tampilkan rentang tanggal yang dipilih tanpa jam
              Text(
                  'Rentang Tanggal: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}'),
              SizedBox(height: 16),

              // Multi Select Dropdown
              MultiSelectDialogField(
                items: _suppliers
                    .map((supplier) =>
                        MultiSelectItem<SupplierModel>(supplier, supplier.name))
                    .toList(),
                title: Text("Pilih Supplier"),
                buttonText: Text("Pilih Supplier"),
                onConfirm: (values) {
                  setState(() {
                    _selectedSuppliers = values;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPurchasesForSuppliers,
                child: Text('Hitung Rata-rata Susut'),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        DataTable(
                          columnSpacing: 30.0,
                          columns: [
                            DataColumn(label: Text('Supplier')),
                            DataColumn(label: Text('Rata-Rata')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Susut')),
                          ],
                          rows: _averageSusut.entries.map((entry) {
                            final supplier = _suppliers.firstWhere(
                                (supplier) => supplier.id == entry.key);
                            final totalSusut =
                                _getTotalSusutPerSupplier(entry.key);
                            return DataRow(cells: [
                              DataCell(Text(supplier.name)),
                              DataCell(Text("${_formatNumber(entry.value)}%")),
                              DataCell(Text(
                                  '${_getTotalQuantityForSupplier(entry.key)}')),
                              DataCell(Text('${_formatNumber(totalSusut)}')),
                            ]);
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        // Tambahkan PieChart setelah tabel
                        if (_averageSusut.isNotEmpty)
                          Container(
                            height: 250, // Mengatur tinggi PieChart
                            child: PieChart(
                              PieChartData(
                                sections: _getPieChartSections(),
                                centerSpaceRadius: 0,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
