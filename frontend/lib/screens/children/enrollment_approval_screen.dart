import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class EnrollmentApprovalScreen extends StatefulWidget {
  final int childId;
  final String childName;
  
  const EnrollmentApprovalScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);
  
  @override
  _EnrollmentApprovalScreenState createState() => _EnrollmentApprovalScreenState();
}

class _EnrollmentApprovalScreenState extends State<EnrollmentApprovalScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _currentStatus = 'INITIATED';
  List<String> _criteriaMet = [];
  String _verificationNotes = '';
  String _rejectionReason = '';
  
  final List<Map<String, dynamic>> _criteria = [
    {
      'id': 'orphan_status',
      'title': 'Confirmed Orphan Status',
      'description': 'Both parents deceased or missing',
      'verification': 'Death certificates or village head confirmation'
    },
    {
      'id': 'abandoned',
      'title': 'Abandoned Child',
      'description': 'Child abandoned by guardians',
      'verification': 'Police report or hospital record'
    },
    {
      'id': 'neglect',
      'title': 'Severe Neglect/Abuse',
      'description': 'Child in dangerous situation',
      'verification': 'Social worker assessment or medical report'
    },
    {
      'id': 'medical_need',
      'title': 'Medical Emergency',
      'description': 'Child needs urgent medical care',
      'verification': "Doctor's recommendation or hospital admission"
    },
    {
      'id': 'family_incapacity',
      'title': 'Family Incapacity',
      'description': 'Family unable to provide care',
      'verification': 'Social worker assessment or family interview'
    }
  ];
  
  @override
  void initState() {
    super.initState();
    _loadEnrollmentStatus();
  }
  
  Future<void> _loadEnrollmentStatus() async {
    setState(() => _isLoading = true);
    try {
      final child = await _apiService.getChild(widget.childId);
      setState(() {
        _currentStatus = child['enrollment_status'] ?? 'INITIATED';
        _criteriaMet = List<String>.from(child['criteria_met'] ?? []);
        _verificationNotes = child['verification_notes'] ?? '';
        _rejectionReason = child['rejection_reason'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateEnrollmentStatus(widget.childId, {
        'enrollment_status': newStatus,
        'criteria_met': _criteriaMet,
        'verification_notes': _verificationNotes,
        'rejection_reason': _rejectionReason,
      });
      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.userRole;
    
    // Determine what actions this user can take
    final canScreen = userRole == UserRole.socialWorker || userRole == UserRole.superAdmin;
    final canVerify = userRole == UserRole.socialWorker || userRole == UserRole.superAdmin;
    final canApprove = userRole == UserRole.orphanageDirector || userRole == UserRole.superAdmin;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrollment Approval - ${widget.childName}'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Status Card
                  Card(
                    color: _getStatusColor(_currentStatus).withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(_getStatusIcon(_currentStatus), color: _getStatusColor(_currentStatus), size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Status', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      _getStatusDisplay(_currentStatus),
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(_currentStatus)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _getStatusProgress(_currentStatus),
                            backgroundColor: Colors.grey.shade200,
                            color: _getStatusColor(_currentStatus),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Enrollment Criteria Checklist
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enrollment Criteria Checklist',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'At least 2 criteria must be met for approval',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Divider(),
                          ..._criteria.map((criterion) => CheckboxListTile(
                            title: Text(criterion['title'], style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(criterion['description']),
                            value: _criteriaMet.contains(criterion['id']),
                            onChanged: (canScreen || canVerify) ? (value) {
                              setState(() {
                                if (value == true) {
                                  _criteriaMet.add(criterion['id']);
                                } else {
                                  _criteriaMet.remove(criterion['id']);
                                }
                              });
                            } : null,
                            secondary: IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.blue),
                              onPressed: () {
                                _showVerificationDialog(criterion);
                              },
                            ),
                          )),
                          
                          SizedBox(height: 16),
                          
                          // Criteria met count
                          Text(
                            'Criteria Met: ${_criteriaMet.length}/5 (Minimum 2 required)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _criteriaMet.length >= 2 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Verification Notes
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verification Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue: _verificationNotes,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add verification notes, document references, etc.',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _verificationNotes = value,
                            enabled: canScreen || canVerify,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Action Buttons based on role and current status
                  if (canScreen && _currentStatus == 'INITIATED')
                    _buildActionButton('Start Screening', Colors.orange, () => _updateStatus('SCREENING')),
                  
                  if (canVerify && _currentStatus == 'SCREENING')
                    _buildActionButton('Verify & Recommend', Colors.blue, () {
                      if (_criteriaMet.length >= 2) {
                        _updateStatus('VERIFIED');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('At least 2 criteria must be met'), backgroundColor: Colors.red),
                        );
                      }
                    }),
                  
                  if (canApprove && _currentStatus == 'VERIFIED')
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton('Approve Enrollment', Colors.green, () => _updateStatus('APPROVED'), isOutlined: false),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton('Reject', Colors.red, () => _showRejectionDialog(), isOutlined: true),
                        ),
                      ],
                    ),
                  
                  if (canApprove && _currentStatus == 'APPROVED')
                    _buildActionButton('Mark as Enrolled', Colors.teal, () => _updateStatus('ENROLLED')),
                  
                  if ((canScreen || canVerify || canApprove) && _currentStatus == 'REJECTED')
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text('Rejection Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(_rejectionReason),
                          ],
                        ),
                      ),
                    ),
                  
                  // Status Timeline
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Approval Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Divider(),
                          _buildTimelineItem('Initiated', _currentStatus, Icons.edit),
                          _buildTimelineItem('Screening', _currentStatus, Icons.assignment),
                          _buildTimelineItem('Verified', _currentStatus, Icons.verified),
                          _buildTimelineItem('Approved', _currentStatus, Icons.check_circle),
                          _buildTimelineItem('Enrolled', _currentStatus, Icons.people),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildActionButton(String text, Color color, VoidCallback onPressed, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: Text(text),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: color),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
    );
  }
  
  void _showVerificationDialog(Map<String, dynamic> criterion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(criterion['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(criterion['description']),
            SizedBox(height: 12),
            Text('Required Verification:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(criterion['verification']),
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
  
  void _showRejectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Enrollment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              setState(() => _rejectionReason = controller.text);
              Navigator.pop(context);
              _updateStatus('REJECTED');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem(String step, String currentStatus, IconData icon) {
    final isCompleted = _getStatusProgress(currentStatus) >= _getStepProgress(step);
    final isCurrent = _getStatusDisplay(currentStatus) == step;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                if (isCurrent)
                  Text('Current step', style: TextStyle(fontSize: 11, color: Colors.blue)),
              ],
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
  
  double _getStepProgress(String step) {
    switch(step) {
      case 'Initiated': return 0.2;
      case 'Screening': return 0.4;
      case 'Verified': return 0.6;
      case 'Approved': return 0.8;
      case 'Enrolled': return 1.0;
      default: return 0;
    }
  }
  
  double _getStatusProgress(String status) {
    switch(status) {
      case 'INITIATED': return 0.2;
      case 'SCREENING': return 0.4;
      case 'VERIFIED': return 0.6;
      case 'APPROVED': return 0.8;
      case 'ENROLLED': return 1.0;
      case 'PLACED': return 1.0;
      default: return 0;
    }
  }
  
  Color _getStatusColor(String status) {
    switch(status) {
      case 'INITIATED': return Colors.orange;
      case 'SCREENING': return Colors.blue;
      case 'VERIFIED': return Colors.teal;
      case 'APPROVED': return Colors.green;
      case 'ENROLLED': return Colors.indigo;
      case 'PLACED': return Colors.purple;
      case 'REJECTED': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch(status) {
      case 'INITIATED': return Icons.pending;
      case 'SCREENING': return Icons.assignment;
      case 'VERIFIED': return Icons.verified;
      case 'APPROVED': return Icons.check_circle;
      case 'ENROLLED': return Icons.people;
      case 'PLACED': return Icons.home;
      case 'REJECTED': return Icons.cancel;
      default: return Icons.help;
    }
  }
  
  String _getStatusDisplay(String status) {
    switch(status) {
      case 'INITIATED': return 'Initiated';
      case 'SCREENING': return 'Screening';
      case 'VERIFIED': return 'Verified';
      case 'APPROVED': return 'Approved';
      case 'ENROLLED': return 'Enrolled';
      case 'PLACED': return 'Placed';
      case 'REJECTED': return 'Rejected';
      default: return status;
    }
  }
}