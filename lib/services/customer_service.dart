import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/customer_model.dart';

class CustomerService {
  String baseUrl = 'http://udandika.simandika.my.id/api';

  // Method to get all customers
  Future<List<CustomerModel>> getAllCustomers(String token) async {
    var url = Uri.parse('$baseUrl/customers');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<CustomerModel> customers =
          data.map((item) => CustomerModel.fromJson(item)).toList();
      return customers;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load customers');
    }
  }

  Future<List<CustomerModel>> getAllLaporanCustomers(String token) async {
    var url = Uri.parse('$baseUrl/customersreport');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<CustomerModel> customers =
          data.map((item) => CustomerModel.fromJson(item)).toList();
      return customers;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load customers');
    }
  }
  // Method to get customers by type (e.g., "purchase" or "sale")

  // Method to get a specific customer by ID
  Future<CustomerModel> getCustomerById(int id, String token) async {
    var url = Uri.parse('$baseUrl/customers/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return CustomerModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load customer');
    }
  }

  // Method to create a new customer
  Future<bool> createCustomer(CustomerModel customer, String token) async {
    var url = Uri.parse('$baseUrl/customers');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(customer.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to create customer');
    }
  }

  // Method to update a customer by ID
  Future<bool> updateCustomer(
      int id, CustomerModel customer, String token) async {
    var url = Uri.parse('$baseUrl/customers/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(customer.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update customer');
    }
  }

  // Method to delete a customer by ID
  Future<bool> deleteCustomer(int id, String token) async {
    var url = Uri.parse('$baseUrl/customers/$id');
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
