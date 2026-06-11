import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/role_permissions.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final role = authProvider.userRole;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: _getRoleColor(role),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: _getRoleColor(role).withOpacity(0.2),
              child: Icon(
                _getRoleIcon(role),
                size: 60,
                color: _getRoleColor(role),
              ),
            ),
            SizedBox(height: 16),
            Text(
              user?.fullName ?? 'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role.displayName,
                style: TextStyle(color: _getRoleColor(role)),
              ),
            ),
            SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', user?.email ?? 'Not set'),
                    _buildInfoRow(Icons.phone, 'Phone', user?.phoneNumber ?? 'Not set'),
                    _buildInfoRow(Icons.business, 'Orphanage', user?.orphanageName ?? 'Not assigned'),
                    _buildInfoRow(Icons.people, 'Role', role.displayName),
                  ],
                ),
              ),
            ),
            
            // Show permissions summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Access Level',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    _buildPermissionTile('Add Orphanage', RolePermissions.canAddOrphanage(role)),
                    _buildPermissionTile('Edit Orphanage', RolePermissions.canEditOrphanage(role)),
                    _buildPermissionTile('View All Orphanages', RolePermissions.canViewAllOrphanages(role)),
                    _buildPermissionTile('Manage Staff', role == UserRole.orphanageDirector || role == UserRole.superAdmin),
                    _buildPermissionTile('Enroll Children', role != UserRole.viewer && role != UserRole.donor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
  
  Widget _buildPermissionTile(String permission, bool hasAccess) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasAccess ? Icons.check_circle : Icons.cancel,
            color: hasAccess ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(permission),
        ],
      ),
    );
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.orphanageDirector:
        return Colors.blue;
      case UserRole.orphanageStaff:
        return Colors.lightBlue;
      case UserRole.socialWorker:
        return Colors.green;
      case UserRole.healthcareWorker:
        return Colors.teal;
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
  
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.orphanageDirector:
        return Icons.business;
      case UserRole.orphanageStaff:
        return Icons.people_outline;
      case UserRole.socialWorker:
        return Icons.people;
      case UserRole.healthcareWorker:
        return Icons.medical_services;
      case UserRole.villageHead:
        return Icons.location_city;
      case UserRole.donor:
        return Icons.favorite;
      case UserRole.governmentOfficial:
        return Icons.account_balance;
      case UserRole.viewer:
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }
}