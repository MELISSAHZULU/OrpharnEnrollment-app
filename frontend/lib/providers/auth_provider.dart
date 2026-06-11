import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  AuthProvider() {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    _isAuthenticated = token != null && token.isNotEmpty;
    notifyListeners();
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.login(username, password);
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}