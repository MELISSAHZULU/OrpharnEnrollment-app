enum UserRole {
  superAdmin,
  orphanageDirector,
  orphanageStaff,
  socialWorker,
  healthcareWorker,
  villageHead,
  donor,
  governmentOfficial,
  viewer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'System Administrator';
      case UserRole.orphanageDirector:
        return 'Orphanage Director';
      case UserRole.orphanageStaff:
        return 'Orphanage Staff';
      case UserRole.socialWorker:
        return 'Social Worker';
      case UserRole.healthcareWorker:
        return 'Healthcare Worker';
      case UserRole.villageHead:
        return 'Village Head';
      case UserRole.donor:
        return 'Donor / Sponsor';
      case UserRole.governmentOfficial:
        return 'Government Official';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
  
  String get code {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.orphanageDirector:
        return 'orphanage_director';
      case UserRole.orphanageStaff:
        return 'orphanage_staff';
      case UserRole.socialWorker:
        return 'social_worker';
      case UserRole.healthcareWorker:
        return 'healthcare_worker';
      case UserRole.villageHead:
        return 'village_head';
      case UserRole.donor:
        return 'donor';
      case UserRole.governmentOfficial:
        return 'government_official';
      case UserRole.viewer:
        return 'viewer';
    }
  }
  
  static UserRole fromCode(String code) {
    switch (code) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'orphanage_director':
        return UserRole.orphanageDirector;
      case 'orphanage_staff':
        return UserRole.orphanageStaff;
      case 'social_worker':
        return UserRole.socialWorker;
      case 'healthcare_worker':
        return UserRole.healthcareWorker;
      case 'village_head':
        return UserRole.villageHead;
      case 'donor':
        return UserRole.donor;
      case 'government_official':
        return UserRole.governmentOfficial;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer;
    }
  }
}

class RolePermissions {
  static const Map<UserRole, List<String>> permissions = {
    UserRole.superAdmin: [
      'view_all', 'edit_all', 'delete_all',
      'manage_users', 'manage_orphanages', 'manage_staff',
      'view_reports', 'system_settings',
    ],
    
    UserRole.orphanageDirector: [
      'view_orphanage', 'edit_orphanage',
      'manage_orphanage_staff', 'view_orphanage_children',
      'enroll_children', 'edit_orphanage_children',
      'manage_beds', 'approve_transport',
      'view_orphanage_reports',
    ],
    
    UserRole.orphanageStaff: [
      'view_orphanage', 'view_orphanage_children',
      'enroll_children', 'edit_orphanage_children',
      'view_beds', 'request_transport',
      'view_staff',
    ],
    
    UserRole.socialWorker: [
      'enroll_children', 'edit_assigned_children',
      'view_assigned_children', 'add_case_notes',
      'family_tracing', 'request_transport',
      'view_medical_records',
    ],
    
    UserRole.healthcareWorker: [
      'enroll_children', 'emergency_enrollment',
      'view_medical_records', 'add_medical_records',
      'track_vaccinations', 'record_checkups',
      'request_immediate_transport',
    ],
    
    UserRole.villageHead: [
      'report_orphans', 'view_village_reports',
      'track_reported_cases', 'send_emergency_alerts',
    ],
    
    UserRole.donor: [
      'view_sponsored_children', 'sponsor_children',
      'view_donation_history', 'download_receipts',
    ],
    
    UserRole.governmentOfficial: [
      'view_all_orphanages_readonly', 'view_statistics',
      'generate_compliance_reports', 'export_anonymized_data',
    ],
    
    UserRole.viewer: [
      'view_children_readonly', 'view_orphanages_readonly',
    ],
  };
  
  static bool hasPermission(UserRole role, String permission) {
    final rolePermissions = permissions[role];
    if (rolePermissions == null) return false;
    return rolePermissions.contains(permission);
  }
  
  static bool canAddOrphanage(UserRole role) {
    return role == UserRole.superAdmin || role == UserRole.orphanageDirector;
  }
  
  static bool canEditOrphanage(UserRole role) {
    return role == UserRole.superAdmin || role == UserRole.orphanageDirector;
  }
  
  static bool canViewAllOrphanages(UserRole role) {
    return role == UserRole.superAdmin || role == UserRole.governmentOfficial;
  }
  
  static bool canViewOnlyOwnOrphanage(UserRole role) {
    return role == UserRole.orphanageDirector || role == UserRole.orphanageStaff;
  }
  
  static bool canViewOrphanages(UserRole role) {
    return role != UserRole.donor && role != UserRole.villageHead;
  }
}