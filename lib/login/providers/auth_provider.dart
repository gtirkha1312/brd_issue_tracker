import 'package:brd_issue_tracker/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  UserModel? _loggedInUser;
  bool _error = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  UserModel? get loggedInUser => _loggedInUser;
  bool get error => _error;

  void setLoggedIn(bool loggedInBool) {
    _isLoggedIn = loggedInBool;
    notifyListeners();
  }

  void setLoading(bool loadingBool) {
    _isLoading = loadingBool;
    notifyListeners();
  }

  void setLoggedInUser(UserModel userModel) {
    _loggedInUser = userModel;
    notifyListeners();
  }

  void setError(bool errorBool) {
    _error = errorBool;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    dev.log("checkLogin called", name: "Auth Provider");
    if (!isLoading) setLoading(true);
    if (isLoggedIn) setLoading(false);
    if (error) setError(false);

    try {
      UserModel? res = await loginCheck();
      if (res != null) {
        _isLoggedIn = true;
        _loggedInUser = res;
      } else {
        _isLoggedIn = false;
        _error = true;
        notifyListeners();
      }
    } catch (e) {
      dev.log(e.toString(), name: "Auth Provider Exception in Check");
      setError(true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    dev.log("login called", name: "Auth Provider");
    if (!isLoading) setLoading(true);
    if (isLoggedIn) setLoading(false);
    if (error) setError(false);
    try {
      final res = await loginService(email, password);
      if (res != null) {
        _isLoading = false;
        _isLoggedIn = true;
        _loggedInUser = res;
        notifyListeners();
      }
    } catch (e) {
      dev.log(e.toString(), name: "Auth Provider Exception in Login");
      setError(true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await logoutService().then((value) => setLoggedIn(false));
  }
}
