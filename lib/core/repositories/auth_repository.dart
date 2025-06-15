
class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Login
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _tokenService.saveAuthResponse(authResponse);
    
    return authResponse;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    } finally {
      await _tokenService.clearTokens();
    }
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    return await _tokenService.isAuthenticated();
  }

  // Get current user
  Future<Employee?> getCurrentUser() async {
    final authResponse = await _tokenService.getAuthResponse();
    return authResponse?.employee;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    return await _tokenService.refreshToken();
  }
}
