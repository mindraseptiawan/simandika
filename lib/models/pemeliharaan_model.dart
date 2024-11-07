class PemeliharaanModel {
  final int id;
  final int kandangId;
  final int umur;
  final int jumlahAyam;
  final int? jumlahPakan;
  final int? mati;
  final String? keterangan;
  final int? jenisPakanId; // Properti untuk menyimpan ID jenis pakan
  final String? createdAt;
  final String? updatedAt;

  PemeliharaanModel({
    required this.id,
    required this.kandangId,
    required this.umur,
    required this.jumlahAyam,
    this.jumlahPakan,
    this.mati,
    this.keterangan,
    this.jenisPakanId, // Properti untuk menyimpan ID jenis pakan
    this.createdAt,
    this.updatedAt,
  });

  factory PemeliharaanModel.fromJson(Map<String, dynamic> json) {
    return PemeliharaanModel(
      id: json['id'],
      kandangId: json['kandang_id'],
      umur: json['umur'],
      jumlahAyam: json['jumlah_ayam'],
      jumlahPakan: json['jumlah_pakan'],
      mati: json['mati'],
      keterangan: json['keterangan'],
      jenisPakanId:
          json['jenis_pakan_id'], // Properti untuk menyimpan ID jenis pakan
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kandang_id': kandangId,
      'umur': umur,
      'jumlah_ayam': jumlahAyam,
      'jumlah_pakan': jumlahPakan,

      'mati': mati,
      'keterangan': keterangan,
      'jenis_pakan_id': jenisPakanId, // Properti untuk menyimpan ID jenis pakan
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PemeliharaanModel copyWith({
    int? id,
    int? kandangId,
    int? umur,
    int? jumlahAyam,
    int? jumlahPakan,
    int? mati,
    String? keterangan,
    int? jenisPakanId, // Properti untuk menyimpan ID jenis pakan
    String? createdAt,
    String? updatedAt,
  }) {
    return PemeliharaanModel(
      id: id ?? this.id,
      kandangId: kandangId ?? this.kandangId,
      umur: umur ?? this.umur,
      jumlahAyam: jumlahAyam ?? this.jumlahAyam,
      jumlahPakan: jumlahPakan ?? this.jumlahPakan,
      mati: mati ?? this.mati,
      keterangan: keterangan ?? this.keterangan,
      jenisPakanId: jenisPakanId ??
          this.jenisPakanId, // Properti untuk menyimpan ID jenis pakan
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
