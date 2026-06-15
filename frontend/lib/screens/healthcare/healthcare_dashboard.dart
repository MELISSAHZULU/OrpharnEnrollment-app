import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/enroll_child_screen.dart';

class HealthcareDashboard extends StatefulWidget {
  const HealthcareDashboard({super.key});

  @override
  State<HealthcareDashboard> createState() => _HealthcareDashboardState();
}

class _HealthcareDashboardState extends State<HealthcareDashboard> {
  final ApiService _apiService = ApiService();
  int _emergencyCases = 0;
  int _pendingMedicalReviews = 0;
  int _todayEnrollments = 0;
  bool _isLoading = true;
  List<dynamic> _recentEnrollments = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      
      _emergencyCases = childrenList.where((c) => c['status'] == 'EMERGENCY').length;
      _pendingMedicalReviews = childrenList.where((c) => c['status'] == 'MEDICAL_CHECK').length;
      
      final today = DateTime.now().toString().substring(0, 10);
      _todayEnrollments = childrenList.where((c) => 
        c['enrollment_date']?.toString().contains(today) ?? false
      ).length;
      
      _recentEnrollments = List.from(childrenList);
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error: $e');
      setState(() {
        _recentEnrollments = [];
        _isLoading = false;
      });
    }
  }
  
  void _showEmergencyEnrollmentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnrollChildScreen()),
    ).then((_) => _loadDashboardData());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Portal'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4C1D95),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medical_services, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Healthcare Worker',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          Text(
                            'Enroll orphans directly from health facilities',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Emergency Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showEmergencyEnrollmentDialog,
                  icon: const Icon(Icons.emergency),
                  label: const Text('EMERGENCY ENROLLMENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats Row
              if (!_isLoading)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Emergency', '$_emergencyCases', Icons.emergency, Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Medical Review', '$_pendingMedicalReviews', Icons.medical_information, const Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Today', '$_todayEnrollments', Icons.today, const Color(0xFF10B981)),
                    ),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              // Recent Enrollments
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Enrollments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const Divider(),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_recentEnrollments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No enrollments yet')),
                      )
                    else
                      Column(
                        children: _recentEnrollments.take(5).map((child) {
                          final name = '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}'.trim();
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                              child: Icon(Icons.child_care, color: const Color(0xFF7C3AED)),
                            ),
                            title: Text(name.isEmpty ? 'Unnamed' : name, style: const TextStyle(color: Color(0xFF1F2937))),
                            subtitle: Text('Age: ${child['age'] ?? '?'} | ${child['village'] ?? 'Unknown'}'),
                            trailing: Chip(
                              label: Text(child['status'] ?? 'PENDING'),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEmergencyEnrollmentDialog,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF7C3AED),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}