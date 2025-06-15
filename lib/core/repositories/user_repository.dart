

import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/employee_dto.dart';
import 'package:employee_manegement/core/services/api_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  // Role management
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    final response = await _apiService.get(ApiConfig.userRoleEndpoint);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createRole(CreateRoleDto dto) async {
    final response = await _apiService.post(
      ApiConfig.userRoleEndpoint,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateRole(int id, UpdateRoleDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.userRoleEndpoint}/$id',
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<void> deleteRole(int id) async {
    await _apiService.delete('${ApiConfig.userRoleEndpoint}/$id');
  }

  // User management
  Future<Map<String, dynamic>> createUser(CreateUserDto dto) async {
    final response = await _apiService.post(
      ApiConfig.userEndpoint,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _apiService.get(ApiConfig.userEndpoint);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await _apiService.get('${ApiConfig.userEndpoint}/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(int id, UpdateUserDto dto) async {
    final response = await _apiService.put(
      '${ApiConfig.userEndpoint}/$id',
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<void> deleteUser(int id) async {
    await _apiService.delete('${ApiConfig.userEndpoint}/$id');
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiService.get(ApiConfig.userMeEndpoint);
    return response.data;
  }
}
