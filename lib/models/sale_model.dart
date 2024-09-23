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
  final double totalPrice;
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
    required this.totalPrice,
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
      totalPrice: double.parse(json['total_price'].toString()),
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
      'total_price': totalPrice.toString(),
      'order': order?.toJson(),
      'transaction': transaction?.toJson(),
      'customer': customer?.toJson(),
    };
  }
}
