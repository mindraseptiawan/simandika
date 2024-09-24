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
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'],
      kandangId: json['kandang_id'],
      type: json['type'],
      quantity: json['quantity'],
      reason: json['reason'],
      referenceId: json['reference_id'],
      referenceType: json['reference_type'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
