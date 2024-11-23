import 'package:simandika/models/kandang_model.dart';

class StockMovementModel {
  int id;
  int kandangId;
  String type;
  int quantity;
  String reason;
  int referenceId;
  String referenceType;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;
  final KandangModel? kandang;
  final Map<String, dynamic>? purchase;

  StockMovementModel({
    required this.id,
    required this.kandangId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.referenceId,
    required this.referenceType,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.kandang,
    this.purchase,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? purchaseData = json['purchase'];

    if (json['reference_type'] == 'App\\Models\\Purchase' &&
        purchaseData != null) {}
    return StockMovementModel(
      id: json['id'],
      kandangId: json['kandang_id'],
      type: json['type'],
      quantity: json['quantity'],
      reason: json['reason'],
      referenceId: json['reference_id'],
      referenceType: json['reference_type'],
      notes: json['notes'],
      kandang: json['kandang'] != null
          ? KandangModel.fromJson(json['kandang'])
          : null,
      purchase: purchaseData,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
