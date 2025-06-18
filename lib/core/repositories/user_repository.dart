

import 'dart:convert';

import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/employee_dto.dart';
import 'package:employee_manegement/core/models/user.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  // Helper method to parse response data safely (improved version)
  Map<String, dynamic>? _parseResponseData(dynamic responseData, String endpoint) {
    try {
      // print('🔧 Parsing response data from $endpoint...');
      // print('📦 Data type: ${responseData.runtimeType}');
      // print('📦 Raw data: "$responseData"');

      if (responseData == null) {
        // print('❌ Response data is null');
        return null;
      }

      // If it's already a Map, return it
      if (responseData is Map<String, dynamic>) {
        // print('✅ Response is already a Map<String, dynamic>');
        if (responseData.isEmpty) {
          // print('⚠️ Map is empty');
          return null;
        }
        return responseData;
      }

      // If it's a Map<String, Object?> or similar, convert it
      if (responseData is Map) {
        // print('🔄 Converting Map to Map<String, dynamic>');
        final converted = Map<String, dynamic>.from(responseData);
        if (converted.isEmpty) {
          // print('⚠️ Converted map is empty');
          return null;
        }
        // print('✅ Successfully converted to Map<String, dynamic>');
        return converted;
      }

      // If it's a string, try to parse as JSON
      if (responseData is String) {
        // print('🔄 Response is a string, attempting JSON parse...');
        // print('📝 String content: "$responseData"');
        // print('📏 String length: ${responseData.length}');
        
        if (responseData.trim().isEmpty) {
          // print('❌ String is empty or whitespace only');
          return null;
        }

        try {
          final parsed = jsonDecode(responseData);
          // print('✅ Successfully parsed JSON from string');
          
          if (parsed is Map<String, dynamic>) {
            if (parsed.isEmpty) {
              // print('⚠️ Parsed map is empty');
              return null;
            }
            return parsed;
          } else if (parsed is Map) {
            final converted = Map<String, dynamic>.from(parsed);
            if (converted.isEmpty) {
              // print('⚠️ Converted parsed map is empty');
              return null;
            }
            return converted;
          } else {
            // print('❌ Parsed JSON is not a Map: ${parsed.runtimeType}');
            return null;
          }
        } catch (jsonError) {
          // print('❌ JSON parse error: $jsonError');
          return null;
        }
      }

      // If it's a List, check if it has user data
      if (responseData is List) {
        // print('🔄 Response is a List with ${responseData.length} items');
        if (responseData.isNotEmpty && responseData.first is Map) {
          // print('✅ Using first item from list');
          final firstItem = Map<String, dynamic>.from(responseData.first);
          if (firstItem.isEmpty) {
            // print('⚠️ First item in list is empty');
            return null;
          }
          return firstItem;
        }
        // print('❌ List is empty or doesn\'t contain Maps');
        return null;
      }

      // print('❌ Unsupported response data type: ${responseData.runtimeType}');
      return null;
    } catch (e) {
      // print('❌ Error parsing response data: $e');
      return null;
    }
  }


  // Role management
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    final response = await _apiService.get(ApiConfig.userRoleEndpoint);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createRole(CreateRoleDto dto) async {
    final response = await _apiService.post(
      ApiConfig.userRoleEndpoint,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateRole(int id, UpdateRoleDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.userRoleEndpoint}/$id',
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<void> deleteRole(int id) async {
    await _apiService.delete('${ApiConfig.userRoleEndpoint}/$id');
  }

  // User management
  Future<Map<String, dynamic>> createUser(CreateUserDto dto) async {
    final response = await _apiService.post(
      ApiConfig.userEndpoint,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _apiService.get(ApiConfig.userEndpoint);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await _apiService.get('${ApiConfig.userEndpoint}/$id');
   
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(int id, UpdateUserDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.userEndpoint}/$id',
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<void> deleteUser(int id) async {
    await _apiService.delete('${ApiConfig.userEndpoint}/$id');
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // Get user ID from JWT token
      final userId = await _tokenService.getEmployeeId();
      if (userId == null) {
        
      }

      User? employee;
      Map<String, dynamic>? userData;

      // Method 1: Try /user/{id} endpoint FIRST
      try {
        // print('🌐 Trying /user/$userId endpoint (primary method)...');
        final response = await _apiService.get('${ApiConfig.userEndpoint}/$userId');
        userData = _parseResponseData(response.data, '/user/$userId');
        if (userData != null && userData.isNotEmpty) {
          employee = User.fromJson(userData);
          // print('✅ Got profile from /user/$userId');
        } else {
          // print('⚠️ /user/$userId returned empty data');
        }
      } catch (e) {
        // print('❌ /user/$userId failed: $e');
      }
      
  
      if (employee != null) {
        
        return employee.toJson();
      } else {
        // print('⚠️ All endpoints failed or returned empty data, using fallback');
        return _createFallbackEmployee(userId);
      }
    } catch (e) {
      // print('❌ Failed to get current employee profile: $e');
      return {};
    }
  }

  // Fallback employee creation method
  Map<String, dynamic> _createFallbackEmployee(dynamic userId) {
    return {
      'employeeId': userId,
      'fullName': 'Unknown User',
      'email': '',
      // Add other default fields as needed
    };
  }


}