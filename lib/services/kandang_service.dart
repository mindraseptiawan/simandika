import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/kandang_model.dart';

class KandangService {
  String baseUrl = 'http://192.168.1.6:8000/api';

  // Method untuk mendapatkan daftar semua kandang
  Future<List<KandangModel>> getKandangs(String token) async {
    var url = Uri.parse('$baseUrl/kandang');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data']['data'];
      List<KandangModel> kandangs =
          data.map((item) => KandangModel.fromJson(item)).toList();

      return kandangs;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load kandangs');
    }
  }

  // Method untuk mendapatkan detail kandang berdasarkan ID
  Future<KandangModel> getKandangById(int id, String token) async {
    var url = Uri.parse('$baseUrl/kandang/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      return KandangModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load kandang');
    }
  }

  // Method untuk menambahkan kandang, memerlukan peran "pimpinan"
  Future<bool> addKandang(KandangModel kandang, String token) async {
    var url = Uri.parse('$baseUrl/kandang');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(kandang.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to add kandang');
    }
  }

  // Method untuk memperbarui kandang berdasarkan ID, memerlukan peran "pimpinan"
  Future<bool> updateKandang(int id, KandangModel kandang, String token) async {
    var url = Uri.parse('$baseUrl/kandang/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(kandang.toJson());

    var response = await http.put(url, headers: headers, body: body);
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update kandang');
    }
  }

  // Method untuk menghapus kandang berdasarkan ID, memerlukan peran "pimpinan"
  Future<bool> deleteKandang(int id, String token) async {
    var url = Uri.parse('$baseUrl/kandang/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete kandang');
    }
  }
}
