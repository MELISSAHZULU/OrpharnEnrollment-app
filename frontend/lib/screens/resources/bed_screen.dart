import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading beds: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _addBed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isAddingBed = true);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        
        final response = await http.post(
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
        
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bed added successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
          _loadBeds();
          _orphanageNameController.clear();
          _totalBedsController.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding bed: $e'), backgroundColor: Colors.red),
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
        title: Text('Add New Bed Space'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _orphanageNameController,
                decoration: InputDecoration(labelText: 'Orphanage Name'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isAddingBed ? null : _addBed,
            child: _isAddingBed ? CircularProgressIndicator() : Text('Add'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bed Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddBedDialog,
            tooltip: 'Add Bed Space',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBeds,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _beds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bed, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bed spaces added yet'),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddBedDialog,
                        icon: Icon(Icons.add),
                        label: Text('Add Bed Space'),
                      ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  
  Widget _buildBedStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}