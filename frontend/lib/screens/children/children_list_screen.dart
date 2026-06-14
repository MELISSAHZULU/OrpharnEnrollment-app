import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'child_detail_screen.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  _ChildrenListScreenState createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _children = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadChildren();
  }
  
  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final children = await _apiService.getChildren();
      if (mounted) {
        setState(() {
          _children = children is List ? children : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading children: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _children = [];
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChildren,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_children.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No children enrolled yet'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Children'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          
          // SAFE extraction with null checks
          final firstName = child['first_name']?.toString() ?? '';
          final lastName = child['last_name']?.toString() ?? '';
          final fullName = '$firstName $lastName'.trim();
          final age = child['age']?.toString() ?? '?';
          final village = child['village']?.toString() ?? 'Unknown';
          final status = child['status']?.toString() ?? 'PENDING';
          
          // Get child ID - ensure it's an int
          final childId = child['id'];
          final intId = childId is int ? childId : int.tryParse(childId.toString()) ?? 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(fullName.isEmpty ? 'Unnamed Child' : fullName),
              subtitle: Text('Age: $age | $village'),
              trailing: Chip(
                label: Text(status),
                backgroundColor: Colors.grey.shade200,
              ),
              onTap: () {
                // Ensure we have a valid ID before navigating
                if (intId > 0) {
                  // Create a clean map with proper types
                  final cleanChild = {
                    'id': intId,
                    'first_name': firstName,
                    'last_name': lastName,
                    'age': age,
                    'village': village,
                    'district': child['district']?.toString() ?? '',
                    'status': status,
                    'enrollment_date': child['enrollment_date']?.toString() ?? '',
                    'reason_for_care': child['reason_for_care']?.toString() ?? '',
                    'guardian_name': child['guardian_name']?.toString(),
                    'guardian_contact': child['guardian_contact']?.toString(),
                    'gender': child['gender']?.toString() ?? 'U',
                  };
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildDetailScreen(
                        childId: intId,
                        child: cleanChild,
                      ),
                    ),
                  ).then((_) => _loadChildren());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid child ID'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}