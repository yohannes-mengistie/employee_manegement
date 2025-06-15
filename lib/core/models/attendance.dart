import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final int? id;
  final int employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final String? notes;
  final Duration? workingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Attendance({
    this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    this.workingHours,
    this.createdAt,
    this.updatedAt,
  });

  Duration? get totalWorkingTime {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return workingHours;
  }

  bool get isCheckedIn => checkInTime != null && checkOutTime == null;
  bool get isCheckedOut => checkInTime != null && checkOutTime != null;

  // JSON serialization to match your backend
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employeeId'] ?? 0,
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      status: _parseAttendanceStatus(json['status']),
      notes: json['notes'],
      workingHours: json['workingHours'] != null 
          ? Duration(minutes: json['workingHours']) 
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      if (checkInTime != null) 'checkInTime': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'checkOutTime': checkOutTime!.toIso8601String(),
      'status': status.name.toUpperCase(),
      if (notes != null) 'notes': notes,
      if (workingHours != null) 'workingHours': workingHours!.inMinutes,
    };
  }

  static AttendanceStatus _parseAttendanceStatus(String? statusString) {
    switch (statusString?.toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'ABSENT':
        return AttendanceStatus.absent;
      case 'LATE':
        return AttendanceStatus.late;
      case 'HALF_DAY':
        return AttendanceStatus.halfDay;
      case 'LEAVE':
        return AttendanceStatus.leave;
      default:
        return AttendanceStatus.absent;
    }
  }

  Attendance copyWith({
    int? id,
    int? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    String? notes,
    Duration? workingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
        workingHours,
        createdAt,
        updatedAt,
      ];
}

enum AttendanceStatus { present, absent, late, halfDay, leave }

// DTOs to match your backend
class CreateAttendanceDto {
  final int employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final String? notes;

  const CreateAttendanceDto({
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      if (checkInTime != null) 'checkInTime': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'checkOutTime': checkOutTime!.toIso8601String(),
      'status': status.name.toUpperCase(),
      if (notes != null) 'notes': notes,
    };
  }
}

class UpdateAttendanceDto {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus? status;
  final String? notes;

  const UpdateAttendanceDto({
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (checkInTime != null) data['checkInTime'] = checkInTime!.toIso8601String();
    if (checkOutTime != null) data['checkOutTime'] = checkOutTime!.toIso8601String();
    if (status != null) data['status'] = status!.name.toUpperCase();
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int halfDays;
  final int leaveDays;
  final double attendancePercentage;
  final Duration totalWorkingHours;
  final Duration averageWorkingHours;

  const AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.halfDays,
    required this.leaveDays,
    required this.attendancePercentage,
    required this.totalWorkingHours,
    required this.averageWorkingHours,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalDays: json['totalDays'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      halfDays: json['halfDays'] ?? 0,
      leaveDays: json['leaveDays'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0.0).toDouble(),
      totalWorkingHours: Duration(minutes: json['totalWorkingHours'] ?? 0),
      averageWorkingHours: Duration(minutes: json['averageWorkingHours'] ?? 0),
    );
  }
}
