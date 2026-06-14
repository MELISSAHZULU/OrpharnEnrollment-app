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
  late Map<String, dynamic> _childData;
  bool _isEditing = false;
  
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
    _firstNameController = TextEditingController(text: _childData['first_name'] ?? '');
    _lastNameController = TextEditingController(text: _childData['last_name'] ?? '');
    _villageController = TextEditingController(text: _childData['village'] ?? '');
    _districtController = TextEditingController(text: _childData['district'] ?? '');
    _guardianNameController = TextEditingController(text: _childData['guardian_name'] ?? '');
    _guardianContactController = TextEditingController(text: _childData['guardian_contact'] ?? '');
    _reasonController = TextEditingController(text: _childData['reason_for_care'] ?? '');
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
  
  void _showTransportRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportRequestScreen(
          childId: widget.childId,
          childName: '${_childData['first_name']} ${_childData['last_name']}'.trim(),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final firstName = _childData['first_name'] ?? '';
    final lastName = _childData['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(fullName.isEmpty ? 'Child Details' : fullName),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: _isEditing ? _buildEditForm() : _buildViewMode(),
    );
  }
  
  Widget _buildViewMode() {
    final firstName = _childData['first_name'] ?? '';
    final lastName = _childData['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Unnamed Child' : fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(_childData['status'] ?? 'PENDING'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDetailRow('First Name', _childData['first_name'] ?? 'Not specified'),
                  _buildDetailRow('Last Name', _childData['last_name'] ?? 'Not specified'),
                  _buildDetailRow('Age', '${_childData['age'] ?? '?'} years'),
                  _buildDetailRow('Gender', _childData['gender'] == 'M' ? 'Male' : _childData['gender'] == 'F' ? 'Female' : 'Not specified'),
                  _buildDetailRow('Village', _childData['village'] ?? 'Unknown'),
                  _buildDetailRow('District', _childData['district'] ?? 'Unknown'),
                  if (_childData['guardian_name'] != null && _childData['guardian_name'].toString().isNotEmpty) ...[
                    _buildDetailRow('Guardian', _childData['guardian_name']),
                  ],
                  if (_childData['guardian_contact'] != null && _childData['guardian_contact'].toString().isNotEmpty) ...[
                    _buildDetailRow('Guardian Contact', _childData['guardian_contact']),
                  ],
                  _buildDetailRow('Enrollment Date', _childData['enrollment_date']?.toString().split('T')[0] ?? 'Unknown'),
                  _buildDetailRow('Reason for Care', _childData['reason_for_care'] ?? 'Not specified'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.directions_car, color: Colors.white),
                    ),
                    title: const Text('Request Transport'),
                    subtitle: const Text('Arrange pickup or drop-off transport'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showTransportRequest,
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.medical_services, color: Colors.white),
                    ),
                    title: const Text('Medical Records'),
                    subtitle: const Text('View and add medical information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to medical records
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.note, color: Colors.white),
                    ),
                    title: const Text('Case Notes'),
                    subtitle: const Text('Document case progress and notes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to case notes
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(labelText: 'Village'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(labelText: 'District'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guardianNameController,
                      decoration: const InputDecoration(labelText: 'Guardian Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guardianContactController,
                      decoration: const InputDecoration(labelText: 'Guardian Contact'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Reason for Care'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
                              );
                            },
                            child: const Text('Save'),
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
      ),
    );
  }
}