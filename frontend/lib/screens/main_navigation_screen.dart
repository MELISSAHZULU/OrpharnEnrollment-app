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
import 'orphanages/orphanage_list_screen.dart';
import 'government/government_dashboard.dart';

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
        actions: _getAppBarActions(userRole, authProvider, context),
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
      floatingActionButton: _getFloatingActionButton(userRole, context),
    );
  }
  
  List<Widget> _getAppBarActions(UserRole role, AuthProvider authProvider, BuildContext context) {
    List<Widget> actions = [];
    
    // Transport Request Button - Only for roles that need transport
    if (role == UserRole.healthcareWorker || 
        role == UserRole.socialWorker || 
        role == UserRole.orphanageStaff ||
        role == UserRole.orphanageDirector) {
      actions.add(
        IconButton(
          icon: Icon(Icons.directions_car),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TransportRequestScreen()));
          },
          tooltip: 'Request Transport',
        ),
      );
    }
    
    // Enroll Child Button - Not for viewers or donors
    if (role != UserRole.viewer && role != UserRole.donor && role != UserRole.governmentOfficial) {
      actions.add(
        IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EnrollChildScreen()));
          },
          tooltip: 'Enroll Child',
        ),
      );
    }
    
    // Profile Menu (only profile, no logout here)
    actions.add(
      PopupMenuButton<String>(
        icon: Icon(Icons.person),
        onSelected: (value) async {
          if (value == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.account_circle),
                SizedBox(width: 12),
                Text('My Profile'),
              ],
            ),
          ),
        ],
      ),
    );
    
    return actions;
  }
  
  List<BottomNavigationBarItem> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Staff'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.healthcareWorker:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Medical'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Beds'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.orphanageDirector:
      case UserRole.orphanageStaff:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Staff'),
          const BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Beds'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.socialWorker:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Cases'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.villageHead:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Village'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Reports'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.donor:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Sponsors'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ];
      case UserRole.governmentOfficial:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          const BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
       ];
      case UserRole.viewer:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'View'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
          const BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orphanages'),
        ];
      default:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Children'),
        ];
    }
  }
  
  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [DashboardScreen(), ChildrenListScreen(), OrphanageListScreen(), StaffListScreen(), NotificationsScreen()];
      case UserRole.healthcareWorker:
        return [HealthcareDashboard(), ChildrenListScreen(), BedScreen(), NotificationsScreen()];
      case UserRole.orphanageDirector:
      case UserRole.orphanageStaff:
        return [DashboardScreen(), ChildrenListScreen(), StaffListScreen(), BedScreen(), NotificationsScreen()];
      case UserRole.socialWorker:
        return [DashboardScreen(), ChildrenListScreen(), NotificationsScreen()];
      case UserRole.villageHead:
        return [DashboardScreen(), ChildrenListScreen(), NotificationsScreen()];
      case UserRole.donor:
        return [DashboardScreen(), ChildrenListScreen(), NotificationsScreen()];
      case UserRole.governmentOfficial:
        return [GovernmentDashboard(), OrphanageListScreen(), DashboardScreen(), NotificationsScreen()];
      case UserRole.viewer:
        return [DashboardScreen(), ChildrenListScreen(), OrphanageListScreen()];
      default:
        return [DashboardScreen(), ChildrenListScreen()];
    }
  }
  
  Widget? _getFloatingActionButton(UserRole role, BuildContext context) {
    switch (role) {
      case UserRole.healthcareWorker:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EnrollChildScreen()));
          },
          icon: Icon(Icons.emergency),
          label: Text('Emergency'),
          backgroundColor: Colors.red,
        );
      case UserRole.orphanageDirector:
      case UserRole.orphanageStaff:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EnrollChildScreen()));
          },
          icon: Icon(Icons.add),
          label: Text('Enroll'),
          backgroundColor: Colors.green,
        );
      case UserRole.socialWorker:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EnrollChildScreen()));
          },
          icon: Icon(Icons.person_add),
          label: Text('New Case'),
          backgroundColor: Colors.blue,
        );
      default:
        return null;
    }
  }
  
  String _getAppTitle(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Admin Portal';
      case UserRole.healthcareWorker:
        return 'Healthcare Portal';
      case UserRole.orphanageDirector:
        return 'Director Portal';
      case UserRole.orphanageStaff:
        return 'Staff Portal';
      case UserRole.socialWorker:
        return 'Social Services';
      case UserRole.villageHead:
        return 'Village Portal';
      case UserRole.donor:
        return 'Sponsor Portal';
      case UserRole.governmentOfficial:
        return 'Government Portal';
      case UserRole.viewer:
        return 'Viewer Portal';
      default:
        return 'Orphan Enrollment System';
    }
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.healthcareWorker:
        return Colors.teal;
      case UserRole.orphanageDirector:
        return Colors.blue;
      case UserRole.orphanageStaff:
        return Colors.lightBlue;
      case UserRole.socialWorker:
        return Colors.green;
      case UserRole.villageHead:
        return Colors.orange;
      case UserRole.donor:
        return Colors.pink;
      case UserRole.governmentOfficial:
        return Colors.indigo;
      case UserRole.viewer:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}