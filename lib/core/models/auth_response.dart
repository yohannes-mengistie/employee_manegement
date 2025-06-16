import 'package:employee_manegement/core/models/employee.dart';
import 'package:equatable/equatable.dart';


class AuthResponse extends Equatable {
  final String token;
  final String refreshToken;
  final Employee employee;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.employee,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle access_token based response
      String token = json['token'] ?? 
                    json['access_token'] ?? 
                    json['accessToken'] ?? 
                    '';

      String refreshToken = json['refreshToken'] ?? 
                           json['refresh_token'] ?? 
                           json['access_token'] ?? // Use access_token as refresh token if no separate refresh token
                           '';

      // Handle employee data
      Map<String, dynamic> employeeData;
      if (json['employee'] != null) {
        employeeData = json['employee'] as Map<String, dynamic>;
      } else if (json['user'] != null) {
        employeeData = json['user'] as Map<String, dynamic>;
      } else {
        // If no employee data, create from top-level fields or use defaults
        employeeData = Map<String, dynamic>.from(json);
        
        // Add default employee fields if missing
        employeeData.putIfAbsent('id', () => 1);
        employeeData.putIfAbsent('firstName', () => 'Employee');
        employeeData.putIfAbsent('lastName', () => 'User');
        employeeData.putIfAbsent('email', () => 'user@company.com');
        employeeData.putIfAbsent('phone', () => '+1234567890');
        employeeData.putIfAbsent('department', () => 'General');
        employeeData.putIfAbsent('position', () => 'Employee');
        employeeData.putIfAbsent('profileImage', () => 'https://via.placeholder.com/150');
        employeeData.putIfAbsent('joinDate', () => DateTime.now().toIso8601String());
        employeeData.putIfAbsent('salary', () => 50000.0);
        employeeData.putIfAbsent('tenantId', () => 1);
        employeeData.putIfAbsent('address', () => '123 Main Street');
        employeeData.putIfAbsent('dateOfBirth', () => DateTime(1990, 1, 1).toIso8601String());
        employeeData.putIfAbsent('departmentId', () => 1);
        employeeData.putIfAbsent('gender', () => 'other');
      }

      // Handle expiration
      DateTime expiresAt;
      if (json['expiresAt'] != null) {
        expiresAt = DateTime.parse(json['expiresAt']);
      } else if (json['expires_in'] != null) {
        final expiresIn = json['expires_in'] as int;
        expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      } else {
        expiresAt = DateTime.now().add(const Duration(hours: 24));
      }

      return AuthResponse(
        token: token,
        refreshToken: refreshToken,
        employee: Employee.fromJson(employeeData),
        expiresAt: expiresAt,
      );
    } catch (e) {
      print('❌ Error parsing AuthResponse: $e');
      print('📦 Raw JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'employee': employee.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [token, refreshToken, employee, expiresAt];
}
