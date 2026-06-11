import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/role_permissions.dart';
import '../models/user.dart';
import '../models/role_permissions.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  UserRole _userRole = UserRole.socialWorker;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserRole get userRole => _userRole;
  
  AuthProvider() {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final roleCode = prefs.getString('user_role');
    
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      if (roleCode != null) {
        _userRole = UserRoleExtension.fromCode(roleCode);
      }
      await loadUserProfile();
    }
    notifyListeners();
  }
  
  Future<void> loadUserProfile() async {
    try {
      final userData = await _apiService.getCurrentUser();
      _currentUser = User.fromJson(userData);
      if (userData['role'] != null) {
        _userRole = UserRoleExtension.fromCode(userData['role']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userData['role']);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(username, password);
      _isAuthenticated = true;
      
      // Get user role from response or fetch separately
      if (response['role'] != null) {
        _userRole = UserRoleExtension.fromCode(response['role']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', response['role']);
      }
      
      await loadUserProfile();
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
    _currentUser = null;
    notifyListeners();
  }
  
  bool hasPermission(String permission) {
    return RolePermissions.hasPermission(_userRole, permission);
  }
}