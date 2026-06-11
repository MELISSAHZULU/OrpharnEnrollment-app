import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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
      final orphanages = await _apiService.getOrphanages();
      setState(() {
        _orphanages = orphanages;
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
        title: Text('Orphanages'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddOrphanageDialog(),
            tooltip: 'Add Orphanage',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadOrphanages,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _orphanages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No orphanages registered yet'),
                          SizedBox(height: 16),
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
                        final orphanage = _orphanages[index];
                        final availableSpace = orphanage['available_space'] ?? 
                            (orphanage['capacity'] - orphanage['current_children']);
                        final occupancyRate = (orphanage['current_children'] / orphanage['capacity']) * 100;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.home, color: Colors.blue.shade800, size: 32),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            orphanage['name'],
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Reg: ${orphanage['registration_number']}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: orphanage['is_active'] ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        orphanage['is_active'] ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: orphanage['is_active'] ? Colors.green.shade800 : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Divider(),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatCard('Children', orphanage['current_children'].toString(), Icons.people, Colors.blue),
                                    _buildStatCard('Capacity', orphanage['capacity'].toString(), Icons.bed, Colors.green),
                                    _buildStatCard('Staff', orphanage['staff_count'].toString(), Icons.people_outline, Colors.orange),
                                    _buildStatCard('Available', availableSpace.toString(), Icons.space_dashboard, Colors.purple),
                                  ],
                                ),
                                SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: occupancyRate / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  color: occupancyRate > 80 ? Colors.red : Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${occupancyRate.toStringAsFixed(1)}% occupied',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      '${orphanage['city']}, ${orphanage['district']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.phone, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(orphanage['phone'], style: TextStyle(fontSize: 12, color: Colors.grey)),
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
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  
  void _showAddOrphanageDialog() {
    final nameController = TextEditingController();
    final regNumberController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final districtController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final directorController = TextEditingController();
    final capacityController = TextEditingController();
    String selectedType = 'public';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register New Orphanage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Orphanage Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: regNumberController,
                decoration: InputDecoration(labelText: 'Registration Number'),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: 'Orphanage Type'),
                items: [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                  DropdownMenuItem(value: 'faith_based', child: Text('Faith Based')),
                  DropdownMenuItem(value: 'ngo', child: Text('NGO')),
                ],
                onChanged: (value) => selectedType = value!,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  )),
                  SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: districtController,
                    decoration: InputDecoration(labelText: 'District'),
                  )),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  )),
                  SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  )),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: directorController,
                decoration: InputDecoration(labelText: 'Director Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration: InputDecoration(labelText: 'Capacity (Number of Children)'),
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
                  'registration_number': regNumberController.text,
                  'type': selectedType,
                  'address': addressController.text,
                  'city': cityController.text,
                  'district': districtController.text,
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
                  SnackBar(content: Text('Orphanage registered!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}