
import 'package:dio/dio.dart';
import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/auth_dto.dart';
import 'package:employee_manegement/core/models/auth_response.dart';
import 'package:employee_manegement/core/models/employee.dart';
import 'package:employee_manegement/core/models/user.dart';
import 'dart:convert';

import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/jwt_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Login - Updated to handle User response structure
  Future<AuthResponse> login(String email, String password) async {
    try {
      final loginDto = LoginDto(email: email, password: password);
      
      print('🔐 Attempting login with email: $email');
      
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: loginDto.toJson(),
      );

      print('✅ Login response received: ${response.data}');

      if (response.data == null) {
        throw Exception('Login response is null');
      }

      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format: ${response.data.runtimeType}');
      }

      if (!responseData.containsKey('access_token')) {
        print('⚠️ Response missing access_token field. Available fields: ${responseData.keys}');
        throw Exception('Login response missing access_token');
      }

      // Create AuthResponse by decoding JWT and fetching user profile
      final authResponse = await _createAuthResponseWithUserProfile(responseData, email);
      await _tokenService.saveAuthResponse(authResponse);
      
      return authResponse;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }

  // Helper method to create AuthResponse by fetching user profile - UPDATED for User model
  Future<AuthResponse> _createAuthResponseWithUserProfile(Map<String, dynamic> data, String email) async {
    try {
      final accessToken = data['access_token'] as String;
      
      if (accessToken.isEmpty) {
        throw Exception('Empty access_token received');
      }

      // Decode JWT to get user information with detailed logging
      print('🔍 Analyzing JWT token...');
      final userInfo = JwtService.getUserInfo(accessToken);
      
      print('📋 Complete JWT user info:');
      userInfo.forEach((key, value) {
        print('  $key: $value');
      });

      // Extract user data from JWT
      final userId = userInfo['userId'] as int?;
      final tokenEmail = userInfo['email'] as String?;
      final tenantId = userInfo['tenantId'] as int?;
      final expirationDate = userInfo['expiresAt'] as DateTime?;
      final isValid = userInfo['isValid'] as bool? ?? false;

      print('📋 Extracted key information:');
      print('  User ID: $userId');
      print('  Email: $tokenEmail');
      print('  Tenant ID: $tenantId');
      print('  Expires: $expirationDate');
      print('  Is Valid: $isValid');

      if (!isValid) {
        print('⚠️ JWT token validation failed');
      }

      if (userId == null) {
        print('⚠️ Could not extract user ID from JWT token, using fallback');
        // Create employee from JWT data with fallback ID
        final employee = _createEmployeeFromJWT(1, tokenEmail ?? email, tenantId);
        return AuthResponse(
          token: accessToken,
          refreshToken: accessToken,
          employee: employee,
          expiresAt: expirationDate ?? DateTime.now().add(const Duration(hours: 24)),
        );
      }


      // Fetch user profile using the extracted user ID
      Employee employee;
      try {
        employee = await _fetchUserProfileById(accessToken, userId);
        print('✅ Successfully fetched user profile from backend');
      } catch (e) {
        print('⚠️ Failed to fetch user profile from backend: $e');
        print('🔄 Creating fallback employee from JWT data');
        employee = _createEmployeeFromJWT(userId, tokenEmail ?? email, tenantId);
      }

      return AuthResponse(
        token: accessToken,
        refreshToken: accessToken, // Use same token as refresh token
        employee: employee,
        expiresAt: expirationDate ?? DateTime.now().add(const Duration(hours: 24)),
      );
    } catch (e) {
      print('❌ Error creating AuthResponse with user profile: $e');
      print('📦 Raw data: $data');
      rethrow;
    }
  }

  // Fetch user profile by ID from backend - UPDATED to handle User response
  Future<Employee> _fetchUserProfileById(String token, int userId) async {
    try {
      print('🌐 Fetching user profile for ID: $userId');
      
      // Create a temporary Dio instance with the token
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ));

      Response? response;
      User? user;
      
      // Method 1: Try /user/{id} endpoint FIRST
      try {
        print('🔍 Trying /user/$userId endpoint (primary method)...');
        response = await dio.get('${ApiConfig.userEndpoint}/$userId');
        print('✅ Got response from /user/$userId');
        print('📦 Raw response data: ${response.data}');
        print('📦 Response type: ${response.data.runtimeType}');
        print('📦 Status Code: ${response.statusCode}');
        
        final userData = _parseResponseData(response.data, '/user/$userId');
        if (userData != null && userData.isNotEmpty) {
          user = User.fromJson(userData);
          print('✅ Successfully parsed User data from /user/$userId');
          print('👤 User: ${user.fullName} (ID: ${user.id})');
        } else {
          print('⚠️ /user/$userId returned empty or invalid data');
        }
      } catch (e) {
        print('❌ /user/$userId failed: $e');
        if (e is DioException) {
          print('  Status Code: ${e.response?.statusCode}');
          print('  Response Data: "${e.response?.data}"');
          print('  Response Type: ${e.response?.data.runtimeType}');
        }
      }

      // Method 2: Try /user/me endpoint as fallback
      if (user == null) {
        try {
          print('🔍 Trying /user/me endpoint (fallback)...');
          response = await dio.get(ApiConfig.userMeEndpoint);
          print('✅ Got response from /user/me');
          print('📦 Raw response data: ${response.data}');
          print('📦 Response type: ${response.data.runtimeType}');
          
          final userData = _parseResponseData(response.data, '/user/me');
          if (userData != null && userData.isNotEmpty) {
            user = User.fromJson(userData);
            print('✅ Successfully parsed User data from /user/me');
            print('👤 User: ${user.fullName} (ID: ${user.id})');
          } else {
            print('⚠️ /user/me returned empty or invalid data');
          }
        } catch (e) {
          print('❌ /user/me failed: $e');
          if (e is DioException) {
            print('  Status Code: ${e.response?.statusCode}');
            print('  Response Data: "${e.response?.data}"');
            print('  Response Type: ${e.response?.data.runtimeType}');
          }
        }
      }


      if (user != null) {
        // Convert User to Employee
        final employee = user.toEmployee();
        print('✅ Successfully converted User to Employee: ${employee.fullName}');
        print('📦 Employee data: ${employee.toJson()}');
        return employee;
      } else {
        print('❌ All endpoints returned empty or invalid data');
        throw Exception('All profile fetch attempts failed - no valid data received from any endpoint');
      }
    } catch (e) {
      print('❌ Failed to fetch user profile by ID: $e');
      rethrow;
    }
  }

  // Helper method to parse response data safely - SAME AS BEFORE
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


  // Create employee from JWT data when backend fetch fails - ENHANCED
  Employee _createEmployeeFromJWT(int userId, String email, int? tenantId) {
    print('🔧 Creating fallback employee from JWT data');
    print('📋 Input data: userId=$userId, email=$email, tenantId=$tenantId');
    
    // Extract name from email
    String firstName = 'User';
    String lastName = 'Employee';
    
    try {
      if (email.contains('@')) {
        final emailPart = email.split('@')[0];
        print('📧 Email part: $emailPart');
        
        if (emailPart.contains('.')) {
          final nameParts = emailPart.split('.');
          firstName = _capitalize(nameParts[0]);
          if (nameParts.length > 1) {
            lastName = _capitalize(nameParts[1]);
          }
        } else if (emailPart.contains('_')) {
          final nameParts = emailPart.split('_');
          firstName = _capitalize(nameParts[0]);
          if (nameParts.length > 1) {
            lastName = _capitalize(nameParts[1]);
          }
        } else {
          firstName = _capitalize(emailPart);
        }
      }
    } catch (e) {
      print('Error parsing email for name: $e');
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
      employeeId: userId,
      tenantId: tenantId ?? 1,
      address: '123 Main Street, City, State',
      dateOfBirth: DateTime(1990, 1, 1),
      departmentId: 1,
      gender: Gender.other,
    );

    print('✅ Created fallback employee: ${employee.fullName} (ID: $userId)');
    print('📦 Employee data: ${employee.toJson()}');
    return employee;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Register - Updated for access_token response
  Future<AuthResponse> register(RegisterDto registerDto) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerEndpoint,
        data: registerDto.toJson(),
      );

      if (response.data == null) {
        throw Exception('Register response is null');
      }

      final authResponse = await _createAuthResponseWithUserProfile(
        response.data, 
        registerDto.email
      );
      await _tokenService.saveAuthResponse(authResponse);
      
      return authResponse;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  // Get current user with profile refresh - IMPROVED fallback
  Future<Employee?> getCurrentUser() async {
    try {
      final authResponse = await _tokenService.getAuthResponse();
      if (authResponse == null) {
        print('❌ No auth response found in storage');
        return null;
      }

      print('📋 Current auth response: ${authResponse.employee.fullName} (ID: ${authResponse.employee.employeeId})');

      // Try to refresh user profile from backend
      final token = authResponse.token;
      final userId = authResponse.employee.employeeId;

      try {
        final updatedEmployee = await _fetchUserProfileById(token, userId);
        
        // Update stored auth response with fresh profile data
        final updatedAuthResponse = AuthResponse(
          token: authResponse.token,
          refreshToken: authResponse.refreshToken,
          employee: updatedEmployee,
          expiresAt: authResponse.expiresAt,
        );
        await _tokenService.saveAuthResponse(updatedAuthResponse);
        
        print('✅ Successfully refreshed user profile from backend');
        return updatedEmployee;
      } catch (e) {
        print('⚠️ Could not refresh user profile from backend: $e');
        print('🔄 Using cached employee data');
        return authResponse.employee;
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }


  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final forgotPasswordDto = ForgotPasswordDto(email: email);
      
      final response = await _apiService.post(
        ApiConfig.forgotPasswordEndpoint,
        data: forgotPasswordDto.toJson(),
      );

      return response.data ?? {'message': 'Password reset email sent'};
    } catch (e) {
      print('❌ Forgot password failed: $e');
      return {'message': 'If an account with that email exists, a password reset link has been sent.'};
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    try {
      final resetPasswordDto = ResetPasswordDto(token: token, password: password);
      
      final response = await _apiService.post(
        ApiConfig.resetPasswordEndpoint,
        data: resetPasswordDto.toJson(),
      );

      return response.data ?? {'message': 'Password reset successfully'};
    } catch (e) {
      print('❌ Reset password failed: $e');
      rethrow;
    }
  }

  // Verify Email
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _apiService.get(
        ApiConfig.verifyEmailEndpoint,
        queryParameters: {'token': token},
      );

      return response.data ?? {'message': 'Email verified successfully'};
    } catch (e) {
      print('❌ Email verification failed: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      await _tokenService.clearTokens();
    }
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    return await _tokenService.isAuthenticated();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    return await _tokenService.refreshToken();
  }
}
