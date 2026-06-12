import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/enroll_child_screen.dart';

class HealthcareDashboard extends StatefulWidget {
  @override
  _HealthcareDashboardState createState() => _HealthcareDashboardState();
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
      
      // Safe way - just assign the list directly, no sublist
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Enrollment'),
        content: Text('This feature allows you to enroll a child in emergency situation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnrollChildScreen()),
              ).then((_) => _loadDashboardData());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Portal'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Healthcare Worker',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Enroll orphans directly from health facilities',
                              style: TextStyle(color: Colors.teal.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Emergency Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showEmergencyEnrollmentDialog,
                  icon: Icon(Icons.emergency),
                  label: Text('EMERGENCY ENROLLMENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Stats
              if (!_isLoading)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Emergency', '$_emergencyCases', Colors.red),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Medical Review', '$_pendingMedicalReviews', Colors.orange),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Today', '$_todayEnrollments', Colors.green),
                    ),
                  ],
                ),
              
              SizedBox(height: 24),
              
              // Recent Enrollments
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Enrollments',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator())
                      else if (_recentEnrollments.isEmpty)
                        Center(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('No enrollments yet'),
                        )
                      else
                        Column(
                          children: _recentEnrollments.take(5).map((child) {
                            final name = '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}'.trim();
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Icon(Icons.child_care, color: Colors.teal),
                              ),
                              title: Text(name.isEmpty ? 'Unnamed' : name),
                              subtitle: Text('Age: ${child['age'] ?? '?'} | ${child['village'] ?? 'Unknown'}'),
                              trailing: Chip(
                                label: Text(child['status'] ?? 'PENDING'),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnrollChildScreen()),
          ).then((_) => _loadDashboardData());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}