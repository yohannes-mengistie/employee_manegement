import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final String profileImage;
  final DateTime joinDate;
  final double salary;
  final String employeeId;

  const Employee({
    required this.id,
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
  });

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? position,
    String? profileImage,
    DateTime? joinDate,
    double? salary,
    String? employeeId,
  }) {
    return Employee(
      id: id ?? this.id,
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
    );
  }

  @override
  List<Object?> get props => [
        id,
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
      ];
}
