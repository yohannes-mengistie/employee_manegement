
class EmployeeRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Get employee profile by ID
  Future<Employee> getEmployeeProfile(int employeeId) async {
    final response = await _apiService.get(
      '${ApiConfig.profileEndpoint}/$employeeId',
    );

    return Employee.fromJson(response.data);
  }

  // Get current employee profile
  Future<Employee> getCurrentEmployeeProfile() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }
    
    return await getEmployeeProfile(employeeId);
  }

  // Update employee profile
  Future<Employee> updateEmployeeProfile(Employee employee) async {
    final response = await _apiService.put(
      ApiConfig.updateProfileEndpoint,
      data: employee.toJson(),
    );

    return Employee.fromJson(response.data);
  }

  // Update profile image
  Future<Employee> updateProfileImage(String imagePath) async {
    // This would typically involve uploading the image file
    // For now, we'll just update the profile with the image path
    final currentEmployee = await getCurrentEmployeeProfile();
    final updatedEmployee = currentEmployee.copyWith(profileImage: imagePath);
    
    return await updateEmployeeProfile(updatedEmployee);
  }
}
