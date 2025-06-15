import 'dart:convert';

import 'package:dio/dio.dart';


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

  // Get current token
  Future<String?> getToken() async {
    final authResponse = await getAuthResponse();
    if (authResponse != null && !authResponse.isExpired) {
      return authResponse.token;
    }
    
    // Token expired, try to refresh
    final refreshed = await refreshToken();
    if (refreshed) {
      final newAuthResponse = await getAuthResponse();
      return newAuthResponse?.token;
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

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final authResponse = await getAuthResponse();
    return authResponse != null && !authResponse.isExpired;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.refreshTokenEndpoint}',
        data: {'refreshToken': refreshToken},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await saveAuthResponse(authResponse);
        return true;
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

  // Get employee ID from token
  Future<int?> getEmployeeId() async {
    final authResponse = await getAuthResponse();
    return authResponse?.employee.employeeId;
  }

  // Get tenant ID from token
  Future<int?> getTenantId() async {
    final authResponse = await getAuthResponse();
    return authResponse?.employee.tenantId;
  }
}
