class ActivityLogModel {
  final int id;
  final String description;
  final String causedBy;
  final String causedByEmail;
  final String createdAt;
  final String logName;

  ActivityLogModel({
    required this.id,
    required this.description,
    required this.causedBy,
    required this.causedByEmail,
    required this.createdAt,
    required this.logName,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      causedBy: json['causer_name'] ?? 'Sistem', // Ambil causer_name langsung
      causedByEmail: json['causer_email'] ?? '',
      createdAt: json['created_at'] ?? '',
      logName: json['log_name'] ?? '',
    );
  }
}
