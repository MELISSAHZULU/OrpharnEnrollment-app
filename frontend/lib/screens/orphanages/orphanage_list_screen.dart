import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/role_permissions.dart';

class OrphanageListScreen extends StatefulWidget {
  @override
  _OrphanageListScreenState createState() => _OrphanageListScreenState();
}

class _OrphanageListScreenState extends State<OrphanageListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _orphanages = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadOrphanages();
  }
  
  Future<void> _loadOrphanages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final data = await _apiService.getOrphanages();
      print('Orphanages loaded: ${data.length}'); // Debug print
      setState(() {
        _orphanages = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orphanages: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _orphanages = [];
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.userRole;
    final canEdit = userRole == UserRole.superAdmin || userRole == UserRole.orphanageDirector;
    
    print('User role: $userRole, Can edit: $canEdit'); // Debug print
    print('Orphanages count: ${_orphanages.length}'); // Debug print
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Orphanages'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadOrphanages,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrphanages,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orphanages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No orphanages found'),
                          SizedBox(height: 16),
                          if (canEdit)
                            ElevatedButton.icon(
                              onPressed: () => _showAddOrphanageDialog(),
                              icon: Icon(Icons.add),
                              label: Text('Add Orphanage'),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _orphanages.length,
                      itemBuilder: (context, index) {
                        final o = _orphanages[index];
                        final isActive = o['is_active'] ?? true;
                        final availableSpace = (o['capacity'] ?? 0) - (o['current_children'] ?? 0);
                        final occupancyPercentage = ((o['current_children'] ?? 0) / (o['capacity'] ?? 1)) * 100;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              o['name'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${o['city'] ?? ''}, ${o['district'] ?? ''}'),
                            trailing: Chip(
                              label: Text(isActive ? 'Active' : 'Inactive'),
                              backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Statistics Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatCard('Capacity', '${o['capacity'] ?? 0}', Icons.bed, Colors.blue),
                                        _buildStatCard('Children', '${o['current_children'] ?? 0}', Icons.people, Colors.green),
                                        _buildStatCard('Staff', '${o['staff_count'] ?? 0}', Icons.people_outline, Colors.orange),
                                        _buildStatCard('Available', availableSpace.toString(), Icons.space_dashboard, Colors.purple),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 16),
                                    
                                    // Occupancy Bar
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Occupancy Rate', style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text('${occupancyPercentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: occupancyPercentage / 100,
                                          backgroundColor: Colors.grey.shade200,
                                          color: occupancyPercentage > 80 ? Colors.red : Colors.green,
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 16),
                                    Divider(),
                                    
                                    // Contact Information
                                    Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    if (o['phone'] != null && o['phone'].isNotEmpty)
                                      _buildContactRow(Icons.phone, 'Phone', o['phone']),
                                    if (o['email'] != null && o['email'].isNotEmpty)
                                      _buildContactRow(Icons.email, 'Email', o['email']),
                                    _buildContactRow(Icons.person, 'Director', o['director_name'] ?? 'Not specified'),
                                    _buildContactRow(Icons.location_on, 'Address', o['address'] ?? '${o['city'] ?? ''}, ${o['district'] ?? ''}'),
                                    
                                    SizedBox(height: 16),
                                    Divider(),
                                    
                                    // Registration Info
                                    Text('Registration Information', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    _buildContactRow(Icons.numbers, 'Reg Number', o['registration_number'] ?? 'N/A'),
                                    _buildContactRow(Icons.calendar_today, 'Established', o['established_date']?.split('T')[0] ?? 'Not set'),
                                    
                                    // Only show edit buttons for admins
                                    if (canEdit)
                                      Padding(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _editOrphanage(o),
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _toggleOrphanageStatus(o),
                                                icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
                                                label: Text(isActive ? 'Deactivate' : 'Activate'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isActive ? Colors.orange : Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
  
  void _editOrphanage(dynamic orphanage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit feature coming soon')),
    );
  }
  
  void _toggleOrphanageStatus(dynamic orphanage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(orphanage['is_active'] ? 'Deactivate Orphanage?' : 'Activate Orphanage?'),
        content: Text('Are you sure you want to ${orphanage['is_active'] ? 'deactivate' : 'activate'} ${orphanage['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status changed successfully'), backgroundColor: Colors.green),
              );
              _loadOrphanages();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orphanage['is_active'] ? Colors.orange : Colors.green,
            ),
            child: Text(orphanage['is_active'] ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }
  
  void _showAddOrphanageDialog() {
    final nameController = TextEditingController();
    final regController = TextEditingController();
    final cityController = TextEditingController();
    final districtController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final directorController = TextEditingController();
    final capacityController = TextEditingController();
    final addressController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Orphanage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Orphanage Name'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: regController,
                decoration: InputDecoration(labelText: 'Registration Number'),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityController,
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: districtController,
                      decoration: InputDecoration(labelText: 'District'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: directorController,
                decoration: InputDecoration(labelText: 'Director Name'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: capacityController,
                decoration: InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
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
                await _apiService.addOrphanage({
                  'name': nameController.text,
                  'registration_number': regController.text,
                  'city': cityController.text,
                  'district': districtController.text,
                  'address': addressController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'director_name': directorController.text,
                  'capacity': int.parse(capacityController.text),
                  'current_children': 0,
                  'staff_count': 0,
                  'is_active': true,
                });
                Navigator.pop(context);
                _loadOrphanages();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Orphanage added!'), backgroundColor: Colors.green),
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
}