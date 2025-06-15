

import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/employee.dart';
import 'package:employee_manegement/core/models/employee_dto.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Create employee
  Future<Employee> createEmployee(CreateEmployeeDto dto) async {
    final response = await _apiService.post(
      ApiConfig.employeeEndpoint,
      data: dto.toJson(),
    );

    return Employee.fromJson(response.data);
  }

  // Search employees
  Future<List<Employee>> searchEmployees(SearchEmployeeDto dto) async {
    final response = await _apiService.get(
      ApiConfig.employeeSearchEndpoint,
      queryParameters: dto.toJson(),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Get all employees
  Future<List<Employee>> getAllEmployees({
    int? companyId,
    String? isActive,
  }) async {
    final queryParams = <String, dynamic>{};
    if (companyId != null) queryParams['companyId'] = companyId;
    if (isActive != null) queryParams['isActive'] = isActive;

    final response = await _apiService.get(
      ApiConfig.employeeEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Get employee by ID
  Future<Employee> getEmployeeById(int id) async {
    final response = await _apiService.get(
      '${ApiConfig.employeeEndpoint}/$id',
    );

    return Employee.fromJson(response.data);
  }

  // Get current employee profile (using /user/me endpoint)
  Future<Employee> getCurrentEmployeeProfile() async {
    final response = await _apiService.get(ApiConfig.userMeEndpoint);
    print("//////////////////////////////////////${response.data}");
    return Employee.fromJson(response.data);
  }

  // Get employee stats
  Future<EmployeeStats> getEmployeeStats(int id) async {
    final response = await _apiService.get(
      ApiConfig.employeeStatsEndpoint.replaceAll('{id}', id.toString()),
    );

    return EmployeeStats.fromJson(response.data);
  }

  // Get current employee stats
  Future<EmployeeStats> getCurrentEmployeeStats() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getEmployeeStats(employeeId);
  }

  // Get department employees
  Future<List<Employee>> getDepartmentEmployees(int departmentId) async {
    final response = await _apiService.get(
      '${ApiConfig.employeeDepartmentEndpoint}/$departmentId',
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Update employee
  Future<Employee> updateEmployee(int id, UpdateEmployeeDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.employeeEndpoint}/$id',
      data: dto.toJson(),
    );

    return Employee.fromJson(response.data);
  }

  // Update current employee profile
  Future<Employee> updateCurrentEmployeeProfile(Employee employee) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final dto = UpdateEmployeeDto(
      firstName: employee.firstName,
      lastName: employee.lastName,
      email: employee.email,
      phone: employee.phone,
      address: employee.address,
      dateOfBirth: employee.dateOfBirth,
      gender: employee.gender.name,
      departmentId: employee.departmentId,
      position: employee.position,
      salary: employee.salary,
      profileImage: employee.profileImage,
    );

    return await updateEmployee(employeeId, dto);
  }

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    await _apiService.delete('${ApiConfig.employeeEndpoint}/$id');
  }

  // Toggle employee status
  Future<Employee> toggleEmployeeStatus(int id, EmployeeStatus status) async {
    final response = await _apiService.patch(
      ApiConfig.employeeStatusEndpoint.replaceAll('{id}', id.toString()),
      data: {'status': status.name},
    );

    return Employee.fromJson(response.data);
  }

  // Bulk update employee status
  Future<List<Employee>> bulkUpdateEmployeeStatus(
    List<int> employeeIds,
    EmployeeStatus status,
  ) async {
    final response = await _apiService.post(
      ApiConfig.employeeBulkStatusEndpoint,
      data: {
        'employeeIds': employeeIds,
        'status': status.name,
      },
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Transfer employees
  Future<List<Employee>> transferEmployees(
    int fromDepartmentId,
    int toDepartmentId,
    List<int> employeeIds,
  ) async {
    final response = await _apiService.post(
      ApiConfig.employeeTransferEndpoint,
      data: {
        'fromDepartmentId': fromDepartmentId,
        'toDepartmentId': toDepartmentId,
        'employeeIds': employeeIds,
      },
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Update profile image
  Future<Employee> updateProfileImage(String imagePath) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final dto = UpdateEmployeeDto(profileImage: imagePath);
    return await updateEmployee(employeeId, dto);
  }
}
