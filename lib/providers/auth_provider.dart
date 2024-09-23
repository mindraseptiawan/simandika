import 'package:flutter/material.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  late UserModel _user;

  UserModel get user => _user;

  set user(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserModel user = await AuthService().register(
        name: name,
        username: username,
        phone: phone,
        email: email,
        password: password,
      );

      _user = user;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      UserModel user = await AuthService().login(
        username: username,
        password: password,
      );

      _user = user;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await AuthService().logout(token: _user.token!);
      _user = UserModel.empty(); // Clear the user data
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      UserModel updatedUser = await AuthService().updateProfile(
        token: _user.token!,
        name: name,
        username: username,
        email: email,
        phone: phone,
      );

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
