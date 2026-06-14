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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/children/'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data['results'] != null) {
          return data['results'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading children: $e');
      return [];
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
     print('Enrollment error: ${response.body}');
     throw Exception('Failed to enroll child');
   }
  } 
  
  Future<Map<String, dynamic>> updateChild(int childId, Map<String, dynamic> childData) async {
   final response = await http.patch(  // Change from put to patch
     Uri.parse('$baseUrl/children/$childId/'),
     headers: await _getHeaders(),
     body: json.encode(childData),
   );
  
   print('Update child response status: ${response.statusCode}');
   print('Update child response body: ${response.body}');
  
   if (response.statusCode == 200) {
     return json.decode(response.body);
   }  else {
      throw Exception('Failed to update child: ${response.body}');
   }
 }

  
  // ==================== BED MANAGEMENT ====================
  
Future<Map<String, dynamic>> getBedAvailability() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/resources/beds/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data['results'] != null) {
        final beds = data['results'];
        int availableBeds = 0;
        for (var bed in beds) {
          availableBeds += (bed['available_beds'] ?? 0) as int;
        }
        return {
          'available_beds': availableBeds,
          'results': beds,
        };
      } else if (data is List) {
        int availableBeds = 0;
        for (var bed in data) {
          availableBeds += (bed['available_beds'] ?? 0) as int;
        }
        return {
          'available_beds': availableBeds,
          'results': data,
        };
      }
      return {'available_beds': 0, 'results': []};
    } else {
      return {'available_beds': 0, 'results': []};
    }
  } catch (e) {
    print('Error loading bed data: $e');
    return {'available_beds': 0, 'results': []};
  }
}


// Add this helper method
void _debugPrintResponse(String tag, http.Response response) {
  print('=== $tag ===');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
  print('==========');
}
//enrollment screen status

Future<Map<String, dynamic>> updateEnrollmentStatus(int childId, Map<String, dynamic> statusData) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/children/$childId/'),
    headers: await _getHeaders(),
    body: json.encode(statusData),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to update status');
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
  
  Future<List<dynamic>> getTransportRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resources/transport/'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data['results'] != null) {
          return data['results'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading transport: $e');
      return [];
    }
  }
  
  // ==================== STAFF MANAGEMENT ====================
  
  Future<List<dynamic>> getStaff() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/staff/'),
        headers: await _getHeaders(),
      );
      
      print('Staff response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data['results'] != null) {
          return data['results'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading staff: $e');
      return [];
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
  
  // ==================== ORPHANAGE MANAGEMENT ====================
  
  Future<List<dynamic>> getOrphanages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orphanages/'),
        headers: await _getHeaders(),
      );
      
      print('Orphanages response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data['results'] != null) {
          return data['results'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading orphanages: $e');
      return [];
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
  
  // ==================== NOTIFICATIONS ====================
  
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data['results'] != null) {
          return data['results'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }
  
  // ==================== DASHBOARD ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final children = await getChildren();
      final beds = await getBedAvailability();
      final staff = await getStaff();
      final orphanages = await getOrphanages();
      
      final childrenList = children is List ? children : [];
      final staffList = staff is List ? staff : [];
      final orphanagesList = orphanages is List ? orphanages : [];
      
      return {
        'total_children': childrenList.length,
        'available_beds': beds['available_beds'] ?? 0,
        'total_staff': staffList.length,
        'active_staff': staffList.where((s) => s['is_active'] == true).length,
        'active_orphanages': orphanagesList.where((o) => o['is_active'] == true).length,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'total_children': 0,
        'available_beds': 0,
        'total_staff': 0,
        'active_staff': 0,
        'active_orphanages': 0,
      };
    }
  }
  
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final children = await getChildren();
      final childrenList = children is List ? children : [];
      
      final recentChildren = childrenList.take(5).map((child) => {
        'title': 'New Child Enrolled',
        'description': '${child['first_name']} ${child['last_name']} was enrolled',
        'type': 'enrollment',
        'time': _formatTimeAgo(child['enrollment_date']),
      }).toList();
      
      return recentChildren.take(10).toList();
    } catch (e) {
      print('Error loading activities: $e');
      return [];
    }
  }
  
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