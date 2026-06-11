import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'children/children_list_screen.dart';
import 'children/enroll_child_screen.dart';
import 'resources/bed_screen.dart';
import 'staff/staff_list_screen.dart';
import 'orphanages/orphanage_list_screen.dart';
import 'notifications/notifications_screen.dart';
import 'transport/transport_request_screen.dart';
import 'profile/user_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    ChildrenListScreen(),
    StaffListScreen(),
    OrphanageListScreen(),
    BedScreen(),
    NotificationsScreen(),
  ];
  
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
    BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Staff'),
    BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
    BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Beds'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
  ];
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Orphan Enrollment System'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          // Transport Request Button
          IconButton(
            icon: Icon(Icons.directions_car),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportRequestScreen()),
              );
            },
            tooltip: 'Request Transport',
          ),
          // Enroll Child Button
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnrollChildScreen()),
              );
            },
            tooltip: 'Enroll Child',
          ),
          // User Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              } else if (value == 'logout') {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.account_circle),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnrollChildScreen()),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Quick Enroll'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}