import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simandika/models/pakan_model.dart';
// Pastikan Anda memiliki PakanModel yang sesuai

class PakanService {
  final String baseUrl = 'http://udandika.simandika.my.id/api';

  Future<List<PakanModel>> getPakan(String token) async {
    var url = Uri.parse('$baseUrl/pakan');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Print the response body to debug
      if (kDebugMode) {
        debugPrint('Response body: ${response.body}');
      }
      // Decode the response
      List<dynamic> data = jsonDecode(response.body);

      // Debug the data
      if (kDebugMode) {
        debugPrint('Data: $data');
      }
      // Convert data to PakanModel list
      return data.map((json) {
        debugPrint('JSON item: $json'); // Debug each item
        return PakanModel.fromJson(json);
      }).toList();
    } else {
      if (kDebugMode) {
        debugPrint(response.body);
      }
      throw Exception('Failed to load pakan');
    }
  }

  Future<bool> addPakan(PakanModel pakan, String token) async {
    var url = Uri.parse('$baseUrl/pakan');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(pakan.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to add pakan');
    }
  }

  Future<bool> updatePakan(int id, PakanModel pakan, String token) async {
    var url = Uri.parse('$baseUrl/pakan/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(pakan.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update pakan');
    }
  }

  Future<bool> deletePakan(int id, String token) async {
    var url = Uri.parse('$baseUrl/pakan/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);

      throw Exception('Failed to delete pakan');
    }
  }
}
