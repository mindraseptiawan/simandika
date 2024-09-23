import 'package:flutter/material.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/providers/auth_provider.dart';

class KandangProvider with ChangeNotifier {
  late KandangModel _kandang;
  final AuthProvider authProvider; // Tambahkan AuthProvider sebagai dependency

  KandangProvider({required this.authProvider});

  KandangModel get kandang => _kandang;

  set kandang(KandangModel kandang) {
    _kandang = kandang;
    notifyListeners();
  }

  Future<bool> addKandang(KandangModel kandang) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      bool success = await KandangService().addKandang(kandang, token!);
      if (success) {
        _kandang = kandang;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateKandang(int id, KandangModel kandang) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      bool success = await KandangService().updateKandang(id, kandang, token!);
      if (success) {
        _kandang = kandang;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deleteKandang(int id) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      return await KandangService().deleteKandang(id, token!);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> fetchKandang(int id) async {
    try {
      // Dapatkan token dari AuthProvider
      final token = authProvider.user.token;

      KandangModel kandang = await KandangService().getKandangById(id, token!);
      _kandang = kandang;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
