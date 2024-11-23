// cashflow_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simandika/models/cashflow_model.dart';
import 'dart:convert';

class CashflowService {
  String baseUrl = 'http://192.168.137.1:8000/api';

  Future<List<CashflowModel>> getCashflows(String token) async {
    var url = Uri.parse('$baseUrl/cashflows');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']; // Ambil data dari map
      List<CashflowModel> cashflows = data
          .map((item) => CashflowModel.fromJson(item))
          .where((cashflow) => cashflow != null) // Filter out null values
          .toList()
          .cast<
              CashflowModel>(); // Ubah list yang berisi elemen dinamis menjadi sebuah list yang berisi elemen CashflowModel
      return cashflows;
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load customers');
    }
  }
}
