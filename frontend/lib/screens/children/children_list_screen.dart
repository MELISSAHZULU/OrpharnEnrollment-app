import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'child_detail_screen.dart';

class ChildrenListScreen extends StatefulWidget {
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
        title: Text('Enrolled Children'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadChildren,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChildren,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No children enrolled yet'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadChildren,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        
                        // SAFE: Get first_name and last_name with null checks
                        final firstName = child['first_name'] ?? '';
                        final lastName = child['last_name'] ?? '';
                        final fullName = '$firstName $lastName'.trim();
                        
                        // SAFE: Get initial for avatar
                        String initial = '?';
                        if (fullName.isNotEmpty) {
                          initial = fullName[0].toUpperCase();
                        } else if (firstName.isNotEmpty) {
                          initial = firstName[0].toUpperCase();
                        } else if (lastName.isNotEmpty) {
                          initial = lastName[0].toUpperCase();
                        }
                        
                        // SAFE: Get age and village with fallbacks
                        final age = child['age']?.toString() ?? '?';
                        final village = child['village'] ?? 'Unknown';
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                initial,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(fullName.isEmpty ? 'Unnamed Child' : fullName),
                            subtitle: Text('Age: $age | $village'),
                            trailing: Chip(
                              label: Text(child['status'] ?? 'PENDING'),
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