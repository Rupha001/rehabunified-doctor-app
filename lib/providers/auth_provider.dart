import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _doctorName = '';
  String _doctorEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get doctorName => _doctorName;
  String get doctorEmail => _doctorEmail;

  // Mock credentials
  static const _validEmail = 'doctor@rehabunified.com';
  static const _validPassword = 'Doctor@123';

  bool login(String email, String password) {
    if (email.trim() == _validEmail && password == _validPassword) {
      _isLoggedIn = true;
      _doctorName = 'Dr. Priya Sharma';
      _doctorEmail = email.trim();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _doctorName = '';
    _doctorEmail = '';
    notifyListeners();
  }
}
