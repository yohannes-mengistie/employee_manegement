class ApiConfig {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://your-backend-api.com/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/employee/profile';
  static const String updateProfileEndpoint = '/employee/update';
  static const String attendanceEndpoint = '/attendance';
  static const String payrollEndpoint = '/payroll';
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
