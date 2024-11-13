import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/purchase_model.dart';

class PurchaseService {
  String _baseUrl = 'http://udandika.simandika.my.id/api';

  // Method to get all purchases
  Future<List<PurchaseModel>> getAllPurchases(String token) async {
    var url = Uri.parse('$_baseUrl/purchases');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List data = jsonData['data']; // Akses data melalui key "data"
      List<PurchaseModel> purchases =
          data.map((item) => PurchaseModel.fromJson(item)).toList();
      return purchases;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchases');
    }
  }

  Future<List<PurchaseModel>> getAllLaporanPurchases(String token) async {
    var url = Uri.parse('$_baseUrl/purchasesreport');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List data = jsonData['data']; // Akses data melalui key "data"
      List<PurchaseModel> purchases =
          data.map((item) => PurchaseModel.fromJson(item)).toList();
      return purchases;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchases');
    }
  }

  // Method to get a specific purchase by ID
  Future<PurchaseModel> getPurchaseById(int id, String token) async {
    var url = Uri.parse('$_baseUrl/purchases/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return PurchaseModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchase');
    }
  }

  Future<List<PurchaseModel>> getPurchaseBySupplierId(
      String token, int supplierId) async {
    var url = Uri.parse('$_baseUrl/purchases/supplier/$supplierId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> purchasesData = jsonResponse['data'];
      List<PurchaseModel> purchases =
          purchasesData.map((item) => PurchaseModel.fromJson(item)).toList();
      return purchases;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchase');
    }
  }

  // Method to create a new purchase
  Future<bool> createPurchase(
      Map<String, dynamic> purchaseData, String token) async {
    var url = Uri.parse('$_baseUrl/purchases');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(purchaseData);

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to create order');
    }
  }

  // Method to update a purchase by ID
  Future<PurchaseModel> updatePurchase(
      int id, Map<String, dynamic> purchaseData, String token) async {
    var url = Uri.parse('$_baseUrl/purchases/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(purchaseData);

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        debugPrint('Update response: $jsonResponse'); // Log respons

        if (jsonResponse['data'] != null) {
          var purchaseData = jsonResponse['data']['purchase'];
          if (purchaseData['id'] != null &&
              purchaseData['supplier_id'] != null &&
              purchaseData['quantity'] != null &&
              purchaseData['price_per_unit'] != null &&
              purchaseData['kandang_id'] != null) {
            return PurchaseModel.fromJson(purchaseData);
          } else {
            throw Exception('Data tidak lengkap dalam respons');
          }
        } else {
          throw Exception('Data tidak ditemukan dalam respons');
        }
      } else {
        debugPrint(
            'Gagal memperbarui pembelian. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Gagal memperbarui pembelian');
      }
    } catch (e) {
      debugPrint('Error dalam updatePurchase: $e');
      rethrow;
    }
  }

  // Method to delete a purchase by ID
  Future<bool> deletePurchase(int id, String token) async {
    var url = Uri.parse('$_baseUrl/purchases/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete purchase');
    }
  }
}
