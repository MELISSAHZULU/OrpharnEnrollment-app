import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/role_permissions.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final role = authProvider.userRole;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4C1D95),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4C1D95)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Avatar
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFFC084FC)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.2),
                      child: Icon(
                        _getRoleIcon(role),
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Profile Information Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          const Divider(),
                          _buildInfoRow(Icons.person, 'Username', user?.username ?? 'N/A'),
                          _buildInfoRow(Icons.email, 'Email', user?.email ?? 'Not set'),
                          _buildInfoRow(Icons.phone, 'Phone', user?.phoneNumber ?? 'Not set'),
                          _buildInfoRow(Icons.business, 'Organization', user?.orphanageName ?? 'System'),
                          _buildInfoRow(Icons.calendar_today, 'Member Since', '2024'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Permissions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Permissions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          const Divider(),
                          ..._getPermissionsForRole(role).take(6).map(
                            (permission) => _buildPermissionTile(permission),
                          ),
                          if (_getPermissionsForRole(role).length > 6)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '+ ${_getPermissionsForRole(role).length - 6} more permissions',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Actions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: Color(0xFF7C3AED)),
                          title: const Text('Change Password', style: TextStyle(color: Color(0xFF1F2937))),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                          onTap: () => _showChangePasswordDialog(context, authProvider),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip, color: Color(0xFF7C3AED)),
                          title: const Text('Privacy Policy', style: TextStyle(color: Color(0xFF1F2937))),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help_outline, color: Color(0xFF7C3AED)),
                          title: const Text('Help & Support', style: TextStyle(color: Color(0xFF1F2937))),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
                          onTap: () => _showHelp(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.red),
                          onTap: () => _showLogoutDialog(context, authProvider),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App Version
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionTile(String permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          Text(permission, style: const TextStyle(color: Color(0xFF4B5563))),
        ],
      ),
    );
  }
  
  List<String> _getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [
          'View all children', 'Edit all children', 'Delete children',
          'Manage users', 'Manage orphanages', 'Manage staff',
          'View reports', 'System settings', 'Audit logs',
        ];
      case UserRole.orphanageDirector:
        return [
          'View orphanage', 'Edit orphanage', 'Manage staff',
          'Enroll children', 'Edit children', 'Manage beds',
          'Approve transport', 'View reports',
        ];
      case UserRole.orphanageStaff:
        return [
          'View orphanage', 'Enroll children', 'Edit children',
          'View beds', 'Request transport', 'View staff',
        ];
      case UserRole.healthcareWorker:
        return [
          'Emergency enrollment', 'View medical records', 'Add medical records',
          'Track vaccinations', 'Request transport', 'View health reports',
        ];
      case UserRole.socialWorker:
        return [
          'Enroll children', 'Edit assigned children', 'Add case notes',
          'Family tracing', 'Request transport', 'View medical records',
        ];
      case UserRole.villageHead:
        return [
          'Report orphans', 'View village reports', 'Send emergency alerts',
        ];
      case UserRole.donor:
        return [
          'View sponsored children', 'Sponsor children', 'View donation history',
          'Download receipts', 'Send messages',
        ];
      case UserRole.governmentOfficial:
        return [
          'View all orphanages', 'View statistics', 'Generate compliance reports',
          'Export data', 'Audit orphanages',
        ];
      case UserRole.viewer:
        return [
          'View children (read only)', 'View orphanages (read only)',
        ];
      default:
        return [];
    }
  }
  
  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
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
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                );
                return;
              }
              try {
                // Add API call here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'We value your privacy. This app collects information about orphans '
            'and staff for management purposes only. Your data is protected and '
            'not shared with third parties without consent.',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('For support, contact:'),
            const SizedBox(height: 8),
            const Text('📧 support@orphanage.mw'),
            const Text('📞 +265 123 456 789'),
            const SizedBox(height: 8),
            const Text('Working Hours: Mon-Fri, 8am-5pm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.healthcareWorker:
        return const Color(0xFF7C3AED);
      case UserRole.orphanageDirector:
        return const Color(0xFF7C3AED);
      case UserRole.orphanageStaff:
        return const Color(0xFF7C3AED);
      case UserRole.socialWorker:
        return const Color(0xFF7C3AED);
      case UserRole.villageHead:
        return const Color(0xFF7C3AED);
      case UserRole.donor:
        return const Color(0xFF7C3AED);
      case UserRole.governmentOfficial:
        return const Color(0xFF7C3AED);
      case UserRole.viewer:
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF7C3AED);
    }
  }
  
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.healthcareWorker:
        return Icons.medical_services;
      case UserRole.orphanageDirector:
        return Icons.business;
      case UserRole.orphanageStaff:
        return Icons.people_outline;
      case UserRole.socialWorker:
        return Icons.people;
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