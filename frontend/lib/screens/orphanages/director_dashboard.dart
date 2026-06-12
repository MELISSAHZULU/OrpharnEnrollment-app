import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class DirectorDashboard extends StatefulWidget {
  @override
  _DirectorDashboardState createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends State<DirectorDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  
  // Statistics
  int _totalChildren = 0;
  int _placedChildren = 0;
  int _pendingChildren = 0;
  int _reunitedChildren = 0;
  int _transferredChildren = 0;
  int _activeStaff = 0;
  int _availableBeds = 0;
  
  // Lists
  List<dynamic> _childrenList = [];
  List<dynamic> _pendingPlacements = [];
  List<dynamic> _recentTransports = [];
  
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
      final beds = await _apiService.getBedAvailability();
      final staff = await _apiService.getStaff();
      
      setState(() {
        _childrenList = childrenList;
        _totalChildren = childrenList.length;
        _placedChildren = childrenList.where((c) => c['status'] == 'PLACED' || c['status'] == 'IN_CARE').length;
        _pendingChildren = childrenList.where((c) => c['status'] == 'PENDING' || c['status'] == 'AWAITING_BED').length;
        _reunitedChildren = childrenList.where((c) => c['status'] == 'REUNITED').length;
        _transferredChildren = childrenList.where((c) => c['status'] == 'TRANSFERRED').length;
        _activeStaff = (staff is List ? staff : []).where((s) => s['is_active'] == true).length;
        _availableBeds = beds['available_beds'] ?? 0;
        
        _pendingPlacements = childrenList
            .where((c) => c['status'] == 'PENDING' || c['status'] == 'AWAITING_BED')
            .take(5)
            .toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orphanage Director Portal'),
          backgroundColor: Colors.blue,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.pending), text: 'Pending'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildStatCard('Total Children', _totalChildren.toString(), Icons.people, Colors.blue),
                            _buildStatCard('Placed', _placedChildren.toString(), Icons.check_circle, Colors.green),
                            _buildStatCard('Pending', _pendingChildren.toString(), Icons.pending, Colors.orange),
                            _buildStatCard('Reunited', _reunitedChildren.toString(), Icons.family_restroom, Colors.purple),
                            _buildStatCard('Transferred', _transferredChildren.toString(), Icons.swap_horiz, Colors.indigo),
                            _buildStatCard('Staff', _activeStaff.toString(), Icons.people_outline, Colors.teal),
                            _buildStatCard('Available Beds', _availableBeds.toString(), Icons.bed, Colors.cyan),
                          ],
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Placement Status Chart
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Placement Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 16),
                                _buildStatusBar('Placed', _placedChildren, _totalChildren, Colors.green),
                                _buildStatusBar('In Progress', _pendingChildren, _totalChildren, Colors.orange),
                                _buildStatusBar('Reunited', _reunitedChildren, _totalChildren, Colors.purple),
                                _buildStatusBar('Transferred', _transferredChildren, _totalChildren, Colors.indigo),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            
            // History Tab - Shows all children with their status history
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _childrenList.isEmpty
                    ? Center(child: Text('No children data'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _childrenList.length,
                        itemBuilder: (context, index) {
                          final child = _childrenList[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(child['status']),
                                child: Text(child['first_name']?[0] ?? 'C'),
                              ),
                              title: Text('${child['first_name']} ${child['last_name']}'),
                              subtitle: Text('Age: ${child['age']} | Status: ${child['status']}'),
                              trailing: Chip(
                                label: Text(child['status']),
                                backgroundColor: _getStatusColor(child['status']).withOpacity(0.2),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHistoryDetail('Enrollment Date', child['enrollment_date']?.toString().split('T')[0] ?? 'N/A'),
                                      _buildHistoryDetail('Village', child['village']),
                                      _buildHistoryDetail('District', child['district']),
                                      _buildHistoryDetail('Guardian', child['guardian_name'] ?? 'None'),
                                      _buildHistoryDetail('Reason for Care', child['reason_for_care']),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {},
                                            icon: Icon(Icons.history),
                                            label: Text('View Full History'),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () {},
                                            icon: Icon(Icons.visibility),
                                            label: Text('Details'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            
            // Pending Placements Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _pendingPlacements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 64, color: Colors.green),
                            SizedBox(height: 16),
                            Text('No pending placements', style: TextStyle(fontSize: 18)),
                            Text('All children have been placed'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _pendingPlacements.length,
                        itemBuilder: (context, index) {
                          final child = _pendingPlacements[index];
                          return Card(
                            color: Colors.orange.shade50,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Text(child['first_name']?[0] ?? 'C'),
                              ),
                              title: Text('${child['first_name']} ${child['last_name']}'),
                              subtitle: Text('Age: ${child['age']} | From: ${child['village']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.bed, color: Colors.blue),
                                    onPressed: () {},
                                    tooltip: 'Assign Bed',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.directions_car, color: Colors.orange),
                                    onPressed: () {},
                                    tooltip: 'Request Transport',
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Text('Place'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$count ($percentage.toStringAsFixed(1)%)', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String? status) {
    switch(status) {
      case 'PLACED': return Colors.green;
      case 'IN_CARE': return Colors.teal;
      case 'PENDING': return Colors.orange;
      case 'AWAITING_BED': return Colors.amber;
      case 'REUNITED': return Colors.purple;
      case 'TRANSFERRED': return Colors.indigo;
      case 'EMERGENCY': return Colors.red;
      default: return Colors.grey;
    }
  }
}