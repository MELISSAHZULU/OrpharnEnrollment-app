import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VillageHeadDashboard extends StatefulWidget {
  @override
  _VillageHeadDashboardState createState() => _VillageHeadDashboardState();
}

class _VillageHeadDashboardState extends State<VillageHeadDashboard> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedStatus;
  List<Map<String, dynamic>> _myReports = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _loadReports();
  }
  
  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      // Load reports from API
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      setState(() {
        _myReports = childrenList.take(5).map((c) => ({
          'name': '${c['first_name']} ${c['last_name']}',
          'status': c['status'],
          'date': c['enrollment_date']?.toString().split('T')[0] ?? 'Unknown',
        })).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      await Future.delayed(Duration(seconds: 1));
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted! Social worker will be assigned.'), backgroundColor: Colors.green),
      );
      
      _childNameController.clear();
      _ageController.clear();
      _villageController.clear();
      _situationController.clear();
      _guardianController.clear();
      setState(() {
        _selectedGender = null;
        _selectedStatus = null;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Village Portal'),
          backgroundColor: Colors.orange,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_alert), text: 'Report Orphan'),
              Tab(icon: Icon(Icons.history), text: 'My Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Report Form Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report an Orphaned Child',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fill this form to report a child in need of care',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Divider(),
                            SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _childNameController,
                              decoration: InputDecoration(
                                labelText: 'Child\'s Full Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _ageController,
                                    decoration: InputDecoration(
                                      labelText: 'Age',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: Icon(Icons.cake),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    value: _selectedGender,
                                    items: [
                                      DropdownMenuItem(value: 'M', child: Text('Male')),
                                      DropdownMenuItem(value: 'F', child: Text('Female')),
                                    ],
                                    onChanged: (v) => setState(() => _selectedGender = v),
                                    validator: (v) => v == null ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            
                            TextFormField(
                              controller: _villageController,
                              decoration: InputDecoration(
                                labelText: 'Village/Town',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12),
                            
                            TextFormField(
                              controller: _guardianController,
                              decoration: InputDecoration(
                                labelText: 'Known Guardian/Relative (if any)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.family_restroom),
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            TextFormField(
                              controller: _situationController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Situation Description',
                                hintText: 'Describe why this child needs care...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.description, size: 20),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('SUBMIT REPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    
                    SizedBox(height: 16),
                    Text(
                      'Note: A social worker will contact you within 48 hours',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // My Reports Tab
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _myReports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No reports submitted yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _myReports.length,
                        itemBuilder: (context, index) {
                          final report = _myReports[index];
                          Color statusColor;
                          IconData statusIcon;
                          
                          switch(report['status']) {
                            case 'PENDING':
                              statusColor = Colors.orange;
                              statusIcon = Icons.pending;
                              break;
                            case 'ENROLLED':
                              statusColor = Colors.green;
                              statusIcon = Icons.check_circle;
                              break;
                            default:
                              statusColor = Colors.blue;
                              statusIcon = Icons.assignment_turned_in;
                          }
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.2),
                                child: Icon(statusIcon, color: statusColor),
                              ),
                              title: Text(report['name']),
                              subtitle: Text('Reported: ${report['date']}'),
                              trailing: Chip(
                                label: Text(report['status']),
                                backgroundColor: statusColor.withOpacity(0.2),
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
}