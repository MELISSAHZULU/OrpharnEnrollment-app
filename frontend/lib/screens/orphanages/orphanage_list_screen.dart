import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OrphanageListScreen extends StatefulWidget {
  @override
  _OrphanageListScreenState createState() => _OrphanageListScreenState();
}

floatingActionButton: RolePermissions.canAddOrphanage(authProvider.userRole)
    ? FloatingActionButton(
        onPressed: _showAddOrphanageDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      )
    : null,
    
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
      setState(() {
        _orphanages = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _orphanages = [];
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
                          Text('No orphanages registered'),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddOrphanageDialog,
                            icon: Icon(Icons.add),
                            label: Text('Register Orphanage'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _orphanages.length,
                      itemBuilder: (context, index) {
                        final o = _orphanages[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                o['name']?.substring(0, 1) ?? 'O',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(o['name'] ?? 'Unknown'),
                            subtitle: Text('${o['city'] ?? ''}, ${o['district'] ?? ''}'),
                            trailing: Chip(
                              label: Text(o['is_active'] == true ? 'Active' : 'Inactive'),
                              backgroundColor: o['is_active'] == true ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
  
  void _showAddOrphanageDialog() {
    final nameController = TextEditingController();
    final regController = TextEditingController();
    final cityController = TextEditingController();
    final districtController = TextEditingController();
    final phoneController = TextEditingController();
    final directorController = TextEditingController();
    final capacityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register Orphanage'),
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
                  Expanded(child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  )),
                  SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: districtController,
                    decoration: InputDecoration(labelText: 'District'),
                  )),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
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
                  'phone': phoneController.text,
                  'director_name': directorController.text,
                  'capacity': int.parse(capacityController.text),
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