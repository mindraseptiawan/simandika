class TransaksiModel {
  final int id;
  final int userId;
  final String type; // 'purchase' or 'sale'
  final double? amount;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransaksiModel({
    required this.id,
    required this.userId,
    required this.type,
    this.amount,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null, // Convert amount to double
      keterangan: json['keterangan'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount?.toString(),
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
