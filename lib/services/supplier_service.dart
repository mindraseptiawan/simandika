import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/supplier_model.dart';

class SupplierService {
  String baseUrl = 'http://192.168.137.1:8000/api';

  // Method to get all suppliers
  Future<List<SupplierModel>> getAllSuppliers(String token) async {
    var url = Uri.parse('$baseUrl/suppliers');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<SupplierModel> suppliers =
          data.map((item) => SupplierModel.fromJson(item)).toList();
      return suppliers;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load suppliers');
    }
  }

  // Method to get suppliers by type (e.g., "purchase" or "sale")

  // Method to get a specific customer by ID
  Future<SupplierModel> getSupplierById(int id, String token) async {
    var url = Uri.parse('$baseUrl/suppliers/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return SupplierModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load supplier');
    }
  }

  // Method to create a new customer
  Future<bool> createSupplier(SupplierModel supplier, String token) async {
    var url = Uri.parse('$baseUrl/suppliers');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(supplier.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to create supplier');
    }
  }

  // Method to update a customer by ID
  Future<bool> updateSupplier(
      int id, SupplierModel supplier, String token) async {
    var url = Uri.parse('$baseUrl/suppliers/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(supplier.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update supplier');
    }
  }

  // Method to delete a customer by ID
  Future<bool> deleteSupplier(int id, String token) async {
    var url = Uri.parse('$baseUrl/suppliers/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete customer');
    }
  }
}
