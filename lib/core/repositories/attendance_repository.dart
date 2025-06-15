
import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/models/attendance.dart';
import 'package:employee_manegement/core/services/api_service.dart';
import 'package:employee_manegement/core/services/token_service.dart';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  // Create attendance record
  Future<Attendance> createAttendance(CreateAttendanceDto dto) async {
    final response = await _apiService.post(
      ApiConfig.attendanceEndpoint,
      data: dto.toJson(),
    );

    return Attendance.fromJson(response.data);
  }

  // Update attendance record
  Future<Attendance> updateAttendance(int id, UpdateAttendanceDto dto) async {
    final response = await _apiService.patch(
      '${ApiConfig.attendanceEndpoint}/$id',
      data: dto.toJson(),
    );

    return Attendance.fromJson(response.data);
  }

  // Delete attendance record
  Future<void> deleteAttendance(int id) async {
    await _apiService.delete('${ApiConfig.attendanceEndpoint}/$id');
  }

  // Get all attendances for a specific date
  Future<List<Attendance>> getAttendances({String? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) {
      queryParams['date'] = date;
    }

    final response = await _apiService.get(
      ApiConfig.attendanceEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  // Get employee attendance for a specific month
  Future<List<Attendance>> getEmployeeAttendance(
    int employeeId, {
    String? monthYear,
  }) async {
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

  // Get current employee attendance
  Future<List<Attendance>> getCurrentEmployeeAttendance({String? monthYear}) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getEmployeeAttendance(employeeId, monthYear: monthYear);
  }

  // Get employee attendance stats
  Future<AttendanceStats> getEmployeeAttendanceStats(
    int employeeId, {
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiService.get(
      ApiConfig.attendanceStatsEndpoint.replaceAll('{employeeId}', employeeId.toString()),
      queryParameters: queryParams,
    );

    return AttendanceStats.fromJson(response.data);
  }

  // Get current employee attendance stats
  Future<AttendanceStats> getCurrentEmployeeAttendanceStats({
    String? startDate,
    String? endDate,
  }) async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    return await getEmployeeAttendanceStats(
      employeeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Search attendance records
  Future<List<Attendance>> searchAttendance({
    int? employeeId,
    String? startDate,
    String? endDate,
    AttendanceStatus? status,
    int? departmentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (employeeId != null) queryParams['employeeId'] = employeeId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (status != null) queryParams['status'] = status.name.toUpperCase();
    if (departmentId != null) queryParams['departmentId'] = departmentId;

    final response = await _apiService.get(
      ApiConfig.attendanceSearchEndpoint,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  // Get department attendance
  Future<List<Attendance>> getDepartmentAttendance(
    int departmentId, {
    String? date,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;

    final response = await _apiService.get(
      '${ApiConfig.attendanceDepartmentEndpoint}/$departmentId',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  // Get attendance summary
  Future<Map<String, dynamic>> getAttendanceSummary({String? monthYear}) async {
    final queryParams = <String, dynamic>{};
    if (monthYear != null) queryParams['monthYear'] = monthYear;

    final response = await _apiService.get(
      ApiConfig.attendanceSummaryEndpoint,
      queryParameters: queryParams,
    );

    return response.data;
  }

  // Check in
  Future<Attendance> checkIn() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dto = CreateAttendanceDto(
      employeeId: employeeId,
      date: today,
      checkInTime: now,
      status: _determineAttendanceStatus(now),
    );

    return await createAttendance(dto);
  }

  // Check out
  Future<Attendance> checkOut(int attendanceId) async {
    final now = DateTime.now();

    final dto = UpdateAttendanceDto(
      checkOutTime: now,
    );

    return await updateAttendance(attendanceId, dto);
  }

  // Get today's attendance for current employee
  Future<Attendance?> getTodayAttendance() async {
    final employeeId = await _tokenService.getEmployeeId();
    if (employeeId == null) {
      throw Exception('Employee ID not found in token');
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    try {
      final attendances = await searchAttendance(
        employeeId: employeeId,
        startDate: today,
        endDate: today,
      );

      return attendances.isNotEmpty ? attendances.first : null;
    } catch (e) {
      return null;
    }
  }

  // Determine attendance status based on check-in time
  AttendanceStatus _determineAttendanceStatus(DateTime checkInTime) {
    final lateThreshold = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      9, // 9:00 AM
      30, // 30 minutes
    );

    if (checkInTime.isAfter(lateThreshold)) {
      return AttendanceStatus.late;
    }

    return AttendanceStatus.present;
  }

  // Bulk create attendance (for admin use)
  Future<List<Attendance>> bulkCreateAttendance(List<CreateAttendanceDto> dtos) async {
    final response = await _apiService.post(
      ApiConfig.attendanceBulkEndpoint,
      data: {'attendances': dtos.map((dto) => dto.toJson()).toList()},
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  // Bulk mark attendance (for admin use)
  Future<List<Attendance>> markBulkAttendance(
    List<int> employeeIds,
    String date,
    AttendanceStatus status,
  ) async {
    final response = await _apiService.post(
      ApiConfig.attendanceBulkMarkEndpoint,
      data: {
        'employeeIds': employeeIds,
        'date': date,
        'status': status.name.toUpperCase(),
      },
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }
}
