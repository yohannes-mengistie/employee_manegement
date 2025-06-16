
import 'package:dio/dio.dart';
import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/employee.dart';
import 'dart:convert';

import 'package:employee_manegement/core/models/employee_dto.dart';
import 'package:employee_manegement/core/models/user.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Helper method to parse response data safely (improved version)
  Map<String, dynamic>? _parseResponseData(dynamic responseData, String endpoint) {
    try {
      print('🔧 Parsing response data from $endpoint...');
      print('📦 Data type: ${responseData.runtimeType}');
      print('📦 Raw data: "$responseData"');

      if (responseData == null) {
        print('❌ Response data is null');
        return null;
      }

      // If it's already a Map, return it
      if (responseData is Map<String, dynamic>) {
        print('✅ Response is already a Map<String, dynamic>');
        if (responseData.isEmpty) {
          print('⚠️ Map is empty');
          return null;
        }
        return responseData;
      }

      // If it's a Map<String, Object?> or similar, convert it
      if (responseData is Map) {
        print('🔄 Converting Map to Map<String, dynamic>');
        final converted = Map<String, dynamic>.from(responseData);
        if (converted.isEmpty) {
          print('⚠️ Converted map is empty');
          return null;
        }
        print('✅ Successfully converted to Map<String, dynamic>');
        return converted;
      }

      // If it's a string, try to parse as JSON
      if (responseData is String) {
        print('🔄 Response is a string, attempting JSON parse...');
        print('📝 String content: "$responseData"');
        print('📏 String length: ${responseData.length}');
        
        if (responseData.trim().isEmpty) {
          print('❌ String is empty or whitespace only');
          return null;
        }

        try {
          final parsed = jsonDecode(responseData);
          print('✅ Successfully parsed JSON from string');
          
          if (parsed is Map<String, dynamic>) {
            if (parsed.isEmpty) {
              print('⚠️ Parsed map is empty');
              return null;
            }
            return parsed;
          } else if (parsed is Map) {
            final converted = Map<String, dynamic>.from(parsed);
            if (converted.isEmpty) {
              print('⚠️ Converted parsed map is empty');
              return null;
            }
            return converted;
          } else {
            print('❌ Parsed JSON is not a Map: ${parsed.runtimeType}');
            return null;
          }
        } catch (jsonError) {
          print('❌ JSON parse error: $jsonError');
          return null;
        }
      }

      // If it's a List, check if it has user data
      if (responseData is List) {
        print('🔄 Response is a List with ${responseData.length} items');
        if (responseData.isNotEmpty && responseData.first is Map) {
          print('✅ Using first item from list');
          final firstItem = Map<String, dynamic>.from(responseData.first);
          if (firstItem.isEmpty) {
            print('⚠️ First item in list is empty');
            return null;
          }
          return firstItem;
        }
        print('❌ List is empty or doesn\'t contain Maps');
        return null;
      }

      print('❌ Unsupported response data type: ${responseData.runtimeType}');
      return null;
    } catch (e) {
      print('❌ Error parsing response data: $e');
      return null;
    }
  }


  // Get current employee profile - IMPROVED with better fallback
  Future<Employee> getCurrentEmployeeProfile() async {
    try {
      // Get user ID from JWT token
      final userId = await _tokenService.getEmployeeId();
      if (userId == null) {
        print('⚠️ Could not extract user ID from token, using fallback');
        return _createFallbackEmployee();
      }

      print('🔍 Getting current employee profile for user ID: $userId');

      // Try multiple endpoints to get the profile
      Employee? employee;
      Map<String, dynamic>? userData;

      // Method 1: Try /user/{id} endpoint FIRST
      try {
        print('🌐 Trying /user/$userId endpoint (primary method)...');
        final response = await _apiService.get('${ApiConfig.userEndpoint}/$userId');
        userData = _parseResponseData(response.data, '/user/$userId');
        if (userData != null && userData.isNotEmpty) {
          employee = Employee.fromJson(userData);
          print('✅ Got profile from /user/$userId');
        } else {
          print('⚠️ /user/$userId returned empty data');
        }
      } catch (e) {
        print('❌ /user/$userId failed: $e');
      }

      // // Method 2: Try /user/me endpoint as fallback
      // if (employee == null) {
      //   try {
      //     print('🌐 Trying /user/me endpoint (fallback)...');
      //     final response = await _apiService.get(ApiConfig.userMeEndpoint);
      //     userData = _parseResponseData(response.data, '/user/me');
      //     if (userData != null && userData.isNotEmpty) {
      //       employee = Employee.fromJson(userData);
      //       print('✅ Got profile from /user/me');
      //     } else {
      //       print('⚠️ /user/me returned empty data');
      //     }
      //   } catch (e) {
      //     print('❌ /user/me failed: $e');
      //   }
      // }

      // // Method 3: Try /employee/{id} endpoint as last resort
      // if (employee == null) {
      //   try {
      //     print('🌐 Trying /employee/$userId endpoint (last resort)...');
      //     final response = await _apiService.get('${ApiConfig.employeeEndpoint}/$userId');
      //     userData = _parseResponseData(response.data, '/employee/$userId');
      //     if (userData != null && userData.isNotEmpty) {
      //       employee = Employee.fromJson(userData);
      //       print('✅ Got profile from /employee/$userId');
      //     } else {
      //       print('⚠️ /employee/$userId returned empty data');
      //     }
      //   } catch (e) {
      //     print('❌ /employee/$userId failed: $e');
      //   }
      // }

      if (employee != null) {
        // Ensure the employee has the correct ID from the token
        employee = employee.copyWith(employeeId: userId);
        print('✅ Successfully got employee profile: ${employee.fullName}');
        return employee;
      } else {
        print('⚠️ All endpoints failed or returned empty data, using fallback');
        return _createFallbackEmployee(userId);
      }
    } catch (e) {
      print('❌ Failed to get current employee profile: $e');
      return _createFallbackEmployee();
    }
  }


  // Create fallback employee with better data
  Future<Employee> _createFallbackEmployee([int? userId]) async {
    print('🔧 Creating fallback employee...');
    
    // Try to get data from token if available
    final tokenUserId = userId ?? await _tokenService.getEmployeeId();
    final tenantId = await _tokenService.getTenantId();
    
    // Try to get email from stored auth response
    String email = 'user@company.com';
    String firstName = 'Employee';
    String lastName = 'User';
    
    try {
      final authResponse = await _tokenService.getAuthResponse();
      if (authResponse != null) {
        email = authResponse.employee.email;
        firstName = authResponse.employee.firstName;
        lastName = authResponse.employee.lastName;
        print('📋 Using data from stored auth response');
      }
    } catch (e) {
      print('⚠️ Could not get data from auth response: $e');
    }
    
    final employee = Employee(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: '+1234567890',
      department: 'General',
      position: 'Employee',
      profileImage: 'https://via.placeholder.com/150',
      joinDate: DateTime.now().subtract(const Duration(days: 365)),
      salary: 50000.0,
      employeeId: tokenUserId ?? 1,
      tenantId: tenantId ?? 1,
      address: '123 Main Street, City, State',
      dateOfBirth: DateTime(1990, 1, 1),
      departmentId: 1,
      gender: Gender.other,
    );

    print('✅ Created fallback employee: ${employee.fullName} (ID: ${employee.employeeId})');
    return employee;
  }

  // Create employee
  Future<Employee> createEmployee(CreateEmployeeDto dto) async {
    final response = await _apiService.post(
      ApiConfig.employeeEndpoint,
      data: dto.toJson(),
    );

    final userData = _parseResponseData(response.data, 'createEmployee');
    if (userData != null) {
      return Employee.fromJson(userData);
    } else {
      throw Exception('Invalid response format for createEmployee');
    }
  }

  // Search employees
  Future<List<Employee>> searchEmployees(SearchEmployeeDto dto) async {
    final response = await _apiService.get(
      ApiConfig.employeeSearchEndpoint,
      queryParameters: dto.toJson(),
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) {
        final userData = _parseResponseData(json, 'searchEmployees');
        return userData != null ? Employee.fromJson(userData) : null;
      }).where((employee) => employee != null).cast<Employee>().toList();
    } else {
      throw Exception('Expected List response for searchEmployees');
    }
  }

  // Get all employees
  Future<List<Employee>> getAllEmployees({
    int? companyId,
    String? isActive,
  }) async {
    final queryParams = <String, dynamic>{};
    if (companyId != null) queryParams['companyId'] = companyId;
    if (isActive != null) queryParams['isActive'] = isActive;

    final response = await _apiService.get(
      ApiConfig.employeeEndpoint,
      queryParameters: queryParams,
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) {
        final userData = _parseResponseData(json, 'getAllEmployees');
        return userData != null ? Employee.fromJson(userData) : null;
      }).where((employee) => employee != null).cast<Employee>().toList();
    } else {
      throw Exception('Expected List response for getAllEmployees');
    }
  }

  // Get employee by ID
  Future<Employee> getEmployeeById(int id) async {
    final response = await _apiService.get(
      '${ApiConfig.employeeEndpoint}/$id',
    );

    final userData = _parseResponseData(response.data, 'getEmployeeById');
    if (userData != null) {
      return Employee.fromJson(userData);
    } else {
      throw Exception('Invalid response format for getEmployeeById');
    }
  }


  // Get employee stats
  Future<EmployeeStats> getEmployeeStats(int id) async {
    try {
      final response = await _apiService.get(
        ApiConfig.employeeStatsEndpoint.replaceAll('{id}', id.toString()),
      );

      final statsData = _parseResponseData(response.data, 'getEmployeeStats');
      if (statsData != null) {
        return EmployeeStats.fromJson(statsData);
      } else {
        throw Exception('Invalid response format for getEmployeeStats');
      }
    } catch (e) {
      print('Failed to get employee stats: $e');
      // Return mock stats for testing
      return const EmployeeStats(
        totalAttendance: 22,
        presentDays: 20,
        absentDays: 2,
        lateDays: 1,
        attendancePercentage: 90.9,
        totalWorkingHours: Duration(hours: 176),
        averageWorkingHours: 8.0,
      );
    }
  }

  // Get current employee stats
  Future<EmployeeStats> getCurrentEmployeeStats() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      // Return mock stats if no employee ID
      return const EmployeeStats(
        totalAttendance: 22,
        presentDays: 20,
        absentDays: 2,
        lateDays: 1,
        attendancePercentage: 90.9,
        totalWorkingHours: Duration(hours: 176),
        averageWorkingHours: 8.0,
      );
    }

    return await getEmployeeStats(employeeId);
  }

  // Get department employees
  Future<List<Employee>> getDepartmentEmployees(int departmentId) async {
    final response = await _apiService.get(
      '${ApiConfig.employeeDepartmentEndpoint}/$departmentId',
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) {
        final userData = _parseResponseData(json, 'getDepartmentEmployees');
        return userData != null ? Employee.fromJson(userData) : null;
      }).where((employee) => employee != null).cast<Employee>().toList();
    } else {
      throw Exception('Expected List response for getDepartmentEmployees');
    }
  }

  // Update employee
  Future<Employee> updateEmployee(int id, UpdateEmployeeDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.employeeEndpoint}/$id',
      data: dto.toJson(),
    );

    final userData = _parseResponseData(response.data, 'updateEmployee');
    if (userData != null) {
      return Employee.fromJson(userData);
    } else {
      throw Exception('Invalid response format for updateEmployee');
    }
  }

  // Update current employee profile - UPDATED to handle fullName reconstruction
  Future<Employee> updateCurrentEmployeeProfile(Employee employee) async {
    try {
      final employeeId = await _tokenService.getEmployeeId();
      if (employeeId == null) {
        throw Exception('Employee ID not found in token');
      }

      print('🔄 Updating employee profile for ID: $employeeId');
      print('📋 Updated firstName: "${employee.firstName}"');
      print('📋 Updated lastName: "${employee.lastName}"');

      // Reconstruct fullName from firstName and lastName
      final fullName = '${employee.firstName.trim()} ${employee.lastName.trim()}'.trim();
      print('📋 Reconstructed fullName: "$fullName"');

      // For User model, we need to update the fullName field
      // Since your backend uses User model, we should update fullName
      final updateData = {
        'fullName': fullName,
        'email': employee.email,
        // Add other fields that can be updated in your User model
      };

      print('📦 Update data: $updateData');

      // Try to update via user endpoint since your backend uses User model
      try {
        final response = await _apiService.put(
          '${ApiConfig.userEndpoint}/$employeeId',
          data: updateData,
        );


        final userData = _parseResponseData(response.data, 'updateCurrentEmployeeProfile');
        if (userData != null) {
          // Parse as User first, then convert to Employee
          final updatedUser = User.fromJson(userData);
          final updatedEmployee = updatedUser.toEmployee();
          print('✅ Successfully updated user profile via /user endpoint');
          return updatedEmployee;
        }
      } catch (e) {
        print('❌ Failed to update via /user endpoint: $e');
      }

      // Fallback: try the original employee endpoint
      final dto = UpdateEmployeeDto(
        firstName: employee.firstName,
        lastName: employee.lastName,
        email: employee.email,
        phone: employee.phone,
        address: employee.address,
        dateOfBirth: employee.dateOfBirth,
        gender: employee.gender.name,
        departmentId: employee.departmentId,
        position: employee.position,
        salary: employee.salary,
        profileImage: employee.profileImage,
      );

      try {
        return await updateEmployee(employeeId, dto);
      } catch (e) {
        print('❌ Failed to update via /employee endpoint: $e');
        // For testing, return the updated employee with proper name handling
        return employee;
      }
    } catch (e) {
      print('Failed to update employee profile: $e');
      // For testing, just return the updated employee
      return employee;
    }
  }

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    await _apiService.delete('${ApiConfig.employeeEndpoint}/$id');
  }

  // Toggle employee status
  Future<Employee> toggleEmployeeStatus(int id, EmployeeStatus status) async {
    final response = await _apiService.patch(
      ApiConfig.employeeStatusEndpoint.replaceAll('{id}', id.toString()),
      data: {'status': status.name},
    );

    final userData = _parseResponseData(response.data, 'toggleEmployeeStatus');
    if (userData != null) {
      return Employee.fromJson(userData);
    } else {
      throw Exception('Invalid response format for toggleEmployeeStatus');
    }
  }

  // Bulk update employee status
  Future<List<Employee>> bulkUpdateEmployeeStatus(
    List<int> employeeIds,
    EmployeeStatus status,
  ) async {
    final response = await _apiService.post(
      ApiConfig.employeeBulkStatusEndpoint,
      data: {
        'employeeIds': employeeIds,
        'status': status.name,
      },
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) {
        final userData = _parseResponseData(json, 'bulkUpdateEmployeeStatus');
        return userData != null ? Employee.fromJson(userData) : null;
      }).where((employee) => employee != null).cast<Employee>().toList();
    } else {
      throw Exception('Expected List response for bulkUpdateEmployeeStatus');
    }
  }

  // Transfer employees
  Future<List<Employee>> transferEmployees(
    int fromDepartmentId,
    int toDepartmentId,
    List<int> employeeIds,
  ) async {
    final response = await _apiService.post(
      ApiConfig.employeeTransferEndpoint,
      data: {
        'fromDepartmentId': fromDepartmentId,
        'toDepartmentId': toDepartmentId,
        'employeeIds': employeeIds,
      },
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) {
        final userData = _parseResponseData(json, 'transferEmployees');
        return userData != null ? Employee.fromJson(userData) : null;
      }).where((employee) => employee != null).cast<Employee>().toList();
    } else {
      throw Exception('Expected List response for transferEmployees');
    }
  }

  // Update profile image
  Future<Employee> updateProfileImage(String imagePath) async {
    try {
      final employeeId = await _tokenService.getEmployeeId();
      if (employeeId == null) {
        throw Exception('Employee ID not found in token');
      }


      final dto = UpdateEmployeeDto(profileImage: imagePath);
      return await updateEmployee(employeeId, dto);
    } catch (e) {
      print('Failed to update profile image: $e');
      // For testing, return current employee with updated image
      final currentEmployee = await getCurrentEmployeeProfile();
      return currentEmployee.copyWith(profileImage: imagePath);
    }
  }
}
