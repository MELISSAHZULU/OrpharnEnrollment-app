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
      role: json['role'] ?? json['profile']?['role'] ?? 'social_worker',
      phoneNumber: json['phone_number'] ?? json['profile']?['phone_number'],
      orphanageName: json['orphanage_name'] ?? json['profile']?['orphanage_name'],
      dateJoined: json['date_joined'] != null ? DateTime.parse(json['date_joined']) : null,
    );
  }
}