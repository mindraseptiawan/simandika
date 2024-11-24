class PemeliharaanModel {
  final int id;
  final int kandangId;
  final int? purchaseId;
  final int jumlahAyam;
  final int? jumlahPakan;
  final int? mati;
  final String? keterangan;
  final int? jenisPakanId;
  final String? createdAt;
  final String? updatedAt;

  PemeliharaanModel({
    required this.id,
    required this.kandangId,
    this.purchaseId,
    required this.jumlahAyam,
    this.jumlahPakan,
    this.mati,
    this.keterangan,
    this.jenisPakanId,
    this.createdAt,
    this.updatedAt,
  });

  factory PemeliharaanModel.fromJson(Map<String, dynamic> json) {
    return PemeliharaanModel(
      id: json['id'],
      kandangId: json['kandang_id'],
      purchaseId: json['purchase_id'],
      jumlahAyam: json['jumlah_ayam'],
      jumlahPakan: json['jumlah_pakan'],
      mati: json['mati'],
      keterangan: json['keterangan'],
      jenisPakanId: json['jenis_pakan_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kandang_id': kandangId,
      'purchase_id': purchaseId,
      'jumlah_ayam': jumlahAyam,
      'jumlah_pakan': jumlahPakan,
      'mati': mati,
      'keterangan': keterangan,
      'jenis_pakan_id': jenisPakanId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PemeliharaanModel copyWith({
    int? id,
    int? kandangId,
    int? purchaseId,
    int? jumlahAyam,
    int? jumlahPakan,
    int? mati,
    String? keterangan,
    int? jenisPakanId,
    String? createdAt,
    String? updatedAt,
  }) {
    return PemeliharaanModel(
      id: id ?? this.id,
      kandangId: kandangId ?? this.kandangId,
      purchaseId: purchaseId ?? this.purchaseId,
      jumlahAyam: jumlahAyam ?? this.jumlahAyam,
      jumlahPakan: jumlahPakan ?? this.jumlahPakan,
      mati: mati ?? this.mati,
      keterangan: keterangan ?? this.keterangan,
      jenisPakanId: jenisPakanId ?? this.jenisPakanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
