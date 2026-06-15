import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
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
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            Text(
              'Orphan Enrollment Dashboard',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatsCard('Total Children', '$_totalChildren', Icons.people, const Color(0xFF10B981)),
                  _buildStatsCard('Available Beds', '$_availableBeds', Icons.bed, const Color(0xFF7C3AED)),
                  _buildStatsCard('Staff Members', '$_totalStaff', Icons.people_outline, const Color(0xFFF59E0B)),
                  _buildStatsCard('Orphanages', '$_activeOrphanages', Icons.business, const Color(0xFF8B5CF6)),
                ],
              ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
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
                  Row(
                    children: [
                      Icon(Icons.history, color: const Color(0xFF7C3AED), size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_recentActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('No recent activities')),
                    )
                  else
                    ..._recentActivities.take(3).map((activity) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                        child: Icon(Icons.person_add, color: const Color(0xFF7C3AED), size: 20),
                      ),
                      title: Text(activity['title'], style: const TextStyle(color: Color(0xFF1F2937))),
                      subtitle: Text(activity['description']),
                      trailing: Text(activity['time'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}