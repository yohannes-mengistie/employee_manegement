class ApiConfig {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://backend-r944.onrender.com/';
  
  // Auth Endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String verifyEmailEndpoint = '/auth/verify-email';
  static const String refreshTokenEndpoint = '/auth/refresh'; 
  static const String logoutEndpoint = '/auth/logout'; 
  
  // Employee Endpoints 
  static const String employeeEndpoint = '/employee';
  static const String employeeSearchEndpoint = '/employee/search';
  static const String employeeStatsEndpoint = '/employee/{id}/stats';
  static const String employeeDepartmentEndpoint = '/employee/department';
  static const String employeeStatusEndpoint = '/employee/{id}/status';
  static const String employeeBulkStatusEndpoint = '/employee/bulk-status';
  static const String employeeTransferEndpoint = '/employee/transfer';
  
  // User Endpoints 
  static const String userEndpoint = '/user';
  static const String userMeEndpoint = '/user/me';
  static const String userRoleEndpoint = '/user/role';
  
  // Profile Endpoints (using employee endpoints)
  static const String profileEndpoint = '/employee';
  static const String updateProfileEndpoint = '/employee';
  
  // Payroll Endpoints 
  static const String payrollEndpoint = '/payroll';
  static const String payrollHistoryEndpoint = '/payroll/history';
  static const String payrollSummaryEndpoint = '/payroll/summary';
  static const String payslipEndpoint = '/payroll/payslip';
  static const String payslipDetailEndpoint = '/payroll/payslip-detail';
  static const String payrollSettingEndpoint = '/payroll';
  
  // Tax Endpoints
  static const String taxRuleEndpoint = '/tax-rule';
  
  // Payroll Item Endpoints
  static const String payrollItemEndpoint = '/payroll-item';
  
  // Attendance Endpoints 
  static const String attendanceEndpoint = '/attendance';
  static const String attendanceBulkEndpoint = '/attendance/bulk';
  static const String attendanceBulkMarkEndpoint = '/attendance/bulk-mark';
  static const String attendanceSearchEndpoint = '/attendance/search';
  static const String attendanceEmployeeEndpoint = '/attendance/employee';
  static const String attendanceStatsEndpoint = '/attendance/employee/{employeeId}/stats';
  static const String attendanceDepartmentEndpoint = '/attendance/department';
  static const String attendanceSummaryEndpoint = '/attendance/summary';
  static const String attendanceEmployeeEndPoint = '/attendance/employee/{employeeId}';
  
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
