import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:simandika/models/log_model.dart';

class ActivityLogService {
  String baseUrl = 'http://udandika.simandika.my.id/api';

  Future<List<ActivityLogModel>> getActivityLogs(String token) async {
    var url = Uri.parse('$baseUrl/activity-logs');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data =
            jsonData['data']['data']; // Ambil data aktivitas dari respons API

        List<ActivityLogModel> activityLogs = data
            .map<ActivityLogModel>((item) => ActivityLogModel.fromJson(item))
            .toList();

        return activityLogs;
      } else if (response.statusCode == 403) {
        // Tangani kasus tidak punya akses
        throw Exception(
            'Anda tidak memiliki akses untuk melihat log aktivitas');
      } else {
        // Tangani error lainnya
        debugPrint(response.body);
        throw Exception('Gagal memuat log aktivitas');
      }
    } catch (e) {
      debugPrint('Error in getActivityLogs: $e');
      rethrow;
    }
  }
}
