import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/sale_model.dart';

class SaleService {
  final String baseUrl = 'http://192.168.137.1:8000/api';

  Future<List<SaleModel>> getAllSales(String token) async {
    var url = Uri.parse('$baseUrl/sales');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['data'] is List) {
        List<SaleModel> sales = (jsonData['data'] as List)
            .map((item) => SaleModel.fromJson(item))
            .toList();
        return sales;
      } else {
        debugPrint('Unexpected data format: ${jsonData['data']}');
        return [];
      }
    } else {
      debugPrint('Failed to load sales: ${response.body}');
      throw Exception('Failed to load sales');
    }
  }

  Future<List<SaleModel>> getAllLaporanSales(String token) async {
    var url = Uri.parse('$baseUrl/salesreport');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['data'] is List) {
        List<SaleModel> sales = (jsonData['data'] as List)
            .map((item) => SaleModel.fromJson(item))
            .toList();
        return sales;
      } else {
        debugPrint('Unexpected data format: ${jsonData['data']}');
        return [];
      }
    } else {
      debugPrint('Failed to load sales: ${response.body}');
      throw Exception('Failed to load sales');
    }
  }

  // Method to get a sale by ID
  Future<SaleModel> getSaleById(int id, String token) async {
    var url = Uri.parse('$baseUrl/sales/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return SaleModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load sale');
    }
  }

  // Method to create a new sale
  Future<bool> createSale(Map<String, dynamic> saleData, String token) async {
    var url = Uri.parse('$baseUrl/sales');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(saleData);

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to create sale');
    }
  }

  // Method to update a sale by ID
  Future<bool> updateSale(
      int id, Map<String, dynamic> saleData, String token) async {
    var url = Uri.parse('$baseUrl/sales/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(saleData);

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update sale');
    }
  }

  // Method to delete a sale by ID
  Future<bool> deleteSale(int id, String token) async {
    var url = Uri.parse('$baseUrl/sales/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete sale');
    }
  }

  // Method to get sales by customer ID
  Future<List<SaleModel>> getSalesByCustomerId(
      int customerId, String token) async {
    var url = Uri.parse('$baseUrl/sales/customer/$customerId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> salesData = jsonDecode(response.body);
      return salesData.map((item) => SaleModel.fromJson(item)).toList();
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load sales by customer ID');
    }
  }
}
