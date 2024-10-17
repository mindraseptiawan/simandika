import 'package:simandika/models/supplier_model.dart';

import 'package:simandika/models/transaksi_model.dart';

class PurchaseModel {
  final int id;
  final int transactionId;
  final int kandangId;
  final int supplierId;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TransaksiModel? transaction; // Relationship with Transaction
  final SupplierModel? supplier;

  PurchaseModel({
    required this.id,
    required this.transactionId,
    required this.kandangId,
    required this.supplierId,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.transaction,
    this.supplier,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      kandangId: json['kandang_id'],
      supplierId: json['supplier_id'],
      quantity: json['quantity'],
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      transaction: json['transaction'] != null
          ? TransaksiModel.fromJson(json['transaction'])
          : null,
      supplier: json['supplier'] != null
          ? SupplierModel.fromJson(json['supplier'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'supplier_id': supplierId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit.toString(),
      'total_price': totalPrice.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'transaction': transaction?.toJson(),
      'supplier': supplier?.toJson(),
    };
  }
}
