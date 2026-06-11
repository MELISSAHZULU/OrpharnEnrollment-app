import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  int _totalChildren = 0;
  int _availableBeds = 0;
  int _totalStaff = 0;
  int _activeOrphanages = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentActivities = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _apiService.getDashboardStats();
      final activities = await _apiService.getRecentActivities();
      
      setState(() {
        _totalChildren = stats['total_children'] ?? 0;
        _availableBeds = stats['available_beds'] ?? 0;
        _totalStaff = stats['total_staff'] ?? 0;
        _activeOrphanages = stats['active_orphanages'] ?? 0;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Orphan Enrollment Dashboard',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatsCard('Total Children', '$_totalChildren', Icons.people, Colors.blue),
                  _buildStatsCard('Available Beds', '$_availableBeds', Icons.bed, Colors.green),
                  _buildStatsCard('Staff Members', '$_totalStaff', Icons.people_outline, Colors.orange),
                  _buildStatsCard('Orphanages', '$_activeOrphanages', Icons.business, Colors.purple),
                ],
              ),
            
            SizedBox(height: 24),
            
            // Recent Activity
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.orange, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Recent Activity',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(),
                    if (_recentActivities.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No recent activities')),
                      )
                    else
                      ..._recentActivities.take(3).map((activity) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          child: Icon(Icons.person_add, color: Colors.green, size: 20),
                        ),
                        title: Text(activity['title']),
                        subtitle: Text(activity['description']),
                        trailing: Text(activity['time'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}