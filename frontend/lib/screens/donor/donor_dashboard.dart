import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DonorDashboard extends StatefulWidget {
  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final ApiService _apiService = ApiService();
  List<dynamic> _sponsoredChildren = [];
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  
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
      
      setState(() {
        _sponsoredChildren = childrenList.take(2).toList();
        _donations = [
          {'amount': 100, 'date': 'Jun 2024', 'type': 'Monthly Sponsorship', 'status': 'Completed'},
          {'amount': 100, 'date': 'May 2024', 'type': 'Monthly Sponsorship', 'status': 'Completed'},
          {'amount': 100, 'date': 'Apr 2024', 'type': 'Monthly Sponsorship', 'status': 'Completed'},
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sponsor Portal'),
          backgroundColor: Colors.pink,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'My Sponsors'),
              Tab(icon: Icon(Icons.history), text: 'Donations'),
              Tab(icon: Icon(Icons.people), text: 'Sponsor More'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Sponsored Children Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _sponsoredChildren.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No sponsored children yet'),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Sponsor a Child'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _sponsoredChildren.length,
                        itemBuilder: (context, index) {
                          final child = _sponsoredChildren[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.pink.shade100,
                                        child: Text(
                                          child['first_name']?[0] ?? 'C',
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${child['first_name']} ${child['last_name']}',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text('Age: ${child['age']} years', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Chip(
                                        label: Text('Sponsored'),
                                        backgroundColor: Colors.green.shade100,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Divider(),
                                  SizedBox(height: 8),
                                  Text(
                                    '📸 Monthly Update: ${child['first_name']} is doing well in school!',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.photo),
                                          label: Text('View Photos'),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.message),
                                          label: Text('Send Message'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            
            // Donations History Tab
            ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _donations.length,
              itemBuilder: (context, index) {
                final donation = _donations[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink.shade100,
                      child: Icon(Icons.attach_money, color: Colors.pink),
                    ),
                    title: Text('\$${donation['amount']} - ${donation['type']}'),
                    subtitle: Text(donation['date']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(donation['status']),
                          backgroundColor: Colors.green.shade100,
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {},
                          tooltip: 'Download Receipt',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Sponsor More Children Tab
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 64, color: Colors.pink),
                    SizedBox(height: 16),
                    Text(
                      'Sponsor a Child in Need',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your monthly donation provides food, education, and healthcare',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Text('M'),
                        ),
                        title: Text('Maria Phiri, 6'),
                        subtitle: Text('Needs education support'),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: Text('Sponsor'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text('J'),
                        ),
                        title: Text('John Mwale, 4'),
                        subtitle: Text('Needs medical support'),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: Text('Sponsor'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                        ),
                      ),
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
}