import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/create_leave_dto.dart';
import 'package:employee_manegement/core/services/api_service.dart';


class LeaveRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> requestLeave(CreateLeaveDto data) async {
    final response = await _apiService.post(
      '${ApiConfig.baseUrl}/leave',
      data: data.toJson(),
    );
    return response.data;
  }
}