import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GovernmentDashboard extends StatefulWidget {
  const GovernmentDashboard({super.key});

  @override
  State<GovernmentDashboard> createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  int _totalOrphanages = 0;
  int _totalChildren = 0;
  int _totalStaff = 0;
  int _compliantOrphanages = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final staff = await _apiService.getStaff();
      final orphanages = await _apiService.getOrphanages();
      
      final childrenCount = children is List ? children.length : 0;
      final staffCount = staff is List ? staff.length : 0;
      final orphanagesList = orphanages is List ? orphanages : [];
      final orphanagesCount = orphanagesList.length;
      final compliantCount = orphanagesList.where((o) => o['is_active'] == true).length;
      
      setState(() {
        _totalChildren = childrenCount;
        _totalStaff = staffCount;
        _totalOrphanages = orphanagesCount;
        _compliantOrphanages = compliantCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Government Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'National Statistics',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildStatCard('Orphanages', '$_totalOrphanages', Icons.business, Colors.indigo),
                        _buildStatCard('Children', '$_totalChildren', Icons.people, Colors.green),
                        _buildStatCard('Staff', '$_totalStaff', Icons.people_outline, Colors.orange),
                        _buildStatCard('Compliant', '$_compliantOrphanages', Icons.check_circle, Colors.teal),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Compliance Card
                    Card(
                      color: Colors.indigo.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Compliance Overview',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Compliance Rate'),
                                Text('${_totalOrphanages > 0 ? ((_compliantOrphanages / _totalOrphanages) * 100).toStringAsFixed(1) : 0}%',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _totalOrphanages > 0 ? _compliantOrphanages / _totalOrphanages : 0,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}