import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    try {
      final notifications = await _apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['message']),
                    trailing: notification['is_read'] 
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.circle, color: Colors.blue, size: 12),
                  ),
                );
              },
            ),
    );
  }
}