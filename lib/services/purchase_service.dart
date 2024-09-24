import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/purchase_model.dart';

class PurchaseService {
  final String _baseUrl =
      'http://192.168.137.1:8000/api'; // ganti dengan URL API Anda

  // Method to get all purchases
  Future<List<PurchaseModel>> getAllPurchases(String token) async {
    var url = Uri.parse('$_baseUrl/purchases');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the list of purchases from 'data'
      List<dynamic> purchasesData = jsonResponse['data'];

      // Convert the list of dynamic to list of PurchaseModel
      List<PurchaseModel> purchases =
          purchasesData.map((item) => PurchaseModel.fromJson(item)).toList();

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
      return PurchaseModel.fromJson(jsonDecode(response.body));
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
      int id, PurchaseModel purchase, String token) async {
    var url = Uri.parse('$_baseUrl/purchases/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      'quantity': purchase.quantity,
      'price_per_unit': purchase.pricePerUnit,
      'total_price': purchase.totalPrice,
    });

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return PurchaseModel.fromJson(jsonDecode(response.body));
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update purchase');
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

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete purchase');
    }
  }
}
