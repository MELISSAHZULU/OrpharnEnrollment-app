import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../children/child_detail_screen.dart';
import '../children/enroll_child_screen.dart';

class SocialWorkerDashboard extends StatefulWidget {
  const SocialWorkerDashboard({super.key});

  @override
  State<SocialWorkerDashboard> createState() => _SocialWorkerDashboardState();
}

class _SocialWorkerDashboardState extends State<SocialWorkerDashboard> {
  final ApiService _apiService = ApiService();
  List<dynamic> _activeCases = [];
  List<Map<String, dynamic>> _caseNotes = [];
  bool _isLoading = true;
  int? _selectedChildId;
  String? _selectedChildName;
  
  final TextEditingController _noteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load children
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      
      setState(() {
        _activeCases = childrenList.toList();
        _isLoading = false;
      });
      
      // Load case notes if a child is selected
      if (_selectedChildId != null) {
        await _loadCaseNotes();
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadCaseNotes() async {
    if (_selectedChildId == null) return;
    
    try {
      final notes = await _apiService.getCaseNotes(childId: _selectedChildId);
      setState(() {
        _caseNotes = notes is List ? List<Map<String, dynamic>>.from(notes) : [];
      });
    } catch (e) {
      print('Error loading case notes: $e');
      setState(() {
        _caseNotes = [];
      });
    }
  }
  
  Future<void> _addCaseNote() async {
    if (_noteController.text.isNotEmpty && _selectedChildId != null) {
      try {
        await _apiService.addCaseNote(_selectedChildId!, _noteController.text);
        _noteController.clear();
        await _loadCaseNotes();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case note added!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _selectChild(dynamic child) {
    final firstName = child['first_name'] ?? '';
    final lastName = child['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    setState(() {
      _selectedChildId = child['id'];
      _selectedChildName = fullName.isEmpty ? 'Unnamed Child' : fullName;
    });
    _loadCaseNotes();
  }
  
  void _navigateToChild(dynamic child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailScreen(
          childId: child['id'],
          child: child,
        ),
      ),
    ).then((_) => _loadData());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Services'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4C1D95),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Cases Section
                  _buildActiveCasesSection(),
                  const SizedBox(height: 16),
                  
                  // Case Notes Section
                  _buildCaseNotesSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnrollChildScreen()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.person_add),
        backgroundColor: const Color(0xFF7C3AED),
      ),
    );
  }
  
  Widget _buildActiveCasesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              const Text(
                'Active Cases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Text(
                '${_activeCases.length} cases',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(),
          if (_activeCases.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No active cases')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeCases.length,
              itemBuilder: (context, index) {
                final child = _activeCases[index];
                final firstName = child['first_name'] ?? '';
                final lastName = child['last_name'] ?? '';
                final fullName = '$firstName $lastName'.trim();
                final status = child['status'] ?? 'PENDING';
                final village = child['village'] ?? 'Unknown';
                final isSelected = _selectedChildId == child['id'];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      fullName.isEmpty ? 'Unnamed Child' : fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                    ),
                    subtitle: Text(
                      'Status: $status | Village: $village',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSelected)
                          TextButton(
                            onPressed: () => _selectChild(child),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF7C3AED),
                            ),
                            child: const Text('Select'),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          color: const Color(0xFF7C3AED),
                          onPressed: () => _navigateToChild(child),
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildCaseNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              const Text(
                'Case Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const Divider(),
          
          // Selected case display
          if (_selectedChildId == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Select a case from above to view/add notes'),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Case: $_selectedChildName',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedChildId = null;
                        _selectedChildName = null;
                        _caseNotes = [];
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                    ),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Add note section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add case note for $_selectedChildName...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF7C3AED),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addCaseNote,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Case notes list
            if (_caseNotes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No case notes yet')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _caseNotes.length,
                itemBuilder: (context, index) {
                  final note = _caseNotes[index];
                  final date = note['created_at']?.toString().split('T')[0] ?? 'Unknown';
                  final author = note['author_name'] ?? 'Unknown';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                        child: Icon(Icons.note, color: const Color(0xFF7C3AED)),
                      ),
                      title: Text(note['note'], style: const TextStyle(color: Color(0xFF1F2937))),
                      subtitle: Text('$author - $date', style: TextStyle(color: Colors.grey[600])),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}