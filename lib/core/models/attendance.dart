import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final String? notes;
  final Duration? workingHours;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    this.workingHours,
  });

  Duration? get totalWorkingTime {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  bool get isCheckedIn => checkInTime != null && checkOutTime == null;
  bool get isCheckedOut => checkInTime != null && checkOutTime != null;

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    String? notes,
    Duration? workingHours,
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
      ];
}

enum AttendanceStatus { present, absent, late, halfDay, leave }
