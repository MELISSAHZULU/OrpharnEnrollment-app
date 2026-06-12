import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/role_permissions.dart';

class BedScreen extends StatefulWidget {
  @override
  _BedScreenState createState() => _BedScreenState();
}

class _BedScreenState extends State<BedScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _beds = [];
  bool _isLoading = true;
  bool _isAddingBed = false;
  
  final _formKey = GlobalKey<FormState>();
  final _orphanageNameController = TextEditingController();
  final _totalBedsController = TextEditingController();
  
  // Room/Dorm specific data for occupancy bars
  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Boys Dorm', 'occupied': 24, 'total': 30, 'color': Colors.blue},
    {'name': 'Girls Dorm', 'occupied': 20, 'total': 30, 'color': Colors.pink},
    {'name': 'Infants Room', 'occupied': 8, 'total': 20, 'color': Colors.green},
    {'name': 'Special Needs', 'occupied': 3, 'total': 20, 'color': Colors.orange},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadBeds();
  }
  
  Future<void> _loadBeds() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getBedAvailability();
      setState(() {
        _beds = response['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _addBed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isAddingBed = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        
        await http.post(
          Uri.parse('http://localhost:8000/api/resources/beds/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'orphanage_name': _orphanageNameController.text,
            'total_beds': int.parse(_totalBedsController.text),
            'occupied_beds': 0,
          }),
        );
        
        Navigator.pop(context);
        _loadBeds();
        _orphanageNameController.clear();
        _totalBedsController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bed space added!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isAddingBed = false);
      }
    }
  }
  
  void _showAddBedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Bed Space'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _orphanageNameController,
                decoration: InputDecoration(labelText: 'Room/Dorm Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _totalBedsController,
                decoration: InputDecoration(labelText: 'Total Beds'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: _isAddingBed ? null : _addBed, child: Text('Add')),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.userRole;
    
    // Check if user can manage beds (add/edit)
    final canManageBeds = userRole == UserRole.superAdmin || 
                          userRole == UserRole.orphanageDirector ||
                          userRole == UserRole.orphanageStaff;
    
    // Check if user can view beds
    final canViewBeds = userRole != UserRole.villageHead && 
                        userRole != UserRole.donor;
    
    if (!canViewBeds) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Bed Management'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('You do not have permission to view bed information.'),
            ],
          ),
        ),
      );
    }
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(canManageBeds ? 'Bed Management' : 'Bed Availability'),
          backgroundColor: Colors.blue,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bed), text: 'Overview'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Occupancy'),
            ],
          ),
          // Only show add button for users who can manage beds
          actions: canManageBeds
              ? [
                  IconButton(icon: Icon(Icons.add), onPressed: _showAddBedDialog),
                  IconButton(icon: Icon(Icons.refresh), onPressed: _loadBeds),
                ]
              : [
                  IconButton(icon: Icon(Icons.refresh), onPressed: _loadBeds),
                ],
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _beds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No bed spaces added yet'),
                            if (canManageBeds) ...[
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _showAddBedDialog,
                                icon: Icon(Icons.add),
                                label: Text('Add Bed Space'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _beds.length,
                        itemBuilder: (context, index) {
                          final bed = _beds[index];
                          final available = bed['available_beds'] ?? (bed['total_beds'] - bed['occupied_beds']);
                          final occupancyPercentage = (bed['occupied_beds'] / bed['total_beds']) * 100;
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.business, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          bed['orphanage_name'],
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: available > 0 ? Colors.green.shade100 : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          available > 0 ? 'Available' : 'Full',
                                          style: TextStyle(
                                            color: available > 0 ? Colors.green.shade800 : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildBedStat('Total Beds', bed['total_beds'].toString(), Colors.blue),
                                      _buildBedStat('Occupied', bed['occupied_beds'].toString(), Colors.orange),
                                      _buildBedStat('Available', available.toString(), Colors.green),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: occupancyPercentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: occupancyPercentage > 80 ? Colors.red : Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${occupancyPercentage.toStringAsFixed(1)}% occupied',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  // Show note for healthcare workers that they can't edit
                                  if (!canManageBeds && userRole == UserRole.healthcareWorker)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'ℹ️ View only. Contact orphanage staff for bed assignments.',
                                        style: TextStyle(fontSize: 11, color: Colors.blue),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            
            // Occupancy Tab with Room-wise breakdown
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Occupancy Breakdown',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Detailed occupancy by room/dorm',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Divider(),
                          ..._rooms.map((room) => _buildRoomOccupancyTile(room)).toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Capacity',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          _buildOverallCapacity(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Only show FAB for users who can manage beds
        floatingActionButton: canManageBeds
            ? FloatingActionButton(
                onPressed: _showAddBedDialog,
                child: Icon(Icons.add),
                backgroundColor: Colors.green,
              )
            : null,
      ),
    );
  }
  
  Widget _buildBedStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildRoomOccupancyTile(Map<String, dynamic> room) {
    final percentage = (room['occupied'] / room['total']) * 100;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                room['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${room['occupied']}/${room['total']} beds',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: room['color'],
          ),
          SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}% occupied',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverallCapacity() {
    int totalBeds = 0;
    int occupiedBeds = 0;
    
    for (var room in _rooms) {
      totalBeds += room['total'] as int;
      occupiedBeds += room['occupied'] as int;
    }
    
    final percentage = (occupiedBeds / totalBeds) * 100;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBedStat('Total Capacity', totalBeds.toString(), Colors.blue),
            _buildBedStat('Occupied', occupiedBeds.toString(), Colors.orange),
            _buildBedStat('Available', (totalBeds - occupiedBeds).toString(), Colors.green),
          ],
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          color: percentage > 80 ? Colors.red : Colors.green,
        ),
        SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}% overall occupancy',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}