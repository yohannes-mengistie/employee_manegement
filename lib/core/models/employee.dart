import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

class Employee extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final String profileImage;
  final DateTime joinDate;
  final double salary;
  final int employeeId;
  final int tenantId; 
  final String address; 
  final DateTime dateOfBirth; 
  final int departmentId; 
  final Gender gender; 

  const Employee({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.profileImage,
    required this.joinDate,
    required this.salary,
    required this.employeeId,
    required this.tenantId,
    required this.address,
    required this.dateOfBirth,
    required this.departmentId,
    required this.gender,
  });

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? position,
    String? profileImage,
    DateTime? joinDate,
    double? salary,
    int? employeeId,
    int? tenantId,
    String? address,
    DateTime? dateOfBirth,
    int? departmentId,
    Gender? gender,
  }) {
    return Employee(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      profileImage: profileImage ?? this.profileImage,
      joinDate: joinDate ?? this.joinDate,
      salary: salary ?? this.salary,
      employeeId: employeeId ?? this.employeeId,
      tenantId: tenantId ?? this.tenantId,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      departmentId: departmentId ?? this.departmentId,
      gender: gender ?? this.gender,
    );
  }

  // JSON serialization - Updated to match your backend
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department']?['name'] ?? json['department'] ?? '',
      position: json['position'] ?? '',
      profileImage: json['profileImage'] ?? 'https://via.placeholder.com/150',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      salary: (json['salary'] ?? 0).toDouble(),
      employeeId: json['id'] ?? json['employeeId'] ?? 0,
      tenantId: json['tenantId'] ?? json['companyId'] ?? 0,
      address: json['address'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      departmentId: json['departmentId'] ?? 0,
      gender: _parseGender(json['gender']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'profileImage': profileImage,
      'joinDate': joinDate.toIso8601String(),
      'salary': salary,
      'id': employeeId,
      'employeeId': employeeId,
      'tenantId': tenantId,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'departmentId': departmentId,
      'gender': gender.name,
    };
  }

  static Gender _parseGender(String? genderString) {
    switch (genderString?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other;
    }
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        department,
        position,
        profileImage,
        joinDate,
        salary,
        employeeId,
        tenantId,
        address,
        dateOfBirth,
        departmentId,
        gender,
      ];
}
