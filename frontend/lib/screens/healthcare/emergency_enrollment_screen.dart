import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EmergencyEnrollmentScreen extends StatefulWidget {
  @override
  _EmergencyEnrollmentScreenState createState() => _EmergencyEnrollmentScreenState();
}

class _EmergencyEnrollmentScreenState extends State<EmergencyEnrollmentScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Emergency enrollment specific fields
  String? _enrollmentType; // birth_loss, abandoned, medical_emergency, abuse
  String? _babyGender;
  String? _motherName;
  DateTime? _birthDate;
  String? _medicalCondition;
  bool _needsImmediateTransport = false;
  String? _preferredOrphanage;
  
  final List<Map<String, dynamic>> _emergencyTypes = [
    {'value': 'birth_loss', 'label': 'Mother passed during childbirth', 'icon': Icons.female, 'color': Colors.pink},
    {'value': 'abandoned', 'label': 'Abandoned newborn/infant', 'icon': Icons.child_care, 'color': Colors.orange},
    {'value': 'medical_emergency', 'label': 'Critical medical condition', 'icon': Icons.medical_services, 'color': Colors.red},
    {'value': 'abuse', 'label': 'Child abuse/neglect case', 'icon': Icons.warning, 'color': Colors.purple},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Enrollment'),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Alert Banner
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is an emergency enrollment. The child needs immediate attention.',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Emergency Type Selection
              Text(
                'Emergency Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ..._emergencyTypes.map((type) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text(type['label']),
                  value: type['value'],
                  groupValue: _enrollmentType,
                  onChanged: (value) {
                    setState(() {
                      _enrollmentType = value;
                    });
                  },
                  secondary: Icon(type['icon'], color: type['color']),
                ),
              )),
              
              SizedBox(height: 24),
              
              // Child Information
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      
                      if (_enrollmentType == 'birth_loss') ...[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mother\'s Name',
                            hintText: 'Deceased mother\'s name (if known)',
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (v) => _motherName = v,
                        ),
                        SizedBox(height: 12),
                      ],
                      
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Child\'s Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'M', child: Text('Male')),
                          DropdownMenuItem(value: 'F', child: Text('Female')),
                          DropdownMenuItem(value: 'U', child: Text('Unknown')),
                        ],
                        onChanged: (v) => _babyGender = v,
                      ),
                      SizedBox(height: 12),
                      
                      ListTile(
                        title: Text(_birthDate != null 
                            ? 'Birth Date: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                            : 'Select Birth Date'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _birthDate = date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Medical Information
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Medical Condition',
                          hintText: 'Describe any medical needs or conditions',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (v) => _medicalCondition = v,
                      ),
                      SizedBox(height: 12),
                      
                      CheckboxListTile(
                        title: Text('Needs immediate ambulance/transport'),
                        value: _needsImmediateTransport,
                        onChanged: (v) => setState(() => _needsImmediateTransport = v!),
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Orphanage Assignment
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Placement Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Preferred Orphanage',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'central', child: Text('Central Orphanage - Lilongwe')),
                          DropdownMenuItem(value: 'blantyre', child: Text('Blantyre Children\'s Home')),
                          DropdownMenuItem(value: 'mzuzu', child: Text('Mzuzu Orphanage')),
                        ],
                        onChanged: (v) => _preferredOrphanage = v,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitEmergencyEnrollment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'SUBMIT EMERGENCY ENROLLMENT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              SizedBox(height: 16),
              Text(
                'Note: This will immediately notify the orphanage and trigger emergency protocols.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _submitEmergencyEnrollment() async {
    // Submit emergency enrollment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emergency enrollment submitted!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }
}