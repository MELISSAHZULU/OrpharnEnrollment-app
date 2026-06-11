import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role_permissions.dart';
import 'common/unauthorized_screen.dart';
import 'common/profile_screen.dart';

// Existing screens
import 'dashboard/dashboard_screen.dart';
import 'children/children_list_screen.dart';
import 'children/enroll_child_screen.dart';
import 'resources/bed_screen.dart';
import 'transport/transport_request_screen.dart';
import 'notifications/notifications_screen.dart';
import 'healthcare/healthcare_dashboard.dart';
import 'staff/staff_list_screen.dart';

// Simple placeholder for orphanage screen
class OrphanageListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orphanages'), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Orphanage Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Coming Soon'),
          ],
        ),
      ),
    );
  }
}

// Simple placeholders for role-specific dashboards
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class DirectorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class SocialWorkerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class VillageHeadDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class DonorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class GovernmentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.userRole;
    
    final navItems = _getNavigationItems(userRole);
    final screens = _getScreensForRole(userRole);
    
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppTitle(userRole)),
        centerTitle: true,
        backgroundColor: _getRoleColor(userRole),
        actions: [
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
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              } else if (value == 'logout') {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [Icon(Icons.account_circle), SizedBox(width: 12), Text('My Profile')]),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 12), Text('Logout', style: TextStyle(color: Colors.red))]),
              ),
            ],
          ),
        ],
      ),
      body: screens.isNotEmpty ? screens[_selectedIndex] : UnauthorizedScreen(),
      bottomNavigationBar: navItems.isNotEmpty
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              items: navItems,
              selectedItemColor: _getRoleColor(userRole),
              unselectedItemColor: Colors.grey,
            )
          : null,
    );
  }
  
  List<BottomNavigationBarItem> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.healthcareWorker:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Medical'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Enroll'),
          BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Beds'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.orphanageDirector:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Beds'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      default:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
    }
  }
  
  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [DashboardScreen(), ChildrenListScreen(), OrphanageListScreen(), StaffListScreen(), NotificationsScreen()];
      case UserRole.healthcareWorker:
        return [HealthcareDashboard(), ChildrenListScreen(), EnrollChildScreen(), BedScreen(), NotificationsScreen()];
      case UserRole.orphanageDirector:
        return [DashboardScreen(), ChildrenListScreen(), StaffListScreen(), BedScreen(), NotificationsScreen()];
      default:
        return [DashboardScreen(), ChildrenListScreen(), NotificationsScreen()];
    }
  }
  
  String _getAppTitle(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'Admin Portal';
      case UserRole.healthcareWorker: return 'Healthcare Portal';
      case UserRole.orphanageDirector: return 'Orphanage Portal';
      default: return 'Orphan Enrollment System';
    }
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return Colors.purple;
      case UserRole.healthcareWorker: return Colors.teal;
      case UserRole.orphanageDirector: return Colors.blue;
      default: return Colors.blue;
    }
  }
}