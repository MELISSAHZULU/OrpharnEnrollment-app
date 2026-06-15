import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BedScreen extends StatefulWidget {
  const BedScreen({super.key});

  @override
  State<BedScreen> createState() => _BedScreenState();
}

class _BedScreenState extends State<BedScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _beds = [];
  bool _isLoading = true;
  bool _isAddingBed = false;
  
  final _formKey = GlobalKey<FormState>();
  final _orphanageNameController = TextEditingController();
  final _totalBedsController = TextEditingController();
  
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
        title: const Text('Add Bed Space'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _orphanageNameController,
                decoration: const InputDecoration(labelText: 'Room/Dorm Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _totalBedsController,
                decoration: const InputDecoration(labelText: 'Total Beds'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _isAddingBed ? null : _addBed, child: const Text('Add')),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bed Management'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4C1D95),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bed), text: 'Overview'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Occupancy'),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _showAddBedDialog),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBeds),
          ],
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _beds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No bed spaces added yet'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddBedDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Bed Space'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _beds.length,
                        itemBuilder: (context, index) {
                          final bed = _beds[index];
                          final available = bed['available_beds'] ?? (bed['total_beds'] - bed['occupied_beds']);
                          final occupancyPercentage = (bed['occupied_beds'] / bed['total_beds']) * 100;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.business, color: const Color(0xFF7C3AED)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          bed['orphanage_name'],
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildBedStat('Total Beds', bed['total_beds'].toString(), Colors.blue),
                                      _buildBedStat('Occupied', bed['occupied_beds'].toString(), Colors.orange),
                                      _buildBedStat('Available', available.toString(), Colors.green),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: occupancyPercentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: occupancyPercentage > 80 ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(height: 8),
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
            
            // Occupancy Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Room Occupancy Breakdown',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Detailed occupancy by room/dorm',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Divider(),
                          ..._rooms.map((room) => _buildRoomOccupancyTile(room)).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Overall Capacity',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddBedDialog,
          child: const Icon(Icons.add),
          backgroundColor: const Color(0xFF7C3AED),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                room['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${room['occupied']}/${room['total']} beds',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: room['color'],
          ),
          const SizedBox(height: 4),
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
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          color: percentage > 80 ? Colors.red : Colors.green,
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}% overall occupancy',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}