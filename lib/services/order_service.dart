import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/order_model.dart';

class OrderService {
  String baseUrl = 'http://192.168.137.1:8000/api';

  // Method to get all orders
  Future<List<OrderModel>> getAllOrders(String token) async {
    var url = Uri.parse('$baseUrl/orders');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Mengurai JSON ke dalam Map, karena responsnya berisi meta dan data
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Ambil daftar pesanan dari objek 'data'
      List<dynamic> ordersData = jsonResponse['data']['data'];

      // Ubah menjadi List<OrderModel>
      List<OrderModel> orders =
          ordersData.map((item) => OrderModel.fromJson(item)).toList();

      return orders;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load orders');
    }
  }

  // Method to get orders by type (e.g., "purchase" or "sale")
  Future<List<OrderModel>> getOrdersByCustomerId(
      String token, int customerId) async {
    var url = Uri.parse('$baseUrl/orders/customer/$customerId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the list of orders directly from 'data'
      List<dynamic> ordersData = jsonResponse['data'];

      // Convert the dynamic list into a list of OrderModel
      List<OrderModel> orders =
          ordersData.map((item) => OrderModel.fromJson(item)).toList();

      return orders;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load orders by customer ID');
    }
  }

  // Method to get a specific order by ID
  Future<OrderModel> getOrderById(int id, String token) async {
    var url = Uri.parse('$baseUrl/orders/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return OrderModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load order');
    }
  }

  // Method to create a new order
  Future<bool> createOrder(Map<String, dynamic> orderData, String token) async {
    var url = Uri.parse('$baseUrl/orders');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(orderData);

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      throw Exception('Failed to create order');
    }
  }

  // Method to update a order by ID
  Future<bool> updateOrder(int id, OrderModel order, String token) async {
    var url = Uri.parse('$baseUrl/orders/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(order.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update order');
    }
  }

  // Method to delete a order by ID
  Future<bool> deleteOrder(int id, String token) async {
    var url = Uri.parse('$baseUrl/orders/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete order');
    }
  }

  Future<bool> setPricePerUnit(
      int orderId, double pricePerUnit, String token) async {
    var url = Uri.parse('$baseUrl/orders/$orderId/set-price');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      'price_per_unit': pricePerUnit,
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to set price per unit');
    }
  }

  Future<bool> processOrder(String token, int orderId, int kandangId) async {
    var url = Uri.parse('$baseUrl/orders/$orderId/process');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var body = {
      'kandang_id': kandangId,
    };

    try {
      var response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if the request was successful
        if (jsonResponse['meta']['status'] == 'success') {
          return true;
        } else {
          throw Exception(
              jsonResponse['meta']['message'] ?? 'Failed to process order');
        }
      } else if (response.statusCode == 400) {
        // Check if the error is due to insufficient stock
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['meta']['message'] ==
            'Stok di kandang tidak mencukupi') {
          throw Exception('Stock in kandang is insufficient');
        } else {
          throw Exception(
              jsonResponse['meta']['message'] ?? 'Failed to process order');
        }
      } else {
        debugPrint('Response body: ${response.body}');
        throw Exception(
            'Failed to process order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error processing order: $e');
      throw Exception('Failed to process order: $e');
    }
  }

  Future<bool> submitPaymentProof(int orderId, String paymentMethod,
      String? paymentProofPath, String token) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId/submit-payment');

      var request = http.MultipartRequest('POST', url)
        ..fields['payment_method'] = paymentMethod;

      if (paymentProofPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'payment_proof', paymentProofPath));
      }

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to submit payment proof');
      }
    } catch (e) {
      print('Error submitting payment proof: $e');
      return false;
    }
  }

  Future<bool> verifyPayment(int orderId, String token) async {
    var url = Uri.parse('$baseUrl/orders/$orderId/verify-payment');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to verify payment');
    }
  }

  Future<List<OrderModel>> getOrdersByStatus(
      String token, String status) async {
    var url = Uri.parse('$baseUrl/orders/status/$status');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if the request was successful
        if (jsonResponse['meta']['status'] == 'success') {
          // Access the list of orders from 'data'
          List<dynamic> ordersData = jsonResponse['data'];

          // Convert the list of dynamic to list of OrderModel
          List<OrderModel> orders =
              ordersData.map((item) => OrderModel.fromJson(item)).toList();

          return orders;
        } else {
          throw Exception(
              jsonResponse['meta']['message'] ?? 'Failed to load orders');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        debugPrint('Response body: ${response.body}');
        throw Exception(
            'Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getOrdersByStatus: $e');
      throw Exception('Failed to load orders: $e');
    }
  }
}
