class KandangModel {
  final int id;
  final String namaKandang;
  final String operator;
  final String lokasi;
  final int kapasitas;
  final int? jumlahReal;
  final bool status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  KandangModel({
    required this.id,
    required this.namaKandang,
    required this.operator,
    required this.lokasi,
    required this.kapasitas,
    this.jumlahReal,
    required this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory KandangModel.fromJson(Map<String, dynamic> json) {
    return KandangModel(
      id: json['id'],
      namaKandang: json['nama_kandang'],
      operator: json['operator'],
      lokasi: json['lokasi'],
      kapasitas: json['kapasitas'],
      jumlahReal: json['jumlah_real'],
      status: json['status'] == 1,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kandang': namaKandang,
      'operator': operator,
      'lokasi': lokasi,
      'kapasitas': kapasitas,
      'jumlah_real': jumlahReal,
      'status': status,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  KandangModel copyWith({
    int? id,
    String? namaKandang,
    String? operator,
    String? lokasi,
    int? kapasitas,
    int? jumlahReal,
    bool? status,
    String? deletedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return KandangModel(
      id: id ?? this.id,
      namaKandang: namaKandang ?? this.namaKandang,
      operator: operator ?? this.operator,
      lokasi: lokasi ?? this.lokasi,
      kapasitas: kapasitas ?? this.kapasitas,
      jumlahReal: jumlahReal ?? this.jumlahReal,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
