import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/pemeliharaan_model.dart';

class PemeliharaanService {
  final String baseUrl = 'http://192.168.137.1:8000/api';

  // Method untuk mendapatkan daftar semua pemeliharaan
  Future<List<PemeliharaanModel>> getPemeliharaans(String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      List<PemeliharaanModel> pemeliharaans =
          data.map((item) => PemeliharaanModel.fromJson(item)).toList();

      return pemeliharaans;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to load pemeliharaan');
    }
  }

  // Method untuk mendapatkan detail pemeliharaan berdasarkan ID
  Future<PemeliharaanModel> getPemeliharaanById(int id, String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      return PemeliharaanModel.fromJson(data);
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to load pemeliharaan');
    }
  }

  Future<List<PemeliharaanModel>> getPemeliharaansByKandang(
      int kandangId, String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan/kandang/$kandangId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      // Periksa jika ada kesalahan dalam response JSON
      if (jsonResponse['meta']['status'] != 'success') {
        throw Exception('Failed to load pemeliharaan');
      }

      // Akses data yang benar
      List<dynamic> data = jsonResponse['data']['data'];
      List<PemeliharaanModel> pemeliharaans =
          data.map((item) => PemeliharaanModel.fromJson(item)).toList();

      return pemeliharaans;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to load pemeliharaan');
    }
  }

  // Method untuk menambahkan pemeliharaan, memerlukan peran "pimpinan"
  Future<bool> addPemeliharaan(
      PemeliharaanModel pemeliharaan, String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(pemeliharaan.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to add pemeliharaan');
    }
  }

  // Method untuk memperbarui pemeliharaan berdasarkan ID, memerlukan peran "pimpinan"
  Future<bool> updatePemeliharaan(
      int id, PemeliharaanModel pemeliharaan, String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(pemeliharaan.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to update pemeliharaan');
    }
  }

  // Method untuk menghapus pemeliharaan berdasarkan ID, memerlukan peran "pimpinan"
  Future<bool> deletePemeliharaan(int id, String token) async {
    var url = Uri.parse('$baseUrl/pemeliharaan/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to delete pemeliharaan');
    }
  }
}
