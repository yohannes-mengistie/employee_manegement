

import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/payroll.dart';
import 'package:employee_manegement/core/models/payroll_dto.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class PayrollRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

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

  // Get payroll summary
  Future<PayrollSummary> getPayrollSummary({int? month, int? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    final response = await _apiService.get(
      ApiConfig.payrollSummaryEndpoint,
      queryParameters: queryParams,
    );

    return PayrollSummary.fromJson(response.data);
  }

  // Get payslips
  Future<List<Payroll>> getPayslips() async {
    final response = await _apiService.get(ApiConfig.payslipEndpoint);

    final List<dynamic> data = response.data;
    return data.map((json) => Payroll.fromJson(json)).toList();
  }

  // Get payslip details by ID
  Future<PayslipDetail> getPayslipDetails(int id) async {
    final response = await _apiService.get(
      '${ApiConfig.payslipDetailEndpoint}/$id',
    );

    return PayslipDetail.fromJson(response.data);
  }

  // Get payroll settings
  Future<Map<String, dynamic>> getPayrollSettings() async {
    final response = await _apiService.get(ApiConfig.payrollSettingEndpoint);
    return response.data;
  }

  // Create or update payroll settings
  Future<Map<String, dynamic>> createOrUpdatePayrollSettings(
    CreatePayrollSettingDto dto,
  ) async {
    final response = await _apiService.post(
      ApiConfig.payrollSettingEndpoint,
      data: dto.toJson(),
    );

    return response.data;
  }

  // Create payroll item
  Future<PayrollItem> createPayrollItem(CreatePayrollItemDto dto) async {
    final response = await _apiService.post(
      ApiConfig.payrollItemEndpoint,
      data: dto.toJson(),
    );

    return PayrollItem.fromJson(response.data);
  }

  // Get payroll items for a specific payroll
  Future<List<PayrollItem>> getPayrollItems(int payrollId) async {
    final response = await _apiService.get(
      '${ApiConfig.payrollItemEndpoint}/payroll/$payrollId',
    );

    final List<dynamic> data = response.data;
    return data.map((json) => PayrollItem.fromJson(json)).toList();
  }

  // Update payroll item
  Future<PayrollItem> updatePayrollItem(int id, CreatePayrollItemDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.payrollItemEndpoint}/$id',
      data: dto.toJson(),
    );

    return PayrollItem.fromJson(response.data);
  }

  // Helper method to get current employee payroll history
  Future<List<Payroll>> getCurrentEmployeePayrollHistory({String? year}) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    // Filter by current employee if the backend supports it
    return await getPayrollHistory(year: year);
  }

  // Helper method to get current employee payslips
  Future<List<Payroll>> getCurrentEmployeePayslips() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getPayslips();
  }
}
