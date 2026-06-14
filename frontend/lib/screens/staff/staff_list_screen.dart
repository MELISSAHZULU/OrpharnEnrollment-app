import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _staff = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  
  final List<Map<String, String>> roleOptions = [
    {'value': 'manager', 'label': 'Orphanage Manager'},
    {'value': 'social_worker', 'label': 'Social Worker'},
    {'value': 'nurse', 'label': 'Nurse'},
    {'value': 'caregiver', 'label': 'Caregiver'},
    {'value': 'driver', 'label': 'Driver'},
    {'value': 'security', 'label': 'Security'},
    {'value': 'kitchen', 'label': 'Kitchen Staff'},
    {'value': 'teacher', 'label': 'Teacher'},
  ];
  
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
      final staffData = await _apiService.getStaff();
      print('Staff loaded: ${staffData.length} members');
      setState(() {
        _staff = staffData is List ? staffData : [];
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      print('Error loading staff: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
        _staff = [];
      });
    }
  }
  
  Future<void> _refreshStaff() async {
    setState(() => _isRefreshing = true);
    await _loadStaff();
  }
  
  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final departmentController = TextEditingController();
    String selectedRole = 'caregiver';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Staff Member'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: roleOptions.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter staff name'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                try {
                  await _apiService.addStaff({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'department': departmentController.text,
                    'phone': phoneController.text,
                  });
                  Navigator.pop(context);
                  _loadStaff();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Staff added: ${nameController.text}'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Staff'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditDialog(dynamic staff) {
    final nameController = TextEditingController(text: staff['name'] ?? '');
    final emailController = TextEditingController(text: staff['email'] ?? '');
    final phoneController = TextEditingController(text: staff['phone'] ?? '');
    String selectedRole = staff['role'] ?? 'caregiver';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${staff['name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: roleOptions.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiService.updateStaff(staff['id'], {
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'phone': phoneController.text,
                  });
                  Navigator.pop(context);
                  _loadStaff();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Staff updated!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDelete(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Staff?'),
        content: Text('Are you sure you want to deactivate ${staff['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.toggleStaffStatus(staff['id']);
                Navigator.pop(context);
                _loadStaff();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Staff deactivated'), backgroundColor: Colors.orange),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
  
  void _confirmActivate(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Staff?'),
        content: Text('Are you sure you want to activate ${staff['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.toggleStaffStatus(staff['id']);
                Navigator.pop(context);
                _loadStaff();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Staff activated'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStaffDialog,
            tooltip: 'Add Staff',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStaff,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadStaff,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _staff.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No staff members added yet'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddStaffDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Staff Member'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _staff.length,
                        itemBuilder: (context, index) {
                          final staff = _staff[index];
                          final isActive = staff['is_active'] ?? true;
                          final name = staff['name'] ?? 'Unknown';
                          final role = staff['role'] ?? 'Staff';
                          final email = staff['email'] ?? 'No email';
                          final phone = staff['phone'] ?? '';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade300,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? Colors.green.shade800 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.work, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              role,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Colors.green.shade100
                                                    : Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isActive ? 'Active' : 'Inactive',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isActive
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              email,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        if (phone.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 12, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                phone,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditDialog(staff);
                                      } else if (value == 'deactivate' && isActive) {
                                        _confirmDelete(staff);
                                      } else if (value == 'activate' && !isActive) {
                                        _confirmActivate(staff);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      if (isActive)
                                        const PopupMenuItem(
                                          value: 'deactivate',
                                          child: Row(
                                            children: [
                                              Icon(Icons.block, size: 18, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Deactivate'),
                                            ],
                                          ),
                                        )
                                      else
                                        const PopupMenuItem(
                                          value: 'activate',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, size: 18, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('Activate'),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}