import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Edit form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // Try to get user from API
      final userData = await _apiService.getCurrentUser();
      setState(() {
        _user = User.fromJson(userData);
        _isLoading = false;
      });
      _initControllers();
    } catch (e) {
      // Fallback to demo user if API not ready
      setState(() {
        _user = User(
          id: 1,
          username: 'admin',
          email: 'admin@orphanage.mw',
          firstName: 'John',
          lastName: 'Doe',
          role: 'admin',
          phoneNumber: '+265 888 123 456',
          orphanageName: 'Central Orphanage',
          dateJoined: DateTime.now().subtract(Duration(days: 30)),
        );
        _isLoading = false;
      });
      _initControllers();
    }
  }
  
  void _initControllers() {
    _firstNameController = TextEditingController(text: _user?.firstName ?? '');
    _lastNameController = TextEditingController(text: _user?.lastName ?? '');
    _emailController = TextEditingController(text: _user?.email ?? '');
    _phoneController = TextEditingController(text: _user?.phoneNumber ?? '');
  }
  
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final updatedData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
      };
      
      try {
        await _apiService.updateUserProfile(updatedData);
        setState(() {
          _user = User(
            id: _user!.id,
            username: _user!.username,
            email: _emailController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            role: _user!.role,
            phoneNumber: _phoneController.text,
            orphanageName: _user!.orphanageName,
            dateJoined: _user!.dateJoined,
          );
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile'),
        backgroundColor: Colors.blue,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _updateProfile,
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initControllers();
                });
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditForm()
              : _buildProfileView(),
    );
  }
  
  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      _user?.fullName.isNotEmpty == true 
                          ? '${_user!.firstName[0]}${_user!.lastName[0]}'
                          : 'U',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _user?.fullName ?? 'User Name',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_user?.getRoleIcon(), size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        _user?.getRoleDisplay() ?? 'Staff Member',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          
          // Profile Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        _buildInfoRow(Icons.person, 'Username', _user?.username ?? 'N/A'),
                        _buildInfoRow(Icons.email, 'Email', _user?.email ?? 'N/A'),
                        _buildInfoRow(Icons.phone, 'Phone', _user?.phoneNumber ?? 'Not provided'),
                        if (_user?.orphanageName != null)
                          _buildInfoRow(Icons.business, 'Orphanage', _user!.orphanageName!),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        _buildInfoRow(Icons.calendar_today, 'Member Since', 
                            _user?.dateJoined != null 
                                ? '${_user!.dateJoined!.day}/${_user!.dateJoined!.month}/${_user!.dateJoined!.year}'
                                : 'N/A'),
                        _buildInfoRow(Icons.security, 'Account Type', 'Active'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permissions',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        _buildPermissionTile('Enroll Children', _user?.role == 'admin' || _user?.role == 'orphanage_staff'),
                        _buildPermissionTile('Manage Beds', _user?.role == 'admin' || _user?.role == 'orphanage_staff'),
                        _buildPermissionTile('Request Transport', _user?.role != 'viewer'),
                        _buildPermissionTile('View Reports', true),
                        _buildPermissionTile('Manage Users', _user?.role == 'admin'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Change Password Button
                OutlinedButton.icon(
                  onPressed: () => _showChangePasswordDialog(),
                  icon: Icon(Icons.lock),
                  label: Text('Change Password'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionTile(String permission, bool hasPermission) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            color: hasPermission ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(permission)),
          if (!hasPermission)
            Text('Not allowed', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v!.isEmpty || !v!.contains('@') ? 'Valid email required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                );
                return;
              }
              
              try {
                await _apiService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Change Password'),
          ),
        ],
      ),
    );
  }
}