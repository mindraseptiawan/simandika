class PakanModel {
  final int id;
  final String jenis;
  final int? sisa;
  final String? keterangan;

  PakanModel({
    required this.id,
    required this.jenis,
    this.sisa,
    this.keterangan,
  });

  factory PakanModel.fromJson(Map<String, dynamic> json) {
    return PakanModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      jenis: json['jenis'] as String,
      sisa: json['sisa'] != null ? int.tryParse(json['sisa'].toString()) : null,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis': jenis,
      'sisa': sisa,
      'keterangan': keterangan,
    };
  }
}
