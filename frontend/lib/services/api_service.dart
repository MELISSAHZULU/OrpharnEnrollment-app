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
  
  // ==================== AUTHENTICATION ====================
  
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
        
        // Get user role after login
        await _fetchAndStoreUserRole();
        
        return data;
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Connection failed. Make sure backend is running.');
    }
  }
  
  Future<void> _fetchAndStoreUserRole() async {
    try {
      final userData = await getCurrentUser();
      final prefs = await SharedPreferences.getInstance();
      if (userData['role'] != null) {
        await prefs.setString('user_role', userData['role']);
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }
  
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
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
  }
  
  // ==================== USER PROFILE ====================
  
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
  
  // ==================== CHILDREN MANAGEMENT ====================
  
  Future<List<dynamic>> getChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? data;
    } else {
      throw Exception('Failed to load children');
    }
  }
  
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
  
  Future<void> deleteChild(int childId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/children/$childId/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete child');
    }
  }
  
  // ==================== EMERGENCY ENROLLMENT (Healthcare) ====================
  
  Future<Map<String, dynamic>> emergencyEnrollment(Map<String, dynamic> enrollmentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/emergency/'),
      headers: await _getHeaders(),
      body: json.encode(enrollmentData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to process emergency enrollment');
    }
  }
  
  Future<Map<String, dynamic>> birthEnrollment(Map<String, dynamic> birthData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/birth-enrollment/'),
      headers: await _getHeaders(),
      body: json.encode(birthData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to process birth enrollment');
    }
  }
  
  // ==================== MEDICAL RECORDS ====================
  
  Future<List<dynamic>> getMedicalRecords(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/medical-records/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load medical records');
    }
  }
  
  Future<Map<String, dynamic>> addMedicalRecord(int childId, Map<String, dynamic> recordData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/$childId/medical-records/'),
      headers: await _getHeaders(),
      body: json.encode(recordData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add medical record');
    }
  }
  
  Future<Map<String, dynamic>> recordVaccination(int childId, Map<String, dynamic> vaccineData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/$childId/vaccinations/'),
      headers: await _getHeaders(),
      body: json.encode(vaccineData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to record vaccination');
    }
  }
  
  Future<List<dynamic>> getVaccinations(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/vaccinations/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vaccinations');
    }
  }
  
  // ==================== BED MANAGEMENT ====================
  
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
  
  Future<Map<String, dynamic>> addBedSpace(Map<String, dynamic> bedData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resources/beds/'),
      headers: await _getHeaders(),
      body: json.encode(bedData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add bed space');
    }
  }
  
  Future<Map<String, dynamic>> updateBedSpace(int bedId, Map<String, dynamic> bedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/resources/beds/$bedId/'),
      headers: await _getHeaders(),
      body: json.encode(bedData),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update bed space');
    }
  }
  
  // ==================== TRANSPORT MANAGEMENT ====================
  
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
  
  Future<Map<String, dynamic>> requestEmergencyTransport(Map<String, dynamic> transportData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transport/emergency/'),
      headers: await _getHeaders(),
      body: json.encode(transportData),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to request emergency transport');
    }
  }
  
  Future<List<dynamic>> getTransportRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resources/transport/'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading transport: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> updateTransportStatus(int transportId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/resources/transport/$transportId/'),
      headers: await _getHeaders(),
      body: json.encode({'status': status}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update transport status');
    }
  }
  
  // ==================== STAFF MANAGEMENT ====================
  
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
  
  Future<Map<String, dynamic>> updateStaff(int staffId, Map<String, dynamic> staffData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/staff/$staffId/'),
      headers: await _getHeaders(),
      body: json.encode(staffData),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update staff');
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
  
  // ==================== ORPHANAGE MANAGEMENT ====================
  
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
  
  Future<Map<String, dynamic>> updateOrphanage(int orphanageId, Map<String, dynamic> orphanageData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orphanages/$orphanageId/'),
      headers: await _getHeaders(),
      body: json.encode(orphanageData),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update orphanage');
    }
  }
  
  // ==================== NOTIFICATIONS ====================
  
  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? data;
    } else {
      throw Exception('Failed to load notifications');
    }
  }
  
  Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark notification as read');
    }
  }
  
  Future<int> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread/count/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    } else {
      return 0;
    }
  }
  
  // ==================== DASHBOARD & ACTIVITIES ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final children = await getChildren();
      final beds = await getBedAvailability();
      final staff = await getStaff();
      final orphanages = await getOrphanages();
      
      return {
        'total_children': children.length,
        'available_beds': beds['available_beds'] ?? 0,
        'total_staff': staff.length,
        'active_staff': staff.where((s) => s['is_active'] == true).length,
        'active_orphanages': orphanages.where((o) => o['is_active'] == true).length,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {};
    }
  }
  
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final children = await getChildren();
      final recentChildren = children.take(5).map((child) => {
        'title': 'New Child Enrolled',
        'description': '${child['first_name']} ${child['last_name']} was enrolled',
        'type': 'enrollment',
        'time': _formatTimeAgo(child['enrollment_date']),
      }).toList();
      
      final transport = await getTransportRequests();
      final recentTransport = transport.take(3).map((t) => {
        'title': 'Transport Request',
        'description': 'Pickup from ${t['pickup_location']}',
        'type': 'transport',
        'time': _formatTimeAgo(t['request_date']),
      }).toList();
      
      List<Map<String, dynamic>> allActivities = [];
      allActivities.addAll(recentChildren);
      allActivities.addAll(recentTransport);
      
      allActivities.sort((a, b) => b['time'].compareTo(a['time']));
      
      return allActivities.take(10).toList();
    } catch (e) {
      print('Error loading activities: $e');
      return [];
    }
  }
  
  // ==================== REPORTS ====================
  
  Future<Map<String, dynamic>> generateChildReport(Map<String, dynamic> filters) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/children/'),
      headers: await _getHeaders(),
      body: json.encode(filters),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate report');
    }
  }
  
  Future<Map<String, dynamic>> generateMedicalReport(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/medical/$childId/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate medical report');
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return 'Recently';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}