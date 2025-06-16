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

  // JSON serialization - Updated with better null handling and type safety
  factory Employee.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Parsing Employee from JSON: $json');
      
      return Employee(
        firstName: _parseString(json['firstName'] ?? json['first_name'], 'Employee'),
        lastName: _parseString(json['lastName'] ?? json['last_name'], 'User'),
        email: _parseString(json['email'], 'user@company.com'),
        phone: _parseString(json['phone'], '+1234567890'),
        department: _extractDepartment(json),
        position: _parseString(json['position'] ?? json['job_title'], 'Employee'),
        profileImage: _parseString(
          json['profileImage'] ?? json['profile_image'] ?? json['avatar'], 
          'https://via.placeholder.com/150'
        ),
        joinDate: _parseDate(json['joinDate'] ?? json['join_date'] ?? json['created_at']),
        salary: _parseDouble(json['salary']),
        employeeId: _parseInt(json['id'] ?? json['employeeId'] ?? json['employee_id']),
        tenantId: _parseInt(json['tenantId'] ?? json['companyId'] ?? json['company_id']),
        address: _parseString(json['address'], '123 Main Street, City, State'),
        dateOfBirth: _parseDate(json['dateOfBirth'] ?? json['date_of_birth']),
        departmentId: _parseInt(json['departmentId'] ?? json['department_id']),
        gender: _parseGender(json['gender']),
      );
    } catch (e) {
      print('❌ Error parsing Employee from JSON: $e');
      print('📦 Raw JSON: $json');
      rethrow;
    }
  }

  // Helper methods for parsing with better type safety
  static String _parseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }


  static String _extractDepartment(Map<String, dynamic> json) {
    if (json['department'] != null) {
      if (json['department'] is String) {
        return json['department'];
      } else if (json['department'] is Map) {
        return json['department']['name'] ?? 'General';
      }
    }
    return json['dept'] ?? 'General';
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $dateValue, using current date');
        return DateTime.now();
      }
    }
    if (dateValue is DateTime) return dateValue;
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing double: $value, using 0.0');
        return 0.0;
      }
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('Error parsing int: $value, using 0');
        return 0;
      }
    }
    return 0;
  }

  static Gender _parseGender(dynamic genderValue) {
    if (genderValue == null) return Gender.other;
    
    String genderString = genderValue.toString().toLowerCase();
    switch (genderString) {
      case 'male':
      case 'm':
        return Gender.male;
      case 'female':
      case 'f':
        return Gender.female;
      case 'other':
      case 'o':
        return Gender.other;
      default:
        return Gender.other;
    }
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
