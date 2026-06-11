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
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrolled Children'),
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
              ? Center(child: Text('Error: $_error'))
              : _children.isEmpty
                  ? Center(child: Text('No children enrolled yet'))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${child['first_name'][0]}${child['last_name'][0]}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('${child['first_name']} ${child['last_name']}'),
                            subtitle: Text(
                              'Age: ${child['age']} | ${child['village']}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildDetailScreen(
                                    childId: child['id'],
                                    child: child,
                                  ),
                                ),
                              ).then((_) => _loadChildren());
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}