import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EnrollmentManagementScreen extends StatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  State<EnrollmentManagementScreen> createState() => _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState extends State<EnrollmentManagementScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingEnrollments = [];
  List<dynamic> _emergencyEnrollments = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }
  
  Future<void> _loadEnrollments() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      
      setState(() {
        _pendingEnrollments = childrenList.where((c) => 
          c['status'] == 'PENDING' || c['status'] == 'INITIATED'
        ).toList();
        
        _emergencyEnrollments = childrenList.where((c) => 
          c['status'] == 'EMERGENCY'
        ).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading enrollments: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateStatus(dynamic child, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateChild(child['id'], {'status': newStatus});
      await _loadEnrollments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child status updated to $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enrollment Management'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending), text: 'Pending'),
              Tab(icon: Icon(Icons.emergency), text: 'Emergency'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildEnrollmentList(_pendingEnrollments, 'Pending'),
                  _buildEnrollmentList(_emergencyEnrollments, 'Emergency'),
                ],
              ),
      ),
    );
  }
  
  Widget _buildEnrollmentList(List<dynamic> enrollments, String type) {
    if (enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No $type enrollments'),  // This is fine - not a const
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final child = enrollments[index];
        final firstName = child['first_name'] ?? '';
        final lastName = child['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final age = child['age'] ?? '?';
        final village = child['village'] ?? 'Unknown';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: type == 'Emergency' ? Colors.red : Colors.orange,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'Unnamed Child' : fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('Age: $age | Village: $village'),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(child['status'] ?? 'UNKNOWN'),
                            backgroundColor: type == 'Emergency' ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateStatus(child, 'APPROVED'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(child, 'REJECTED'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}