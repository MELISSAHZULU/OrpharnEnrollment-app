import 'package:flutter/material.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final String? orphanageName;
  final DateTime? dateJoined;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.orphanageName,
    this.dateJoined,
  });
  
  String get fullName => '$firstName $lastName';
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'staff',
      phoneNumber: json['phone_number'],
      orphanageName: json['orphanage_name'],
      dateJoined: json['date_joined'] != null ? DateTime.parse(json['date_joined']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone_number': phoneNumber,
      'orphanage_name': orphanageName,
    };
  }
  
  String getRoleDisplay() {
    switch(role) {
      case 'admin':
        return 'System Administrator';
      case 'orphanage_staff':
        return 'Orphanage Staff';
      case 'healthcare_worker':
        return 'Healthcare Worker';
      case 'village_head':
        return 'Village Head';
      default:
        return 'Staff Member';
    }
  }
  
  IconData getRoleIcon() {
    switch(role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'orphanage_staff':
        return Icons.family_restroom;
      case 'healthcare_worker':
        return Icons.medical_services;
      case 'village_head':
        return Icons.location_city;
      default:
        return Icons.person;
    }
  }
}