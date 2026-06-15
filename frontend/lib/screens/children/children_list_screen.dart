import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'child_detail_screen.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
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
      setState(() {
        _children = children is List ? children : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading children: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _children = [];
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Children'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4C1D95),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChildren,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _children.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No children enrolled yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        final firstName = child['first_name'] ?? '';
                        final lastName = child['last_name'] ?? '';
                        final fullName = '$firstName $lastName'.trim();
                        final age = child['age']?.toString() ?? '?';
                        final village = child['village'] ?? 'Unknown';
                        final status = child['status'] ?? 'PENDING';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF7C3AED),
                              child: Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(fullName.isEmpty ? 'Unnamed Child' : fullName, style: const TextStyle(color: Color(0xFF1F2937))),
                            subtitle: Text('Age: $age | $village'),
                            trailing: Chip(
                              label: Text(status),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            onTap: () {
                              if (child['id'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildDetailScreen(
                                      childId: child['id'],
                                      child: child,
                                    ),
                                  ),
                                ).then((_) => _loadChildren());
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}