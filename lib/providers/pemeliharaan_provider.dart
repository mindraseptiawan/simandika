import 'package:flutter/material.dart';
import 'package:simandika/models/pemeliharaan_model.dart';
import 'package:simandika/services/pemeliharaan_service.dart';
import 'package:simandika/providers/auth_provider.dart'; // Pastikan Anda mengimpor AuthProvider

class PemeliharaanProvider with ChangeNotifier {
  List<PemeliharaanModel> _pemeliharaans = [];
  final AuthProvider authProvider; // Tambahkan AuthProvider sebagai dependency

  PemeliharaanProvider({required this.authProvider});

  List<PemeliharaanModel> get pemeliharaans => _pemeliharaans;

  set pemeliharaans(List<PemeliharaanModel> pemeliharaans) {
    _pemeliharaans = pemeliharaans;
    notifyListeners();
  }

  Future<void> fetchPemeliharaansByKandang(int kandangId) async {
    try {
      final token = authProvider.user.token;
      _pemeliharaans = await PemeliharaanService()
          .getPemeliharaansByKandang(kandangId, token!);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      // Handle error or notify listeners of the error
    }
  }

  Future<bool> addPemeliharaan(PemeliharaanModel pemeliharaan) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      bool success =
          await PemeliharaanService().addPemeliharaan(pemeliharaan, token!);
      if (success) {
        _pemeliharaans.add(pemeliharaan);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updatePemeliharaan(
      int id, PemeliharaanModel pemeliharaan) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      bool success = await PemeliharaanService()
          .updatePemeliharaan(id, pemeliharaan, token!);
      if (success) {
        int index = _pemeliharaans.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pemeliharaans[index] = pemeliharaan;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deletePemeliharaan(int id) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      bool success = await PemeliharaanService().deletePemeliharaan(id, token!);
      if (success) {
        _pemeliharaans.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
