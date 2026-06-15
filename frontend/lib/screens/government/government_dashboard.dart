import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/child_detail_screen.dart';

class GovernmentDashboard extends StatefulWidget {
  const GovernmentDashboard({super.key});

  @override
  State<GovernmentDashboard> createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  int _selectedIndex = 0;
  
  // Statistics data
  int _totalOrphanages = 0;
  int _totalChildren = 0;
  int _totalStaff = 0;
  int _emergencyCases = 0;
  int _placedChildren = 0;
  int _awaitingPlacement = 0;
  double _averageCompliance = 0;
  
  // Lists
  List<dynamic> _orphanages = [];
  List<dynamic> _children = [];
  
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
        _orphanages = orphanagesList;
        _children = childrenList;
        
        _emergencyCases = childrenList.where((c) => c['status'] == 'EMERGENCY').length;
        _placedChildren = childrenList.where((c) => c['status'] == 'PLACED').length;
        _awaitingPlacement = childrenList.where((c) => 
          c['status'] == 'PENDING' || c['status'] == 'APPROVED'
        ).length;
        
        if (_totalOrphanages > 0) {
          final activeOrphanages = orphanagesList.where((o) => o['is_active'] == true).length;
          _averageCompliance = (activeOrphanages / _totalOrphanages) * 100;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Portal'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOverviewTab(),
                _buildOrphanagesTab(),
                _buildChildrenTab(),
                _buildAlertsTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'National Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Malawi Orphan Care System',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Stats Row 1
          Row(
            children: [
              Expanded(child: _buildStatCard('Orphanages', _totalOrphanages.toString(), Icons.business, Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Children', _totalChildren.toString(), Icons.people, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Staff', _totalStaff.toString(), Icons.people_outline, Colors.orange)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row 2
          Row(
            children: [
              Expanded(child: _buildStatCard('Emergency', _emergencyCases.toString(), Icons.emergency, Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Placed', _placedChildren.toString(), Icons.check_circle, Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Pending', _awaitingPlacement.toString(), Icons.pending, Colors.amber)),
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
                      Text('${_averageCompliance.toStringAsFixed(1)}%', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _averageCompliance / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_orphanages.where((o) => o['is_active'] == true).length} out of $_totalOrphanages orphanages are active',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // District Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Orphanages by District',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDistrictList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrphanagesTab() {
    if (_orphanages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orphanages registered'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orphanages.length,
      itemBuilder: (context, index) {
        final o = _orphanages[index];
        final name = o['name'] ?? 'Unknown';
        final city = o['city'] ?? 'Unknown';
        final district = o['district'] ?? 'Unknown';
        final isActive = o['is_active'] == true;
        final capacity = o['capacity'] ?? 0;
        final currentChildren = o['current_children'] ?? 0;
        final staffCount = o['staff_count'] ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.business,
                color: isActive ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$city, $district'),
                const SizedBox(height: 4),
                Text(
                  'Capacity: $capacity | Children: $currentChildren | Staff: $staffCount',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(isActive ? 'Active' : 'Inactive'),
              backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  Widget _buildChildrenTab() {
    if (_children.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No children enrolled'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length,
      itemBuilder: (context, index) {
        final child = _children[index];
        final firstName = child['first_name'] ?? '';
        final lastName = child['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final age = child['age'] ?? '?';
        final village = child['village'] ?? 'Unknown';
        final status = child['status'] ?? 'PENDING';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status),
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(fullName.isEmpty ? 'Unnamed Child' : fullName),
            subtitle: Text('Age: $age | Village: $village | Status: $status'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildDetailScreen(
                    childId: child['id'],
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildAlertsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No notifications'),
          SizedBox(height: 8),
          Text('Check back later for updates', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch(status) {
      case 'EMERGENCY': return Colors.red;
      case 'PLACED': return Colors.green;
      case 'APPROVED': return Colors.teal;
      case 'PENDING': return Colors.orange;
      case 'ENROLLED': return Colors.blue;
      case 'REJECTED': return Colors.grey;
      default: return Colors.grey;
    }
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDistrictList() {
    // Create a map of district counts
    final Map<String, int> districtCount = {};
    for (var o in _orphanages) {
      final district = o['district'] ?? 'Unknown';
      districtCount[district] = (districtCount[district] ?? 0) + 1;
    }
    
    if (districtCount.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('No district data available')),
      );
    }
    
    final List<MapEntry<String, int>> entries = districtCount.entries.toList();
    
    return Column(
      children: entries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entry.key, style: const TextStyle(fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.value.toString(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}