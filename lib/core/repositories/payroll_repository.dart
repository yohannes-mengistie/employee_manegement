import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/payroll.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class PayrollRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Get payroll data for a specific employee
  Future<List<Payroll>> getEmployeePayroll() async {
    final queryParams = {'employeeId': await _tokenService.getEmployeeId()};

    final response = await _apiService.get(
      ApiConfig.payrollEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Payroll.fromJson(json)).toList();
  }

  // Get payroll data with date range
  Future<List<Payroll>> getPayrollData({String? start, String? end}) async {
    final queryParams = <String, dynamic>{};
    if (start != null) queryParams['start'] = start;
    if (end != null) queryParams['end'] = end;

    final response = await _apiService.get(
      ApiConfig.payrollEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Payroll.fromJson(json)).toList();
  }

  // Get payroll history by year
  Future<List<Payroll>> getPayrollHistory({String? year}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;

    final response = await _apiService.get(
      ApiConfig.payrollHistoryEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Payroll.fromJson(json)).toList();
  }

  // Get payroll history for a specific employee
  Future<List<Payroll>> getEmployeePayrollHistory(
    int employeeId, {
    String? year,
  }) async {
    final queryParams = <String, dynamic>{'employeeId': employeeId.toString()};
    if (year != null) queryParams['year'] = year;

    final response = await _apiService.get(
      ApiConfig.payrollHistoryEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Payroll.fromJson(json)).toList();
  }

  // Helper method to get current employee payroll history
  Future<List<Payroll>> getCurrentEmployeePayrollHistory({String? year}) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getEmployeePayrollHistory(employeeId, year: year);
  }

  // Helper method to get current employee payslips
  Future<List<Payroll>> getCurrentEmployeePayslips() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getEmployeePayroll();
  }
}
