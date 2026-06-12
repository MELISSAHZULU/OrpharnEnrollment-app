import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GovernmentDashboard extends StatefulWidget {
  @override
  _GovernmentDashboardState createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _orphanages = [
    {'name': 'Central Children\'s Home', 'compliance': 98, 'status': 'Exemplary', 'lastInspection': 'Jun 2024'},
    {'name': 'Hope Children\'s Center', 'compliance': 72, 'status': 'Needs Improvement', 'lastInspection': 'May 2024'},
    {'name': 'Lilongwe Children\'s Home', 'compliance': 95, 'status': 'Good', 'lastInspection': 'Apr 2024'},
    {'name': 'Blantyre Orphanage', 'compliance': 88, 'status': 'Satisfactory', 'lastInspection': 'Mar 2024'},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Government Portal'),
          backgroundColor: Colors.indigo,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.business), text: 'Orphanages'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'National Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Malawi Orphan Care System', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 24),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard('Total Orphanages', '12', Icons.business, Colors.indigo),
                      _buildStatCard('Children in Care', '1,234', Icons.people, Colors.green),
                      _buildStatCard('Pending Reports', '5', Icons.pending, Colors.orange),
                      _buildStatCard('Compliant', '10', Icons.check_circle, Colors.green),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compliance Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          ..._orphanages.map((o) => _buildComplianceTile(o)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Orphanages Tab
            ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _orphanages.length,
              itemBuilder: (context, index) {
                final o = _orphanages[index];
                Color statusColor;
                switch(o['status']) {
                  case 'Exemplary':
                    statusColor = Colors.green;
                    break;
                  case 'Needs Improvement':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }
                
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(Icons.business, color: statusColor),
                    ),
                    title: Text(o['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Compliance: ${o['compliance']}%'),
                    trailing: Chip(
                      label: Text(o['status']),
                      backgroundColor: statusColor.withOpacity(0.2),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Last Inspection', o['lastInspection']),
                            _buildDetailRow('Compliance Score', '${o['compliance']}%'),
                            _buildDetailRow('Status', o['status']),
                            Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(Icons.picture_as_pdf),
                                    label: Text('Export Report'),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(Icons.visibility),
                                    label: Text('View Details'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                                  ),
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
            
            // Statistics Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Children by District',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          _buildDistrictStat('Lilongwe', 45, Colors.blue),
                          _buildDistrictStat('Blantyre', 35, Colors.green),
                          _buildDistrictStat('Mzuzu', 15, Colors.orange),
                          _buildDistrictStat('Zomba', 5, Colors.purple),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Export Reports',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: Text('Annual Report 2024'),
                            subtitle: Text('Generated: June 2024'),
                            trailing: IconButton(
                              icon: Icon(Icons.download),
                              onPressed: () {},
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.description, color: Colors.blue),
                            title: Text('Compliance Report'),
                            subtitle: Text('Generated: June 2024'),
                            trailing: IconButton(
                              icon: Icon(Icons.download),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComplianceTile(Map<String, dynamic> orphanage) {
    final percentage = orphanage['compliance'] / 100;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orphanage['name'], style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${orphanage['compliance']}%', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            color: orphanage['compliance'] >= 80 ? Colors.green : Colors.red,
            height: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey))),
          Text(value),
        ],
      ),
    );
  }
  
  Widget _buildDistrictStat(String district, int percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(district, style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: color,
            height: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}