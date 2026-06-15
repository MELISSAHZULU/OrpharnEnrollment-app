import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  int _totalChildren = 0;
  int _totalOrphanages = 0;
  int _totalStaff = 0;
  int _emergencyCases = 0;
  int _placedChildren = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      final orphanages = await _apiService.getOrphanages();
      final orphanagesList = orphanages is List ? orphanages : [];
      final staff = await _apiService.getStaff();
      final staffList = staff is List ? staff : [];
      
      setState(() {
        _totalChildren = childrenList.length;
        _totalOrphanages = orphanagesList.length;
        _totalStaff = staffList.length;
        _emergencyCases = childrenList.where((c) => c['status'] == 'EMERGENCY').length;
        _placedChildren = childrenList.where((c) => c['status'] == 'PLACED').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('National Statistics'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Key Metrics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildStatRow('Total Orphanages', '$_totalOrphanages'),
                          _buildStatRow('Total Children', '$_totalChildren'),
                          _buildStatRow('Total Staff', '$_totalStaff'),
                          _buildStatRow('Emergency Cases', '$_emergencyCases'),
                          _buildStatRow('Placed Children', '$_placedChildren'),
                          _buildStatRow('Awaiting Placement', '${_totalChildren - _placedChildren}'),
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
                            'Export Reports',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: const Text('Annual Report'),
                            trailing: const Icon(Icons.download),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.bar_chart, color: Colors.blue),
                            title: const Text('Compliance Report'),
                            trailing: const Icon(Icons.download),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }
}