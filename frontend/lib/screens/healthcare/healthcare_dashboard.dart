import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/enroll_child_screen.dart';

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
  List<dynamic> _recentEnrollments = [];
  
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
      
      _emergencyCases = childrenList.where((c) => c['status'] == 'EMERGENCY').length;
      _pendingMedicalReviews = childrenList.where((c) => c['status'] == 'MEDICAL_CHECK').length;
      
      final today = DateTime.now().toString().substring(0, 10);
      _todayEnrollments = childrenList.where((c) => 
        c['enrollment_date']?.toString().contains(today) ?? false
      ).length;
      
      // Safe way to get recent enrollments
      if (childrenList.isNotEmpty) {
        _recentEnrollments = childrenList.length > 5 
            ? childrenList.sublist(0, 5) 
            : List.from(childrenList);
      } else {
        _recentEnrollments = [];
      }
      
      _vaccinationsDue = 0;
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading healthcare dashboard: $e');
      setState(() {
        _recentEnrollments = [];
        _isLoading = false;
      });
    }
  }
  
  void _showEmergencyEnrollmentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmergencyEnrollmentDialog(
        onSuccess: () => _loadDashboardData(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Portal'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
              
              // Emergency Enrollment Card
              InkWell(
                onTap: _showEmergencyEnrollmentDialog,
                child: Card(
                  color: Colors.red.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    _buildStatsCard('Emergency Cases', '$_emergencyCases', Icons.emergency, Colors.red, 'Requires immediate attention'),
                    _buildStatsCard('Medical Reviews', '$_pendingMedicalReviews', Icons.medical_information, Colors.orange, 'Pending assessment'),
                    _buildStatsCard('Today\'s Enrollments', '$_todayEnrollments', Icons.person_add, Colors.green, 'From health facility'),
                    _buildStatsCard('Vaccinations Due', '$_vaccinationsDue', Icons.vaccines, Colors.blue, 'This week'),
                  ],
                ),
              
              SizedBox(height: 24),
              
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
                            'Recent Enrollments',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator())
                      else if (_recentEnrollments.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('No enrollments yet'),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _showEmergencyEnrollmentDialog,
                                  child: Text('Enroll First Child'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._recentEnrollments.map((child) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: child['status'] == 'EMERGENCY' 
                                ? Colors.red.shade100 
                                : Colors.teal.shade100,
                            child: Icon(
                              child['status'] == 'EMERGENCY' 
                                  ? Icons.emergency 
                                  : Icons.child_care,
                              color: child['status'] == 'EMERGENCY' ? Colors.red : Colors.teal,
                            ),
                          ),
                          title: Text('${child['first_name'] ?? 'Unknown'} ${child['last_name'] ?? ''}'),
                          subtitle: Text('Age: ${child['age'] ?? '?'} | ${child['village'] ?? 'Unknown'}'),
                          trailing: Chip(
                            label: Text(child['status'] ?? 'PENDING'),
                            backgroundColor: child['status'] == 'EMERGENCY' 
                                ? Colors.red.shade100 
                                : Colors.grey.shade200,
                          ),
                        )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEmergencyEnrollmentDialog,
        icon: Icon(Icons.emergency),
        label: Text('Emergency'),
        backgroundColor: Colors.red,
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
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// Emergency Enrollment Dialog
class EmergencyEnrollmentDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  
  const EmergencyEnrollmentDialog({super.key, this.onSuccess});
  
  @override
  _EmergencyEnrollmentDialogState createState() => _EmergencyEnrollmentDialogState();
}

class _EmergencyEnrollmentDialogState extends State<EmergencyEnrollmentDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String? _emergencyType;
  String? _babyGender;
  String? _babyName;
  String? _motherName;
  DateTime? _birthDate;
  String? _medicalCondition;
  bool _needsImmediateTransport = true;
  String? _healthFacility;
  bool _isSubmitting = false;
  
  final List<Map<String, dynamic>> _emergencyTypes = [
    {'value': 'birth_loss', 'label': 'Mother passed during childbirth', 'icon': Icons.female, 'color': Colors.pink},
    {'value': 'abandoned', 'label': 'Abandoned newborn/infant', 'icon': Icons.child_care, 'color': Colors.orange},
    {'value': 'medical_emergency', 'label': 'Critical medical condition', 'icon': Icons.medical_services, 'color': Colors.red},
    {'value': 'abuse', 'label': 'Child abuse/neglect case', 'icon': Icons.warning, 'color': Colors.purple},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'EMERGENCY ENROLLMENT',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('Complete this form for urgent cases', style: TextStyle(color: Colors.grey)),
                Divider(),
                SizedBox(height: 16),
                
                Text('Emergency Type', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ..._emergencyTypes.map((type) => RadioListTile<String>(
                  title: Text(type['label']),
                  value: type['value'],
                  groupValue: _emergencyType,
                  onChanged: (value) => setState(() => _emergencyType = value),
                  secondary: Icon(type['icon'], color: type['color']),
                  contentPadding: EdgeInsets.zero,
                )),
                
                SizedBox(height: 16),
                Text('Child Information', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Baby/Child Name', border: OutlineInputBorder()),
                  onChanged: (v) => _babyName = v,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Gender'),
                        items: [
                          DropdownMenuItem(value: 'M', child: Text('Male')),
                          DropdownMenuItem(value: 'F', child: Text('Female')),
                          DropdownMenuItem(value: 'U', child: Text('Unknown')),
                        ],
                        onChanged: (v) => _babyGender = v,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _birthDate = date);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Birth Date'),
                          child: Text(_birthDate != null 
                              ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                              : 'Select Date'),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_emergencyType == 'birth_loss') ...[
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Mother's Name (Deceased)", border: OutlineInputBorder()),
                    onChanged: (v) => _motherName = v,
                  ),
                ],
                
                SizedBox(height: 16),
                Text('Medical Information', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Medical Condition / Notes',
                    border: OutlineInputBorder(),
                    hintText: 'Describe any medical needs or conditions',
                  ),
                  onChanged: (v) => _medicalCondition = v,
                ),
                
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Health Facility', border: OutlineInputBorder()),
                        onChanged: (v) => _healthFacility = v,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                CheckboxListTile(
                  title: Text('Needs immediate ambulance/transport'),
                  value: _needsImmediateTransport,
                  onChanged: (v) => setState(() => _needsImmediateTransport = v!),
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                ),
                
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitEmergencyEnrollment,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: _isSubmitting 
                            ? CircularProgressIndicator() 
                            : Text('SUBMIT EMERGENCY'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _submitEmergencyEnrollment() async {
    if (_emergencyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select emergency type'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final childData = {
        'first_name': _babyName ?? 'Baby',
        'last_name': '',
        'date_of_birth': _birthDate?.toIso8601String().split('T')[0],
        'gender': _babyGender ?? 'U',
        'village': _healthFacility ?? 'Health Facility',
        'district': 'Unknown',
        'emergency_type': _emergencyType,
        'mother_name': _motherName,
        'health_facility': _healthFacility,
        'needs_immediate_transport': _needsImmediateTransport,
        'medical_notes': _medicalCondition,
        'reason_for_care': _emergencyTypes.firstWhere((t) => t['value'] == _emergencyType)['label'],
        'status': 'EMERGENCY',
      };
      
      await _apiService.enrollChild(childData);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emergency enrollment submitted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}