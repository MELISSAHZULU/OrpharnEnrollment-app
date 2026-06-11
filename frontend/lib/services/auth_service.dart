import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userType = '';
  String _userName = '';

  bool get isAuthenticated => _isAuthenticated;
  String get userType => _userType;
  String get userName => _userName;

  Future<bool> login(String email, String password, String userType) async {
    // TODO: Replace with actual API call
    // For now, demo authentication
    await Future.delayed(Duration(seconds: 1));
    
    if (email == 'demo@orphanage.mw' && password == 'demo123') {
      _isAuthenticated = true;
      _userType = userType;
      _userName = email.split('@')[0];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userType', userType);
      await prefs.setString('userName', _userName);
      
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userType = '';
    _userName = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    _userType = prefs.getString('userType') ?? '';
    _userName = prefs.getString('userName') ?? '';
    notifyListeners();
  }
}