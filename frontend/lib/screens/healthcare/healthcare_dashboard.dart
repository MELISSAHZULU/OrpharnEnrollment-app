import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/enroll_child_screen.dart';
import '../children/children_list_screen.dart';
import 'emergency_enrollment_screen.dart';

class HealthcareDashboard extends StatefulWidget {
  @override
  _HealthcareDashboardState createState() => _HealthcareDashboardState();
}

class _HealthcareDashboardState extends State<HealthcareDashboard> {
  final ApiService _apiService = ApiService();
  int _emergencyCases = 0;
  int _pendingMedicalReviews = 0;
  int _todayEnrollments = 0;
  int _vaccinationsDue = 0;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _recentEnrollments = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final medicalCases = children.where((c) => c['special_needs'] != null && c['special_needs'].isNotEmpty).length;
      
      setState(() {
        _emergencyCases = children.where((c) => c['status'] == 'EMERGENCY').length;
        _pendingMedicalReviews = children.where((c) => c['medical_review_needed'] == true).length;
        _todayEnrollments = children.where((c) => c['enrollment_date'].toString().contains(DateTime.now().toString().substring(0, 10))).length;
        _vaccinationsDue = 15; // Demo data
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
        title: Text('Healthcare Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.medical_services),
            onPressed: () => _showMedicalStats(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Healthcare Worker',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'You can enroll orphans directly from the health facility',
                              style: TextStyle(color: Colors.teal.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Emergency Enrollment Button - PROMINENT
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmergencyEnrollmentScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.emergency, color: Colors.white, size: 32),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMERGENCY ENROLLMENT',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              Text(
                                'Mother loss at birth | Abandoned newborn | Critical case',
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Stats Cards
              if (!_isLoading)
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatsCard(
                      'Emergency Cases',
                      '$_emergencyCases',
                      Icons.emergency,
                      Colors.red,
                      'Requires immediate attention',
                    ),
                    _buildStatsCard(
                      'Medical Reviews',
                      '$_pendingMedicalReviews',
                      Icons.medical_information,
                      Colors.orange,
                      'Pending assessment',
                    ),
                    _buildStatsCard(
                      'Today\'s Enrollments',
                      '$_todayEnrollments',
                      Icons.person_add,
                      Colors.green,
                      'From health facility',
                    ),
                    _buildStatsCard(
                      'Vaccinations Due',
                      '$_vaccinationsDue',
                      Icons.vaccines,
                      Colors.blue,
                      'This week',
                    ),
                  ],
                ),
              
              SizedBox(height: 24),
              
              // Quick Actions
              Card(
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
                            'Standard Enrollment',
                            Icons.person_add,
                            Colors.blue,
                            () => Navigator.pushNamed(context, '/enroll'),
                          ),
                          _buildQuickAction(
                            'Birth Enrollment',
                            Icons.child_care,
                            Colors.teal,
                            () => _showBirthEnrollmentDialog(),
                          ),
                          _buildQuickAction(
                            'Medical Records',
                            Icons.medical_information,
                            Colors.purple,
                            () => Navigator.pushNamed(context, '/medical'),
                          ),
                          _buildQuickAction(
                            'Vaccinations',
                            Icons.vaccines,
                            Colors.green,
                            () => Navigator.pushNamed(context, '/vaccinations'),
                          ),
                          _buildQuickAction(
                            'View Children',
                            Icons.people,
                            Colors.orange,
                            () => Navigator.pushNamed(context, '/children'),
                          ),
                          _buildQuickAction(
                            'Request Transport',
                            Icons.local_hospital,
                            Colors.red,
                            () => _requestAmbulance(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Recent Medical Enrollments
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Recent Medical Enrollments',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: Icon(Icons.child_care, color: Colors.red),
                        ),
                        title: Text('Baby Girl (Mother passed at birth)'),
                        subtitle: Text('Queen Elizabeth Hospital - Enrolled today'),
                        trailing: Chip(
                          label: Text('Emergency', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.red.shade100,
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(Icons.medical_services, color: Colors.orange),
                        ),
                        title: Text('John Mwale - Premature Baby'),
                        subtitle: Text('Kamuzu Central Hospital - Needs NICU care'),
                        trailing: Chip(
                          label: Text('Medical', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.orange.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
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
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
          ],
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
  
  void _showBirthEnrollmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Birth Enrollment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, size: 50, color: Colors.teal),
            SizedBox(height: 12),
            Text('Enroll a newborn orphan:'),
            SizedBox(height: 8),
            Text(
              '• Mother passed away during delivery\n'
              '• Abandoned newborn at facility\n'
              '• Baby left without guardian',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/enroll', arguments: {'type': 'birth_emergency'});
            },
            child: Text('Proceed'),
          ),
        ],
      ),
    );
  }
  
  void _requestAmbulance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Ambulance'),
        content: Text('Request immediate medical transport for a child?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transport');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Request Emergency Transport'),
          ),
        ],
      ),
    );
  }
  
  void _showMedicalStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Medical Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Total Children: 156'), leading: Icon(Icons.people)),
            ListTile(title: Text('Medical Cases: 23'), leading: Icon(Icons.medical_services)),
            ListTile(title: Text('Special Needs: 8'), leading: Icon(Icons.accessibility_new)),
            ListTile(title: Text('Vaccinations Today: 5'), leading: Icon(Icons.vaccines)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}