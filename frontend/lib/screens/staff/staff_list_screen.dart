import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StaffListScreen extends StatefulWidget {
  @override
  _StaffListScreenState createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _staff = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadStaff();
  }
  
  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final staff = await _apiService.getStaff();
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Management'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddStaffDialog(),
            tooltip: 'Add Staff',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _staff.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No staff members added yet'),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddStaffDialog(),
                            icon: Icon(Icons.add),
                            label: Text('Add Staff Member'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _staff.length,
                      itemBuilder: (context, index) {
                        final staff = _staff[index];
                        final isActive = staff['is_active'] ?? true;
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade300,
                                      child: Text(
                                        staff['name']?.substring(0, 1) ?? 'S',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff['name'] ?? 'Unknown',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.work, size: 16, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(
                                                staff['role'] ?? 'Staff',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                              SizedBox(width: 12),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            staff['email'] ?? 'No email',
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: Text('Edit'),
                                          value: 'edit',
                                        ),
                                        PopupMenuItem(
                                          child: Text(isActive ? 'Deactivate' : 'Activate'),
                                          value: 'toggle',
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditStaffDialog(staff);
                                        } else if (value == 'toggle') {
                                          _toggleStaffStatus(staff);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
  
  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final departmentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Staff Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: departmentController,
                decoration: InputDecoration(labelText: 'Department'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.addStaff({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': roleController.text,
                  'department': departmentController.text,
                });
                Navigator.pop(context);
                _loadStaff();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Staff added!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showEditStaffDialog(dynamic staff) {
    // Similar to add but with existing data
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Staff'),
        content: Text('Edit functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _toggleStaffStatus(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff['is_active'] ? 'Deactivate Staff?' : 'Activate Staff?'),
        content: Text('Are you sure you want to ${staff['is_active'] ? 'deactivate' : 'activate'} ${staff['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.toggleStaffStatus(staff['id']);
                Navigator.pop(context);
                _loadStaff();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Staff status updated'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}