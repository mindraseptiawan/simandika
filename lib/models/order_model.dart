import 'package:simandika/models/customer_model.dart';
import 'package:simandika/models/sale_model.dart';

class OrderModel {
  final int id;
  final int customerId;
  final int? kandangId;
  final String orderDate;
  final String status;
  final int quantity;
  final String? alamat;
  final String? paymentMethod;
  final String? paymentProof;
  final String? paymentVerifiedAt;
  final int? paymentVerifiedBy;
  final CustomerModel? customer;
  final List<SaleModel>? sales;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.status,
    required this.quantity,
    this.kandangId,
    this.alamat,
    this.paymentMethod,
    this.paymentProof,
    this.paymentVerifiedAt,
    this.paymentVerifiedBy,
    this.customer,
    this.sales,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      orderDate: json['order_date'],
      status: json['status'],
      quantity: json['quantity'],
      alamat: json['alamat'],
      kandangId: json['kandang_id'],
      paymentMethod: json['payment_method'],
      paymentProof: json['payment_proof'],
      paymentVerifiedAt: json['payment_verified_at'],
      paymentVerifiedBy: json['payment_verified_by'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      sales: json['sales'] != null
          ? (json['sales'] as List)
              .map((sale) => SaleModel.fromJson(sale))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_date': orderDate,
      'status': status,
      'quantity': quantity,
      'alamat': alamat ?? '', // Default value jika null
      'kandang_id': kandangId ?? '', // Default value jika null
      'payment_method': paymentMethod ?? '', // Default value jika null
      'payment_proof': paymentProof ?? '', // Default value jika null
      'payment_verified_at': paymentVerifiedAt ?? '', // Default value jika null
      'payment_verified_by': paymentVerifiedBy ?? '', // Default value jika null
      'customer': customer?.toJson(),
      'sales': sales?.map((sale) => sale.toJson()).toList(),
    };
  }

// Helper method to parse the orderDate string into a DateTime object
  DateTime get orderDateTime => DateTime.parse(orderDate);

  // Helper method to get the day of the month
  int get day => orderDateTime.day;

  // Helper method to get the month (1-12)
  int get month => orderDateTime.month;

  // Helper method to get the year
  int get year => orderDateTime.year;

  // Helper method to compare order dates for sorting
  int compareTo(OrderModel other) {
    return other.orderDateTime.compareTo(orderDateTime);
  }
}
