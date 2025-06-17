import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final int? id;
  final int employeeId;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final AttendanceStatus status;
  final String? notes;
  final Duration? workHours;

  const Attendance({
    this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    this.workHours,
  });

  // Helper to parse HH:mm time strings into DateTime for calculations
  static DateTime _parseTimeString(String time, DateTime baseDate) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  Duration? get totalWorkingTime {
    if (checkInTime != null && checkOutTime != null) {
      final checkIn = _parseTimeString(checkInTime!, date);
      final checkOut = _parseTimeString(checkOutTime!, date);
      return checkOut.difference(checkIn);
    }
    return workHours;
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employeeId'] ?? 0,
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      status: _parseAttendanceStatus(json['status']),
      notes: json['notes'],
      workHours:
          json['workHours'] != null ? Duration(hours: json['workHours']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      'status': status.name.toLowerCase(),
      if (notes != null) 'notes': notes,
      if (workHours != null) 'workHours': workHours!.inHours,
    };
  }

  static AttendanceStatus _parseAttendanceStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'half_day':
        return AttendanceStatus.half_day;
      case 'work_from_home':
        return AttendanceStatus.work_from_home;
      default:
        return AttendanceStatus.absent;
    }
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    date,
    checkInTime,
    checkOutTime,
    status,
    notes,
    workHours,
  ];
}

enum AttendanceStatus { present, absent, late, half_day, work_from_home }

class CreateAttendanceDto {
  final int employeeId;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? notes;
  final AttendanceStatus status;

  const CreateAttendanceDto({
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      if (notes != null) 'notes': notes,
      'status': status.name.toLowerCase(),
    };
  }
}
