import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
class EnrollChildScreen extends StatefulWidget {
  @override
  _EnrollChildScreenState createState() => _EnrollChildScreenState();
}

class _EnrollChildScreenState extends State<EnrollChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianContactController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedGender = 'M';
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enroll New Child'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'
                                : 'Select Date',
                            style: TextStyle(
                              color: _selectedDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.transgender),
                        ),
                        items: [
                          DropdownMenuItem(value: 'M', child: Text('Male')),
                          DropdownMenuItem(value: 'F', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Location Information
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _villageController,
                        decoration: InputDecoration(
                          labelText: 'Village',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _districtController,
                        decoration: InputDecoration(
                          labelText: 'District',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Guardian Information
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guardian Information (Optional)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _guardianNameController,
                        decoration: InputDecoration(
                          labelText: 'Guardian Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _guardianContactController,
                        decoration: InputDecoration(
                          labelText: 'Guardian Contact',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          helperText: 'Phone number if available',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Reason for Care
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason for Care',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Reason for seeking care',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitEnrollment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Submit Enrollment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _submitEnrollment() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final childData = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'date_of_birth': '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
          'gender': _selectedGender,
          'village': _villageController.text,
          'district': _districtController.text,
          'guardian_name': _guardianNameController.text,
          'guardian_contact': _guardianContactController.text,
          'reason_for_care': _reasonController.text,
        };
        
        final response = await _apiService.enrollChild(childData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Child enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _firstNameController.clear();
        _lastNameController.clear();
        _villageController.clear();
        _districtController.clear();
        _guardianNameController.clear();
        _guardianContactController.clear();
        _reasonController.clear();
        setState(() {
          _selectedDate = null;
          _selectedGender = 'M';
        });
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}