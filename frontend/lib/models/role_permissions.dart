enum UserRole {
  superAdmin,
  orphanageDirector,
  socialWorker,
  healthcareWorker,
  villageHead,
  donor,
  governmentOfficial,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'System Administrator';
      case UserRole.orphanageDirector:
        return 'Orphanage Director';
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
    }
  }
  
  String get code {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.orphanageDirector:
        return 'orphanage_director';
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
    }
  }
  
  static UserRole fromCode(String code) {
    switch (code) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'orphanage_director':
        return UserRole.orphanageDirector;
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
      default:
        return UserRole.socialWorker;
    }
  }
}

class RolePermissions {
  static const Map<UserRole, List<String>> permissions = {
    UserRole.superAdmin: [
      'view_all_children', 'edit_all_children', 'delete_children',
      'view_all_staff', 'manage_staff', 'manage_orphanages',
      'view_all_beds', 'manage_beds', 'view_reports',
      'manage_users', 'system_settings', 'audit_logs',
      'view_all_transports', 'manage_all_transports',
    ],
    
    UserRole.orphanageDirector: [
      'view_orphanage_children', 'enroll_children', 'edit_orphanage_children',
      'view_orphanage_staff', 'manage_orphanage_staff',
      'view_orphanage_beds', 'manage_orphanage_beds',
      'approve_transport', 'view_orphanage_reports',
      'request_transport', 'view_orphanage_finances',
    ],
    
    UserRole.socialWorker: [
      'enroll_children', 'edit_assigned_children',
      'view_assigned_children', 'add_case_notes',
      'family_tracing', 'request_transport',
      'view_medical_records', 'generate_child_reports',
      'court_documentation', 'home_visits',
    ],
    
    UserRole.healthcareWorker: [
      'enroll_children', 'emergency_enrollment',
      'view_medical_records', 'add_medical_records',
      'edit_medical_records', 'track_vaccinations',
      'record_checkups', 'prescribe_medications',
      'create_emergency_alerts', 'request_immediate_transport',
      'view_health_reports', 'notify_orphanage',
      'birth_registration', 'mother_death_certification',
    ],
    
    UserRole.villageHead: [
      'report_orphans', 'view_village_reports',
      'track_reported_cases', 'send_emergency_alerts',
      'verify_cases', 'view_village_children',
    ],
    
    UserRole.donor: [
      'view_sponsored_children', 'sponsor_children',
      'view_donation_history', 'send_messages',
      'download_receipts', 'view_child_updates',
    ],
    
    UserRole.governmentOfficial: [
      'view_all_orphanages_readonly', 'view_statistics',
      'generate_compliance_reports', 'export_anonymized_data',
      'audit_orphanages', 'view_policy_compliance',
    ],
  };
  
  static bool hasPermission(UserRole role, String permission) {
    final rolePermissions = permissions[role];
    if (rolePermissions == null) return false;
    return rolePermissions.contains(permission);
  }
  
  static List<String> getPermissionsForRole(UserRole role) {
    return permissions[role] ?? [];
  }
}