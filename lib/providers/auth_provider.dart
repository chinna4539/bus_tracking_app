import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isPasswordHidden = true;
  bool _isRememberMe = false;

  bool get isPasswordHidden => _isPasswordHidden;
  bool get isRememberMe => _isRememberMe;

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _isRememberMe = value;
    notifyListeners();
  }
}
