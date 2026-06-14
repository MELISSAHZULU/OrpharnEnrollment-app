import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final int childId;
  final String childName;
  
  const MedicalRecordsScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);
  
  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _medicalRecords = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
  }
  
  Future<void> _loadMedicalRecords() async {
    setState(() => _isLoading = true);
    try {
      // For now, show placeholder
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _medicalRecords = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  void _showAddRecordDialog() {
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Medical Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: diagnosisController,
              decoration: InputDecoration(labelText: 'Diagnosis'),
              maxLines: 2,
            ),
            SizedBox(height: 12),
            TextField(
              controller: treatmentController,
              decoration: InputDecoration(labelText: 'Treatment'),
              maxLines: 2,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Medical record added!'), backgroundColor: Colors.green),
              );
              _loadMedicalRecords();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records - ${widget.childName}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddRecordDialog,
            tooltip: 'Add Medical Record',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No medical records yet'),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddRecordDialog,
                        icon: Icon(Icons.add),
                        label: Text('Add Medical Record'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _medicalRecords.length,
                  itemBuilder: (context, index) {
                    final record = _medicalRecords[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.medical_services, color: Colors.teal),
                        ),
                        title: Text(record['diagnosis'] ?? 'No diagnosis'),
                        subtitle: Text(record['treatment'] ?? 'No treatment'),
                        trailing: Text(
                          record['date']?.toString().split('T')[0] ?? 'Unknown',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}