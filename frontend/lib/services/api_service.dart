import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Make sure your login method looks like this:
Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Login status: ${response.statusCode}');
    print('Login response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      return data;
    } else {
      throw Exception('Invalid username or password');
    }
  } catch (e) {
    print('Login error: $e');
    throw Exception('Connection failed. Make sure backend is running.');
  }
}
  
  // Enroll Child
  Future<Map<String, dynamic>> enrollChild(Map<String, dynamic> childData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/'),
      headers: await _getHeaders(),
      body: json.encode(childData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to enroll child');
    }
  }
  
  // Get All Children
  Future<List<dynamic>> getChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load children');
    }
  }
  
  // Get Bed Availability
  Future<Map<String, dynamic>> getBedAvailability() async {
    final response = await http.get(
      Uri.parse('$baseUrl/resources/beds/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load bed data');
    }
  }
  
  // Request Transport
  Future<Map<String, dynamic>> requestTransport(int childId, Map<String, dynamic> transportData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/$childId/request_transport/'),
      headers: await _getHeaders(),
      body: json.encode(transportData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to request transport');
    }
  }
  
  // Get Notifications
  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }


  // Update child
Future<Map<String, dynamic>> updateChild(int childId, Map<String, dynamic> childData) async {
  final response = await http.put(
    Uri.parse('$baseUrl/children/$childId/'),
    headers: await _getHeaders(),
    body: json.encode(childData),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to update child');
  }
}

// Get single child
Future<Map<String, dynamic>> getChild(int childId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/children/$childId/'),
    headers: await _getHeaders(),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load child');
  }
}

// Get current user profile
Future<Map<String, dynamic>> getCurrentUser() async {
  final response = await http.get(
    Uri.parse('$baseUrl/users/me/'),
    headers: await _getHeaders(),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user profile');
  }
}

// Update user profile
Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/users/me/'),
    headers: await _getHeaders(),
    body: json.encode(userData),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to update profile');
  }
}

// Change password
Future<void> changePassword(String currentPassword, String newPassword) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/change-password/'),
    headers: await _getHeaders(),
    body: json.encode({
      'current_password': currentPassword,
      'new_password': newPassword,
    }),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to change password');
  }
}
// Register new user
Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/register/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(userData),
  );
  
  if (response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    final error = json.decode(response.body);
    throw Exception(error['detail'] ?? 'Registration failed');
  }
}

// Staff Management
Future<List<dynamic>> getStaff() async {
  final response = await http.get(
    Uri.parse('$baseUrl/staff/'),
    headers: await _getHeaders(),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load staff');
  }
}

Future<Map<String, dynamic>> addStaff(Map<String, dynamic> staffData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/staff/'),
    headers: await _getHeaders(),
    body: json.encode(staffData),
  );
  
  if (response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to add staff');
  }
}

Future<void> toggleStaffStatus(int staffId) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/staff/$staffId/toggle/'),
    headers: await _getHeaders(),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to toggle staff status');
  }
}

// Orphanage Management
Future<List<dynamic>> getOrphanages() async {
  final response = await http.get(
    Uri.parse('$baseUrl/orphanages/'),
    headers: await _getHeaders(),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load orphanages');
  }
}

Future<Map<String, dynamic>> addOrphanage(Map<String, dynamic> orphanageData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/orphanages/'),
    headers: await _getHeaders(),
    body: json.encode(orphanageData),
  );
  
  if (response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to add orphanage');
  }
}

}