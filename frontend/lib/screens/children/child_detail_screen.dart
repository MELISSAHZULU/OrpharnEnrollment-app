import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../transport/transport_request_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final int childId;
  final Map<String, dynamic> child;
  
  const ChildDetailScreen({
    Key? key,
    required this.childId,
    required this.child,
  }) : super(key: key);
  
  @override
  _ChildDetailScreenState createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isEditing = false;
  late Map<String, dynamic> _childData;
  bool _isLoading = false;
  
  // Controllers for editing
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _villageController;
  late TextEditingController _districtController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianContactController;
  late TextEditingController _reasonController;
  
  @override
  void initState() {
    super.initState();
    _childData = Map.from(widget.child);
    _initControllers();
  }
  
  void _initControllers() {
    _firstNameController = TextEditingController(text: _childData['first_name']);
    _lastNameController = TextEditingController(text: _childData['last_name']);
    _villageController = TextEditingController(text: _childData['village']);
    _districtController = TextEditingController(text: _childData['district']);
    _guardianNameController = TextEditingController(text: _childData['guardian_name'] ?? '');
    _guardianContactController = TextEditingController(text: _childData['guardian_contact'] ?? '');
    _reasonController = TextEditingController(text: _childData['reason_for_care']);
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
  
  Future<void> _updateChild() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final updatedData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'village': _villageController.text,
        'district': _districtController.text,
        'guardian_name': _guardianNameController.text,
        'guardian_contact': _guardianContactController.text,
        'reason_for_care': _reasonController.text,
      };
      
      try {
        // You'll need to add this method to your ApiService
        // await _apiService.updateChild(widget.childId, updatedData);
        
        setState(() {
          _childData.addAll(updatedData);
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child information updated!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _showTransportRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => TransportRequestDialog(childId: widget.childId, childName: '${_childData['first_name']} ${_childData['last_name']}'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Child' : 'Child Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _updateChild,
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initControllers();
                });
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _isEditing ? _buildEditForm() : _buildViewMode(),
      floatingActionButton: !_isEditing
          ? FloatingActionButton.extended(
              onPressed: _showTransportRequestDialog,
              icon: Icon(Icons.directions_car),
              label: Text('Request Transport'),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }
  
  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Text(
                '${_childData['first_name'][0]}${_childData['last_name'][0]}',
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildInfoCard(),
          SizedBox(height: 16),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showTransportRequestDialog,
                          icon: Icon(Icons.directions_car),
                          label: Text('Transport'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add medical record functionality
                          },
                          icon: Icon(Icons.medical_services),
                          label: Text('Medical'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Full Name', '${_childData['first_name']} ${_childData['last_name']}'),
            Divider(),
            _buildInfoRow('Age', '${_childData['age']} years'),
            Divider(),
            _buildInfoRow('Gender', _childData['gender'] == 'M' ? 'Male' : 'Female'),
            Divider(),
            _buildInfoRow('Location', '${_childData['village']}, ${_childData['district']}'),
            if (_childData['guardian_name'] != null && _childData['guardian_name'].isNotEmpty) ...[
              Divider(),
              _buildInfoRow('Guardian', _childData['guardian_name']),
            ],
            if (_childData['guardian_contact'] != null && _childData['guardian_contact'].isNotEmpty) ...[
              Divider(),
              _buildInfoRow('Contact', _childData['guardian_contact']),
            ],
            Divider(),
            _buildInfoRow('Status', _childData['status']),
            Divider(),
            _buildInfoRow('Enrolled', _childData['enrollment_date'].toString().split(' ')[0]),
            Divider(),
            _buildInfoRow('Reason for Care', _childData['reason_for_care'], isLongText: true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {bool isLongText = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: isLongText ? 14 : 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _villageController,
              decoration: InputDecoration(labelText: 'Village', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: InputDecoration(labelText: 'District', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _guardianNameController,
              decoration: InputDecoration(labelText: 'Guardian Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _guardianContactController,
              decoration: InputDecoration(labelText: 'Guardian Contact', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Reason for Care', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Transport Request Dialog
class TransportRequestDialog extends StatefulWidget {
  final int childId;
  final String childName;
  
  const TransportRequestDialog({Key? key, required this.childId, required this.childName}) : super(key: key);
  
  @override
  _TransportRequestDialogState createState() => _TransportRequestDialogState();
}

class _TransportRequestDialogState extends State<TransportRequestDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Transport for ${widget.childName}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  hintText: 'Current location of the child',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Orphanage or hospital name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Any special requirements or information',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : () async {
            if (_formKey.currentState!.validate()) {
              setState(() => _isSubmitting = true);
              try {
                await _apiService.requestTransport(widget.childId, {
                  'pickup_location': _pickupController.text,
                  'destination': _destinationController.text,
                  'notes': _notesController.text,
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transport request sent!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                setState(() => _isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
          child: _isSubmitting ? CircularProgressIndicator() : Text('Submit Request'),
        ),
      ],
    );
  }
}