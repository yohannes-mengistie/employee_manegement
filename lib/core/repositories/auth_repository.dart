

class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Login - Updated to use LoginDto
  Future<AuthResponse> login(String email, String password) async {
    final loginDto = LoginDto(email: email, password: password);
    
    final response = await _apiService.post(
      ApiConfig.loginEndpoint,
      data: loginDto.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _tokenService.saveAuthResponse(authResponse);
    
    return authResponse;
  }

  // Register - New method to match your backend
  Future<AuthResponse> register(RegisterDto registerDto) async {
    final response = await _apiService.post(
      ApiConfig.registerEndpoint,
      data: registerDto.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _tokenService.saveAuthResponse(authResponse);
    
    return authResponse;
  }

  // Forgot Password - New method
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final forgotPasswordDto = ForgotPasswordDto(email: email);
    
    final response = await _apiService.post(
      ApiConfig.forgotPasswordEndpoint,
      data: forgotPasswordDto.toJson(),
    );

    return response.data;
  }

  // Reset Password - New method
  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    final resetPasswordDto = ResetPasswordDto(token: token, password: password);
    
    final response = await _apiService.post(
      ApiConfig.resetPasswordEndpoint,
      data: resetPasswordDto.toJson(),
    );

    return response.data;
  }

  // Verify Email - New method
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await _apiService.get(
      ApiConfig.verifyEmailEndpoint,
      queryParameters: {'token': token},
    );

    return response.data;
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
