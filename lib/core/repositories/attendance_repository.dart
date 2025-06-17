import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/attendance.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  Future<Attendance> createAttendance(CreateAttendanceDto dto) async {
    final response = await _apiService.post(
      ApiConfig.attendanceEndpoint,
      data: dto.toJson(),
    );
    return Attendance.fromJson(response.data);
  }

  Future<List<Attendance>> getCurrentEmployeeAttendance({
    String? monthYear,
  }) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final queryParams = <String, dynamic>{};
    if (monthYear != null) {
      queryParams['month'] = monthYear;
    }

    final response = await _apiService.get(
      '${ApiConfig.attendanceEmployeeEndpoint}/$employeeId',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  Future<Attendance> createAttendanceRecord({
    required DateTime date,
    required String checkInTime,
    required String checkOutTime,
    String? notes,
    required AttendanceStatus status,
  }) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final checkIn = DateFormat('HH:mm').parse(checkInTime);
    final checkOut = DateFormat('HH:mm').parse(checkOutTime);
    final fullCheckIn = DateTime(
      date.year,
      date.month,
      date.day,
      checkIn.hour,
      checkIn.minute,
    );
    final fullCheckOut = DateTime(
      date.year,
      date.month,
      date.day,
      checkOut.hour,
      checkOut.minute,
    );
    final workHours = fullCheckOut.difference(fullCheckIn).inHours;

    final dto = CreateAttendanceDto(
      employeeId: employeeId,
      date: date,
      checkInTime: DateFormat('HH:mm').format(fullCheckIn),
      checkOutTime: DateFormat('HH:mm').format(fullCheckOut),
      notes: notes,
      status: status,
    );

    final response = await _apiService.post(
      ApiConfig.attendanceEndpoint,
      data: {...dto.toJson(), 'workHours': workHours},
    );
    return Attendance.fromJson(response.data);
  }
}
