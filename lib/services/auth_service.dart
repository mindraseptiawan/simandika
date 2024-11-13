import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simandika/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  String baseUrl = 'http://udandika.simandika.my.id/api';

  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    var url = Uri.parse('$baseUrl/register');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
    });

    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data['user']);
      user.token = 'Bearer ' + data['access_token'];

      return user;
    } else {
      throw Exception('Gagal Register');
    }
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    var url = Uri.parse('$baseUrl/login');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'username': username,
      'password': password,
    });

    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      debugPrint('User Data: ${data['user']}');
      UserModel user = UserModel.fromJson(data['user']);
      user.token = 'Bearer ' + data['access_token'];

      return user;
    } else {
      debugPrint(response.body);
      throw Exception('Gagal Login');
    }
  }

  Future<void> logout({required String token}) async {
    var url = Uri.parse('$baseUrl/logout');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    var response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }

  Future<UserModel> updateProfile({
    required String token,
    required String name,
    required String username,
    required String email,
    required String phone,
  }) async {
    var url = Uri.parse('$baseUrl/updateProfile');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    var body = jsonEncode({
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
    });

    var response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data['user']);
      user.token = token; // Reuse the existing token

      return user;
    } else {
      throw Exception('Gagal Update Profile');
    }
  }
}
