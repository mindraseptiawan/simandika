import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/user_model.dart';

class UserService {
  String baseUrl = 'http://udandika.simandika.my.id/api';

  // Ambil daftar pengguna
  Future<List<UserModel>> getUsers(String token) async {
    var url = Uri.parse('$baseUrl/users');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var response = await http.get(url, headers: headers);
    if (kDebugMode) {
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
    }
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      List<UserModel> users =
          data.map((item) => UserModel.fromJson(item)).toList();
      return users;
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      throw Exception('Failed to load users');
    }
  }

  // Ambil peran pengguna
  Future<List<String>> getUserWithRoles(String token) async {
    var url = Uri.parse('$baseUrl/user/roles');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var response = await http.get(url, headers: headers);
    if (kDebugMode) {
      debugPrint('Roles Status Code: ${response.statusCode}');
      debugPrint('Roles Response Body: ${response.body}');
    }
    if (response.statusCode == 200) {
      // Parse the user data including roles
      final data = jsonDecode(response.body);
      List<String> roles = List<String>.from(data['roles']);
      return roles;
    } else {
      throw Exception('Failed to load user roles');
    }
  }

  // Hapus pengguna berdasarkan ID
  Future<bool> deleteUser(int userId, String token) async {
    var url = Uri.parse('$baseUrl/user/$userId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.delete(url, headers: headers);
    if (kDebugMode) {
      debugPrint('Delete User Status Code: ${response.statusCode}');
      debugPrint('Delete User Response Body: ${response.body}');
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to delete user');
    }
  }

  // Assign role ke pengguna
  Future<bool> assignRole(int id, String role, String token) async {
    var url = Uri.parse('$baseUrl/user/$id/role');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode({
      'role': role,
    });

    // Debugging request details
    if (kDebugMode) {
      debugPrint('Request URL: $url');
      debugPrint('Request Headers: $headers');
      debugPrint('Request Body: $body');
    }

    try {
      var response = await http.put(url, headers: headers, body: body);

      // Debugging response details
      if (kDebugMode) {
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to assign role');
      }
    } catch (e) {
      // Debugging error details
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
      rethrow; // Re-throw the exception to be handled by the caller
    }
  }

  static updateUser(UserModel updatedUser) {}

  // final response = await http.post(
  //   Uri.parse('$baseUrl/user/assign-role'),
  //   headers: {
  //     'Content-Type': 'application/json',
  //   },
  //   body: jsonEncode({
  //     'user_id': userId,
  //     'role': role,
  //   }),
  // );

  // if (response.statusCode != 200) {
  //   throw Exception('Failed to assign role');
  // }
}
