import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/child_detail_screen.dart';

class SocialWorkerDashboard extends StatefulWidget {
  @override
  _SocialWorkerDashboardState createState() => _SocialWorkerDashboardState();
}

class _SocialWorkerDashboardState extends State<SocialWorkerDashboard> {
  final ApiService _apiService = ApiService();
  List<dynamic> _activeCases = [];
  List<dynamic> _pendingVisits = [];
  bool _isLoading = true;
  String? _selectedCase;
  List<Map<String, dynamic>> _caseNotes = [];
  
  final TextEditingController _noteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCases();
  }
  
  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      
      setState(() {
        _activeCases = childrenList.where((c) => c['status'] != 'ENROLLED').take(5).toList();
        _pendingVisits = [
          {'name': 'Maria Phiri', 'village': 'Lilongwe', 'date': 'Today'},
          {'name': 'John Mwale', 'village': 'Blantyre', 'date': 'Tomorrow'},
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  void _addCaseNote() {
    if (_noteController.text.isNotEmpty && _selectedCase != null) {
      setState(() {
        _caseNotes.add({
          'date': DateTime.now().toString(),
          'note': _noteController.text,
        });
        _noteController.clear();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Social Services'),
          backgroundColor: Colors.green,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment), text: 'Active Cases'),
              Tab(icon: Icon(Icons.home_work), text: 'Home Visits'),
              Tab(icon: Icon(Icons.note), text: 'Case Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active Cases Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _activeCases.isEmpty
                    ? Center(child: Text('No active cases'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _activeCases.length,
                        itemBuilder: (context, index) {
                          final child = _activeCases[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(child['first_name']?[0] ?? 'C'),
                              ),
                              title: Text('${child['first_name']} ${child['last_name']}'),
                              subtitle: Text('Status: ${child['status']} | Village: ${child['village']}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  setState(() => _selectedCase = child['first_name']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Selected ${child['first_name']} for case notes')),
                                  );
                                },
                                child: Text('View Case'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            ),
                          );
                        },
                      ),
            
            // Home Visits Tab
            ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _pendingVisits.length,
              itemBuilder: (context, index) {
                final visit = _pendingVisits[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(Icons.home, color: Colors.orange),
                    ),
                    title: Text(visit['name']),
                    subtitle: Text('${visit['village']} - Scheduled: ${visit['date']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.location_on, color: Colors.blue),
                          onPressed: () {},
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Start Visit'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Case Notes Tab
            Column(
              children: [
                if (_selectedCase != null)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Current Case: $_selectedCase', style: TextStyle(fontWeight: FontWeight.bold)),
                            Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _selectedCase = null),
                              child: Text('Change'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _caseNotes.length,
                    itemBuilder: (context, index) {
                      final note = _caseNotes.reversed.toList()[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.note, color: Colors.green),
                          ),
                          title: Text(note['note']),
                          subtitle: Text(DateTime.parse(note['date']).toString().split(' ')[0]),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedCase != null)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Add case note...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: _addCaseNote,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/enroll');
          },
          child: Icon(Icons.person_add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}