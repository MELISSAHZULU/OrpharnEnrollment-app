import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../transport/transport_request_screen.dart';
import '../medical/medical_records_screen.dart';
import '../case_notes/case_notes_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final int childId;
  final Map<String, dynamic> child;
  
  const ChildDetailScreen({
    super.key, 
    required this.childId, 
    required this.child
  });

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final ApiService _apiService = ApiService();
  late Map<String, dynamic> _childData;
  bool _isEditing = false;
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
    _childData = Map<String, dynamic>.from(widget.child);
    _initControllers();
  }
  
  void _initControllers() {
    _firstNameController = TextEditingController(text: _childData['first_name']?.toString() ?? '');
    _lastNameController = TextEditingController(text: _childData['last_name']?.toString() ?? '');
    _villageController = TextEditingController(text: _childData['village']?.toString() ?? '');
    _districtController = TextEditingController(text: _childData['district']?.toString() ?? '');
    _guardianNameController = TextEditingController(text: _childData['guardian_name']?.toString() ?? '');
    _guardianContactController = TextEditingController(text: _childData['guardian_contact']?.toString() ?? '');
    _reasonController = TextEditingController(text: _childData['reason_for_care']?.toString() ?? '');
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
  
  Future<void> _loadChildData() async {
    setState(() => _isLoading = true);
    try {
      final child = await _apiService.getChild(widget.childId);
      setState(() {
        _childData = child;
        _isLoading = false;
      });
      _initControllers();
    } catch (e) {
      print('Error loading child: $e');
      setState(() => _isLoading = false);
    }
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
        await _apiService.updateChild(widget.childId, updatedData);
        await _loadChildData();
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child information updated!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final firstName = _childData['first_name']?.toString() ?? '';
    final lastName = _childData['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final age = _childData['age']?.toString() ?? '?';
    final village = _childData['village']?.toString() ?? 'Unknown';
    final district = _childData['district']?.toString() ?? 'Unknown';
    final status = _childData['status']?.toString() ?? 'PENDING';
    final reasonForCare = _childData['reason_for_care']?.toString() ?? 'Not specified';
    final enrollmentDate = _childData['enrollment_date']?.toString().split('T')[0] ?? 'Unknown';
    final guardianName = _childData['guardian_name']?.toString();
    final guardianContact = _childData['guardian_contact']?.toString();
    final gender = _childData['gender']?.toString() ?? 'U';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(fullName.isEmpty ? 'Child Details' : fullName),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4C1D95),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _updateChild,
              child: const Text('Save', style: TextStyle(color: Color(0xFF4C1D95))),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initControllers();
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing 
              ? _buildEditForm() 
              : _buildViewMode(fullName, age, village, district, status, reasonForCare, enrollmentDate, guardianName, guardianContact, gender),
    );
  }
  
  Widget _buildViewMode(String fullName, String age, String village, String district, 
      String status, String reasonForCare, String enrollmentDate, String? guardianName, 
      String? guardianContact, String gender) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            color: const Color(0xFF7C3AED).withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF7C3AED),
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
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(status),
                          backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                          labelStyle: const TextStyle(color: Color(0xFF7C3AED)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const Divider(),
                  _buildDetailRow('First Name', _childData['first_name']?.toString() ?? 'Not specified'),
                  _buildDetailRow('Last Name', _childData['last_name']?.toString() ?? 'Not specified'),
                  _buildDetailRow('Age', '$age years'),
                  _buildDetailRow('Gender', gender == 'M' ? 'Male' : gender == 'F' ? 'Female' : 'Not specified'),
                  _buildDetailRow('Village', village),
                  _buildDetailRow('District', district),
                  if (guardianName != null && guardianName.isNotEmpty) ...[
                    _buildDetailRow('Guardian', guardianName),
                  ],
                  if (guardianContact != null && guardianContact.isNotEmpty) ...[
                    _buildDetailRow('Guardian Contact', guardianContact),
                  ],
                  _buildDetailRow('Enrollment Date', enrollmentDate),
                  _buildDetailRow('Reason for Care', reasonForCare),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF7C3AED),
                      child: Icon(Icons.directions_car, color: Colors.white),
                    ),
                    title: const Text('Request Transport', style: TextStyle(color: Color(0xFF1F2937))),
                    subtitle: const Text('Arrange pickup or drop-off transport', style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportRequestScreen(
                            childId: widget.childId,
                            childName: fullName,
                          ),
                        ),
                      ).then((_) => _loadChildData());
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF7C3AED),
                      child: Icon(Icons.medical_services, color: Colors.white),
                    ),
                    title: const Text('Medical Records', style: TextStyle(color: Color(0xFF1F2937))),
                    subtitle: const Text('View and add medical information', style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalRecordsScreen(
                            childId: widget.childId,
                            childName: fullName,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF7C3AED),
                      child: Icon(Icons.note, color: Colors.white),
                    ),
                    title: const Text('Case Notes', style: TextStyle(color: Color(0xFF1F2937))),
                    subtitle: const Text('Document case progress and notes', style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaseNotesScreen(
                            childId: widget.childId,
                            childName: fullName,
                          ),
                        ),
                      );
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
            child: Text(value, style: const TextStyle(color: Color(0xFF1F2937))),
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
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _initControllers();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7C3AED)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateChild,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                        child: const Text('Save Changes'),
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
}