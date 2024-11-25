import 'package:simandika/models/supplier_model.dart';

import 'package:simandika/models/transaksi_model.dart';

class PurchaseModel {
  final int id;
  final int transactionId;
  final int kandangId;
  final int supplierId;
  final int quantity;
  final double pricePerUnit;
  final double? ongkir;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TransaksiModel? transaction;
  final SupplierModel? supplier;
  final int? currentStock;

  PurchaseModel({
    required this.id,
    required this.transactionId,
    required this.kandangId,
    required this.supplierId,
    required this.quantity,
    required this.pricePerUnit,
    this.ongkir,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.transaction,
    this.supplier,
    this.currentStock,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      kandangId: json['kandang_id'],
      supplierId: json['supplier_id'],
      quantity: json['quantity'],
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      ongkir: json['ongkir'] != null
          ? double.parse(json['ongkir'].toString())
          : null,
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      transaction: json['transaction'] != null
          ? TransaksiModel.fromJson(json['transaction'])
          : null,
      supplier: json['supplier'] != null
          ? SupplierModel.fromJson(json['supplier'])
          : null,
      currentStock: json['currentStock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'kandang_id': kandangId,
      'supplier_id': supplierId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit.toString(),
      'ongkir': ongkir?.toString(),
      'total_price': totalPrice.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'transaction': transaction?.toJson(),
      'supplier': supplier?.toJson(),
      'currentStock': currentStock,
    };
  }

  // Helper method to parse the orderDate string into a DateTime object
  DateTime get purchaseDateTime => (createdAt);

  // Helper method to get the day of the month
  int get day => purchaseDateTime.day;

  // Helper method to get the month (1-12)
  int get month => purchaseDateTime.month;

  // Helper method to get the year
  int get year => purchaseDateTime.year;

  // Helper method to compare purchase dates for sorting
  int compareTo(PurchaseModel other) {
    return other.purchaseDateTime.compareTo(purchaseDateTime);
  }
}
