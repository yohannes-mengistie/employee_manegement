import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/auth_response.dart';
import 'package:employee_manegement/core/services/jwt_service.dart';
import 'package:employee_manegement/core/services/storage_service.dart';


class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _authResponseKey = 'auth_response';

  // Save authentication response
  Future<void> saveAuthResponse(AuthResponse authResponse) async {
    await StorageService.setString(_tokenKey, authResponse.token);
    await StorageService.setString(_refreshTokenKey, authResponse.refreshToken);
    await StorageService.setString(_authResponseKey, jsonEncode(authResponse.toJson()));
  }

  // Get current token (access_token) with JWT validation
  Future<String?> getToken() async {
    final token = StorageService.getString(_tokenKey);
    if (token != null) {
      // Check if token is expired using JWT
      if (!JwtService.isTokenExpired(token)) {
        return token;
      } else {
        print('🔄 Token expired, attempting refresh...');
        // Token expired, try to refresh
        final refreshed = await refreshToken();
        if (refreshed) {
          return StorageService.getString(_tokenKey);
        }
      }
    }
    
    return null;
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return StorageService.getString(_refreshTokenKey);
  }

  // Get full auth response
  Future<AuthResponse?> getAuthResponse() async {
    final authResponseString = StorageService.getString(_authResponseKey);
    if (authResponseString != null) {
      try {
        final json = jsonDecode(authResponseString);
        return AuthResponse.fromJson(json);
      } catch (e) {
        print('Error parsing auth response: $e');
        return null;
      }
    }
    return null;
  }

  // Check if user is authenticated using JWT validation
  Future<bool> isAuthenticated() async {
    final token = StorageService.getString(_tokenKey);
    if (token != null) {
      return !JwtService.isTokenExpired(token);
    }
    return false;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio();
      
      final response = await dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.refreshTokenEndpoint}',
        data: {'access_token': refreshToken},
        options: Options(
          headers: {
            ...ApiConfig.defaultHeaders,
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData.containsKey('access_token')) {
          final newToken = responseData['access_token'] as String;
          
          // Update stored token
          await StorageService.setString(_tokenKey, newToken);
          await StorageService.setString(_refreshTokenKey, newToken);
          
          // Update auth response with new token
          final currentAuthResponse = await getAuthResponse();
          if (currentAuthResponse != null) {
            final newExpirationDate = JwtService.getExpirationDate(newToken) ?? 
                                     DateTime.now().add(const Duration(hours: 24));
            
            final updatedAuthResponse = AuthResponse(
              token: newToken,
              refreshToken: newToken,
              employee: currentAuthResponse.employee,
              expiresAt: newExpirationDate,
            );
            
            await saveAuthResponse(updatedAuthResponse);
            return true;
          }
        }
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    
    return false;
  }


  // Clear all tokens
  Future<void> clearTokens() async {
    await StorageService.remove(_tokenKey);
    await StorageService.remove(_refreshTokenKey);
    await StorageService.remove(_authResponseKey);
  }

  // Get employee ID from JWT token
  Future<int?> getEmployeeId() async {
    final token = StorageService.getString(_tokenKey);
    if (token != null) {
      return JwtService.getUserId(token);
    }
    return null;
  }

  // Get tenant ID from JWT token
  Future<int?> getTenantId() async {
    final token = StorageService.getString(_tokenKey);
    if (token != null) {
      return JwtService.getTenantId(token);
    }
    return null;
  }
}
