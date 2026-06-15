import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EnrollmentManagementScreen extends StatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  State<EnrollmentManagementScreen> createState() => _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState extends State<EnrollmentManagementScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingEnrollments = [];
  List<dynamic> _emergencyEnrollments = [];
  List<dynamic> _approvedEnrollments = [];
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _loadEnrollments();
    _loadRooms();
  }
  
  Future<void> _loadRooms() async {
    try {
      final rooms = await _apiService.getRooms();
      setState(() {
        _rooms = rooms is List ? rooms : [];
      });
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }
  
  Future<void> _loadEnrollments() async {
    setState(() => _isLoading = true);
    try {
      final children = await _apiService.getChildren();
      final childrenList = children is List ? children : [];
      
      setState(() {
        _pendingEnrollments = childrenList.where((c) => 
          c['status'] == 'PENDING' || c['status'] == 'INITIATED'
        ).toList();
        
        _emergencyEnrollments = childrenList.where((c) => 
          c['status'] == 'EMERGENCY'
        ).toList();
        
        _approvedEnrollments = childrenList.where((c) => 
          c['status'] == 'APPROVED' || c['status'] == 'ENROLLED' || c['status'] == 'PLACED'
        ).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading enrollments: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateStatus(dynamic child, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateChild(child['id'], {'status': newStatus});
      await _loadEnrollments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child status updated to $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }
  
  void _showAssignRoomDialog(dynamic child) async {
    await _loadRooms();
    
    String? selectedRoomId;
    String? selectedBedId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Place ${child['first_name']} ${child['last_name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Room/Hostel:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_rooms.isEmpty)
                  const Text('No rooms available. Please add rooms first.')
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        final roomName = room['name'] ?? 'Unknown Room';
                        final totalBeds = room['total_beds'] ?? 0;
                        final occupiedBeds = room['occupied_beds'] ?? 0;
                        final availableBeds = totalBeds - occupiedBeds;
                        final isSelected = selectedRoomId == room['id'].toString();
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : null,
                          child: RadioListTile<String>(
                            title: Text(
                              roomName,
                              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text('Beds: $occupiedBeds/$totalBeds occupied (${availableBeds} available)'),
                            value: room['id'].toString(),
                            groupValue: selectedRoomId,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedRoomId = value;
                                selectedBedId = null;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                
                if (selectedRoomId != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Select Bed Number (Optional):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter bed number (e.g., Bed 1, 2A, etc.)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bed),
                    ),
                    onChanged: (value) => selectedBedId = value,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedRoomId != null
                  ? () async {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      try {
                        await _apiService.updateChild(child['id'], {
                          'status': 'PLACED',
                          'assigned_room': selectedRoomId,
                          'assigned_bed': selectedBedId ?? '',
                          'placement_date': DateTime.now().toIso8601String(),
                        });
                        
                        await _apiService.updateRoomOccupancy(int.parse(selectedRoomId!));
                        await _loadEnrollments();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Child placed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                        setState(() => _isLoading = false);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
              child: const Text('Place Child'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enrollment Management'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4C1D95),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending), text: 'Pending'),
              Tab(icon: Icon(Icons.emergency), text: 'Emergency'),
              Tab(icon: Icon(Icons.check_circle), text: 'Placed'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildEnrollmentList(_pendingEnrollments, 'pending'),
                  _buildEnrollmentList(_emergencyEnrollments, 'emergency'),
                  _buildPlacedList(_approvedEnrollments),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddRoomDialog(),
          child: const Icon(Icons.add),
          backgroundColor: const Color(0xFF7C3AED),
          tooltip: 'Add Room/Hostel',
        ),
      ),
    );
  }
  
  Widget _buildEnrollmentList(List<dynamic> enrollments, String type) {
    if (enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No $type enrollments'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final child = enrollments[index];
        final firstName = child['first_name'] ?? '';
        final lastName = child['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final age = child['age'] ?? '?';
        final village = child['village'] ?? 'Unknown';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: type == 'emergency' ? Colors.red : const Color(0xFF7C3AED),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'Unnamed Child' : fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          Text('Age: $age | Village: $village', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(child['status'] ?? 'UNKNOWN'),
                            backgroundColor: type == 'emergency' ? Colors.red.withOpacity(0.2) : const Color(0xFF7C3AED).withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (type != 'emergency')
                      ElevatedButton(
                        onPressed: () => _updateStatus(child, 'APPROVED'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                        child: const Text('Approve'),
                      ),
                    if (type == 'emergency')
                      ElevatedButton(
                        onPressed: () => _showAssignRoomDialog(child),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                        child: const Text('Place Now'),
                      ),
                    const SizedBox(width: 8),
                    if (type != 'emergency')
                      ElevatedButton(
                        onPressed: () => _updateStatus(child, 'REJECTED'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPlacedList(List<dynamic> placements) {
    if (placements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No children placed yet'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: placements.length,
      itemBuilder: (context, index) {
        final child = placements[index];
        final firstName = child['first_name'] ?? '';
        final lastName = child['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final age = child['age'] ?? '?';
        final assignedRoom = child['assigned_room'];
        final assignedBed = child['assigned_bed'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF7C3AED),
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'Unnamed Child' : fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          Text('Age: $age', style: TextStyle(color: Colors.grey[600])),
                          if (assignedRoom != null)
                            Text('Room: ${_getRoomName(int.parse(assignedRoom.toString()))}', style: TextStyle(color: Colors.grey[600])),
                          if (assignedBed != null && assignedBed.toString().isNotEmpty)
                            Text('Bed: $assignedBed', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _getRoomName(int roomId) {
    final room = _rooms.firstWhere(
      (r) => r['id'] == roomId,
      orElse: () => {'name': 'Unknown'},
    );
    return room['name'] ?? 'Unknown Room';
  }
  
  void _showAddRoomDialog() {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Room/Hostel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room/Hostel Name',
                hintText: 'e.g., Boys Dorm, Girls Dorm, Infants Room',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (Number of Beds)',
                hintText: 'e.g., 20',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && capacityController.text.isNotEmpty) {
                await _apiService.addRoom({
                  'name': nameController.text,
                  'total_beds': int.parse(capacityController.text),
                  'occupied_beds': 0,
                });
                Navigator.pop(context);
                _loadRooms();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room added!'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}