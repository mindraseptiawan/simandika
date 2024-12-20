import 'package:simandika/models/customer_model.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/models/transaksi_model.dart';

class SaleModel {
  final int id;
  final int transactionId;
  final int customerId;
  final int orderId;
  final int quantity;
  final double pricePerUnit;
  final double? ongkir;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderModel? order; // Relationship with Order
  final TransaksiModel? transaction; // Relationship with Transaction
  final CustomerModel? customer; // Relationship with Customer

  SaleModel({
    required this.id,
    required this.transactionId,
    required this.customerId,
    required this.orderId,
    required this.quantity,
    required this.pricePerUnit,
    this.ongkir,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.order,
    this.transaction,
    this.customer,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      customerId: json['customer_id'],
      orderId: json['order_id'],
      quantity: json['quantity'],
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      ongkir: json['ongkir'] != null
          ? double.parse(json['ongkir'].toString())
          : null,
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      order: json['order'] != null ? OrderModel.fromJson(json['order']) : null,
      transaction: json['transaction'] != null
          ? TransaksiModel.fromJson(json['transaction'])
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'customer_id': customerId,
      'order_id': orderId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit.toString(),
      'ongkir': ongkir?.toString(),
      'total_price': totalPrice.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'order': order?.toJson(),
      'transaction': transaction?.toJson(),
      'customer': customer?.toJson(),
    };
  }
}
