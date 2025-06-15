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