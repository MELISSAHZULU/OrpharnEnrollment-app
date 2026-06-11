class Child {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String village;
  final String district;
  final String? guardianName;
  final String? guardianContact;
  final String reasonForCare;
  final String status;
  final int? age;
  
  Child({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.village,
    required this.district,
    this.guardianName,
    this.guardianContact,
    required this.reasonForCare,
    this.status = 'PENDING',
    this.age,
  });
  
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      village: json['village'],
      district: json['district'],
      guardianName: json['guardian_name'],
      guardianContact: json['guardian_contact'],
      reasonForCare: json['reason_for_care'],
      status: json['status'],
      age: json['age'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'village': village,
      'district': district,
      'guardian_name': guardianName,
      'guardian_contact': guardianContact,
      'reason_for_care': reasonForCare,
      'status': status,
    };
  }
}