import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../staff/staff_list_screen.dart';
//import '../orphanages/orphanage_list_screen.dart';
import '../children/children_list_screen.dart';
import '../resources/bed_screen.dart';
import '../children/enroll_child_screen.dart';
import '../transport/transport_request_screen.dart';

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
  int _activeStaff = 0;
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
    // Load all data in parallel
    final results = await Future.wait([
      _apiService.getChildren(),
      _apiService.getBedAvailability(),
      _apiService.getStaff(),
      _apiService.getOrphanages(),
      _apiService.getRecentActivities(),
    ]);
    
    final children = results[0] as List;
    final bedsResponse = results[1] as Map<String, dynamic>;
    final staff = results[2] as List;
    final orphanages = results[3] as List;
    final activities = results[4] as List<Map<String, dynamic>>;
    
    setState(() {
      _totalChildren = children.length;
      _availableBeds = bedsResponse['available_beds'] ?? 0;
      _totalStaff = staff.length;
      _activeStaff = staff.where((s) => s['is_active'] == true).length;
      _activeOrphanages = orphanages.where((o) => o['is_active'] == true).length;
      _recentActivities = activities;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    print('Error loading dashboard: $e');
    
    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading dashboard: $e'), backgroundColor: Colors.red),
    );
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
            // Welcome Section
            Text(
              'Welcome back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Here\'s your overview for today',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            
            // Stats Cards
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
                  _buildStatsCard(
                    'Total Children',
                    '$_totalChildren',
                    Icons.people,
                    Colors.blue,
                    'Enrolled',
                    onTap: () => _navigateToChildren(context),
                  ),
                  _buildStatsCard(
                    'Available Beds',
                    '$_availableBeds',
                    Icons.bed,
                    Colors.green,
                    '${_availableBeds > 5 ? "Good" : "Low"} capacity',
                    onTap: () => _navigateToBeds(context),
                  ),
                  _buildStatsCard(
                    'Staff Members',
                    '$_totalStaff',
                    Icons.people_outline,
                    Colors.orange,
                    '$_activeStaff active',
                    onTap: () => _navigateToStaff(context),
                  ),
                  _buildStatsCard(
                    'Orphanages',
                    '$_activeOrphanages',
                    Icons.business,
                    Colors.purple,
                    'Active facilities',
                    onTap: () => _navigateToOrphanages(context),
                  ),
                ],
              ),
            
            SizedBox(height: 24),
            
            // Quick Actions Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickAction(
                          'Enroll Child',
                          Icons.person_add,
                          Colors.green,
                          () => _navigateToEnroll(context),
                        ),
                        _buildQuickAction(
                          'Add Staff',
                          Icons.person_add_alt,
                          Colors.blue,
                          () => _navigateToStaff(context),
                        ),
                        _buildQuickAction(
                          'Register Orphanage',
                          Icons.business,
                          Colors.purple,
                          () => _navigateToOrphanages(context),
                        ),
                        _buildQuickAction(
                          'Request Transport',
                          Icons.directions_car,
                          Colors.orange,
                          () => _navigateToTransport(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
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
                        Spacer(),
                        TextButton(
                          onPressed: () => _viewAllActivities(context),
                          child: Text('View All'),
                        ),
                      ],
                    ),
                    Divider(),
                    if (_recentActivities.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No recent activities', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ..._recentActivities.take(3).map((activity) => _buildActivityItem(activity)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(String title, String value, IconData icon, Color color, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  Widget _buildActivityItem(Map<String, dynamic> activity) {
  IconData icon;
  Color color;
  
  switch(activity['type']) {
    case 'enrollment':
      icon = Icons.person_add;
      color = Colors.green;
      break;
    case 'transport':
      icon = Icons.directions_car;
      color = Colors.orange;
      break;
    case 'staff':
      icon = Icons.person;
      color = Colors.blue;
      break;
    case 'orphanage':
      icon = Icons.business;
      color = Colors.purple;
      break;
    default:
      icon = Icons.notifications;  // Changed from Icons.notification
      color = Colors.grey;
  }
  
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(activity['title'], style: TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text(activity['description']),
    trailing: Text(activity['time'], style: TextStyle(fontSize: 12, color: Colors.grey)),
  );
}
  
  void _navigateToChildren(BuildContext context) {
    Navigator.pushNamed(context, '/children');
  }
  
  void _navigateToBeds(BuildContext context) {
    Navigator.pushNamed(context, '/beds');
  }
  
  void _navigateToStaff(BuildContext context) {
    Navigator.pushNamed(context, '/staff');
  }
  
  void _navigateToOrphanages(BuildContext context) {
    Navigator.pushNamed(context, '/orphanages');
  }
  
  void _navigateToEnroll(BuildContext context) {
    Navigator.pushNamed(context, '/enroll');
  }
  
  void _navigateToTransport(BuildContext context) {
    Navigator.pushNamed(context, '/transport');
  }
  
  void _viewAllActivities(BuildContext context) {
    Navigator.pushNamed(context, '/activities');
  }
}