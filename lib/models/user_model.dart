class UserModel {
  final int id;

  final String name;
  final String email;
  final String username;
  final String phone;
  final String? profilePhotoUrl; // Make this nullable if it can be null
  String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    this.profilePhotoUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      token: json['token'],
    );
  }
  factory UserModel.empty() {
    return UserModel(
      id: 0,
      name: '',
      email: '',
      username: '',
      phone: '',
      profilePhotoUrl: null,
      token: null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
    };
  }
}
