import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/stock_model.dart';

class StockService {
  final String _baseUrl =
      'http://udandika.simandika.my.id/api'; // ganti dengan URL API Anda

  // Method to get all purchases
  Future<List<StockMovementModel>> getAllStocks(String token) async {
    var url = Uri.parse('$_baseUrl/stocks');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the list of purchases from 'data'
      List<dynamic> stocksData = jsonResponse['data'];

      // Convert the list of dynamic to list of StockMovementModel
      List<StockMovementModel> stocks =
          stocksData.map((item) => StockMovementModel.fromJson(item)).toList();

      return stocks;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchases');
    }
  }

  Future<List<StockMovementModel>> getAllLaporanStocks(String token) async {
    var url = Uri.parse('$_baseUrl/stocksreport');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the list of purchases from 'data'
      List<dynamic> stocksData = jsonResponse['data'];

      // Convert the list of dynamic to list of StockMovementModel
      List<StockMovementModel> stocks =
          stocksData.map((item) => StockMovementModel.fromJson(item)).toList();

      return stocks;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchases');
    }
  }

  // Method to get a specific purchase by ID
  Future<StockMovementModel> getStockById(int id, String token) async {
    var url = Uri.parse('$_baseUrl/stocks/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return StockMovementModel.fromJson(jsonDecode(response.body));
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load purchase');
    }
  }

  Future<List<StockMovementModel>> getStockByKandangId(
      int kandangId, String token) async {
    var url = Uri.parse('$_baseUrl/stocks/kandang/$kandangId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the list of stocks from 'data'
      List<dynamic> stocksData = jsonResponse['data'];

      // Convert the list of dynamic to list of StockMovementModel
      List<StockMovementModel> stocks =
          stocksData.map((item) => StockMovementModel.fromJson(item)).toList();

      return stocks;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load stocks');
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
  Future<StockMovementModel> updateStock(
      int id, StockMovementModel stock, String token) async {
    var url = Uri.parse('$_baseUrl/purchases/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // var body = jsonEncode({
    //   'quantity': purchase.quantity,
    //   'price_per_unit': purchase.pricePerUnit,
    //   'total_price': purchase.totalPrice,
    // });

    var response = await http.put(url, headers: headers);

    if (response.statusCode == 200) {
      return StockMovementModel.fromJson(jsonDecode(response.body));
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
