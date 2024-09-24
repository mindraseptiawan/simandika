class SupplierModel {
  final int id;

  final String name;
  final String? alamat;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.alamat,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      alamat: json['alamat'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alamat': alamat,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
