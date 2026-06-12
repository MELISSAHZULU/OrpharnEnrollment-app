import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orphanageController = TextEditingController();
  
  String _selectedRole = 'social_worker';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // All available roles for registration
  final List<Map<String, dynamic>> _roles = [
    {'value': 'orphanage_director', 'label': 'Orphanage Director', 'icon': Icons.business, 'color': Colors.blue, 'showOrphanageField': true},
    {'value': 'orphanage_staff', 'label': 'Orphanage Staff', 'icon': Icons.people_outline, 'color': Colors.lightBlue, 'showOrphanageField': true},
    {'value': 'social_worker', 'label': 'Social Worker', 'icon': Icons.people, 'color': Colors.green, 'showOrphanageField': false},
    {'value': 'healthcare_worker', 'label': 'Healthcare Worker', 'icon': Icons.medical_services, 'color': Colors.teal, 'showOrphanageField': false},
    {'value': 'village_head', 'label': 'Village Head', 'icon': Icons.location_city, 'color': Colors.orange, 'showOrphanageField': false},
    {'value': 'donor', 'label': 'Donor / Sponsor', 'icon': Icons.favorite, 'color': Colors.pink, 'showOrphanageField': false},
    {'value': 'government_official', 'label': 'Government Official', 'icon': Icons.account_balance, 'color': Colors.indigo, 'showOrphanageField': false},
    {'value': 'viewer', 'label': 'Viewer (Read Only)', 'icon': Icons.visibility, 'color': Colors.grey, 'showOrphanageField': false},
  ];
  
  @override
  Widget build(BuildContext context) {
    // Check if selected role should show orphanage field
    final selectedRoleData = _roles.firstWhere((r) => r['value'] == _selectedRole);
    final showOrphanageField = selectedRoleData['showOrphanageField'] as bool;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, size: 60, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Join the Orphan Enrollment System',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      
                      // Personal Information Section
                      _buildSectionTitle('Personal Information', Icons.person),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Account Information Section
                      _buildSectionTitle('Account Information', Icons.account_circle),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v!.isEmpty || !v!.contains('@') 
                            ? 'Valid email required' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                      ),
                      SizedBox(height: 16),
                      
                      // Role Selection Section
                      _buildSectionTitle('Select Your Role', Icons.work),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: _roles.map((role) => RadioListTile<String>(
                            title: Text(role['label']),
                            subtitle: _getRoleDescription(role['value']),
                            value: role['value'],
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                                // Clear orphanage field when switching to non-orphanage role
                                if (!showOrphanageField) {
                                  _orphanageController.clear();
                                }
                              });
                            },
                            secondary: Icon(role['icon'], color: role['color']),
                          )).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Orphanage field - ONLY for orphanage staff and director
                      if (showOrphanageField)
                        Column(
                          children: [
                            _buildSectionTitle('Orphanage Information', Icons.business),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _orphanageController,
                              decoration: InputDecoration(
                                labelText: 'Orphanage Name',
                                prefixIcon: Icon(Icons.business),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: showOrphanageField ? (v) => v!.isEmpty ? 'Orphanage name is required' : null : null,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Enter the name of the orphanage you work for',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      
                      // Contact Information Section (only show if not orphanage field? Always show)
                      SizedBox(height: 16),
                      _buildSectionTitle('Contact Information', Icons.contact_phone),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text('Register', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text('Login Here'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
        ),
      ],
    );
  }
  
  Widget? _getRoleDescription(String role) {
    switch(role) {
      case 'orphanage_director':
        return Text('Full access to manage orphanage, staff, children, and approve transport');
      case 'orphanage_staff':
        return Text('Can manage children, beds, and request transport');
      case 'social_worker':
        return Text('Manage cases, enroll children, and track reunification');
      case 'healthcare_worker':
        return Text('Medical records, emergency enrollment, vaccinations');
      case 'village_head':
        return Text('Report orphans in your village and track status');
      case 'donor':
        return Text('Sponsor children, view updates, and donate');
      case 'government_official':
        return Text('View statistics, compliance reports, and orphanages');
      case 'viewer':
        return Text('Read-only access to view information');
      default:
        return null;
    }
  }
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final selectedRoleData = _roles.firstWhere((r) => r['value'] == _selectedRole);
      final showOrphanageField = selectedRoleData['showOrphanageField'] as bool;
      
      final userData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'role': _selectedRole,
        'phone_number': _phoneController.text,
      };
      
      // Only add orphanage_name if role requires it and field is not empty
      if (showOrphanageField && _orphanageController.text.isNotEmpty) {
        userData['orphanage_name'] = _orphanageController.text;
      }
      
      try {
        await _apiService.register(userData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful! Please login.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}