import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/transaksi_model.dart';

class TransaksiService {
  String baseUrl = 'http://192.168.137.1:8000/api';

  // Method to get all transactions
  Future<List<TransaksiModel>> getAllTransactions(String token) async {
    var url = Uri.parse('$baseUrl/transactions');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List data = jsonData['data']; // Akses data melalui key "data"
      List<TransaksiModel> transactions = data
          .map((item) => TransaksiModel.fromJson(item))
          .where((transaction) => transaction.amount != null)
          .toList();
      return transactions;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load transactions');
    }
  }

  Future<List<TransaksiModel>> getAllLaporanTransactions(String token) async {
    var url = Uri.parse('$baseUrl/transactionsreport');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List data = jsonData['data']; // Akses data melalui key "data"
      List<TransaksiModel> transactions = data
          .map((item) => TransaksiModel.fromJson(item))
          .where((transaction) => transaction.amount != null)
          .toList();
      return transactions;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load transactions');
    }
  }

  // Method to get transactions by type (e.g., "purchase" or "sale")
  Future<List<TransaksiModel>> getTransactionsByType(
      String token, String type) async {
    var url = Uri.parse('$baseUrl/transactions/type/$type');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List data = jsonData['data']; // Akses
      List<TransaksiModel> transactions =
          data.map((item) => TransaksiModel.fromJson(item)).toList();
      return transactions;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load transactions by type');
    }
  }

  // Method to get a specific transaction by ID
  Future<TransaksiModel> getTransactionById(int id, String token) async {
    var url = Uri.parse('$baseUrl/transactions/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return TransaksiModel.fromJson(data);
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load transaction');
    }
  }

  // Method to create a new transaction
  Future<bool> createTransaction(
      TransaksiModel transaction, String token) async {
    var url = Uri.parse('$baseUrl/transactions');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(transaction.toJson());

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to create transaction');
    }
  }

  // Method to update a transaction by ID
  Future<bool> updateTransaction(
      int id, TransaksiModel transaction, String token) async {
    var url = Uri.parse('$baseUrl/transactions/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode(transaction.toJson());

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to update transaction');
    }
  }

  // Method to delete a transaction by ID
  Future<bool> deleteTransaction(int id, String token) async {
    var url = Uri.parse('$baseUrl/transactions/$id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to delete transaction');
    }
  }
}
