import 'package:employee_manegement/core/exceptions/api_exceptions.dart';
import 'package:employee_manegement/core/models/attendance.dart';
import 'package:employee_manegement/core/repositories/attendance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceHistory extends AttendanceEvent {
  final String? monthYear;

  const LoadAttendanceHistory({this.monthYear});

  @override
  List<Object?> get props => [monthYear ?? ''];
}

class AddAttendance extends AttendanceEvent {
  final DateTime date;
  final String checkInTime;
  final String checkOutTime;
  final String? notes;
  final String status;

  const AddAttendance({
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [date, checkInTime, checkOutTime, notes, status];
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceDataLoaded extends AttendanceState {
  final List<Attendance> attendances;

  const AttendanceDataLoaded({required this.attendances});

  @override
  List<Object?> get props => [attendances];
}

class AttendanceUpdated extends AttendanceState {
  final Attendance attendance;
  final String message;

  const AttendanceUpdated({required this.attendance, required this.message});

  @override
  List<Object?> get props => [attendance, message];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  List<Attendance> _attendanceHistory = [];

  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<AddAttendance>(_onAddAttendance);
  }

  Future<void> _onLoadAttendanceHistory(
    LoadAttendanceHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      _attendanceHistory = await _attendanceRepository
          .getCurrentEmployeeAttendance(monthYear: event.monthYear);
      emit(AttendanceDataLoaded(attendances: _attendanceHistory));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
    } catch (e) {
      emit(
        AttendanceError(
          message: 'Failed to load attendance history: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddAttendance(
    AddAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    emit(AttendanceLoading());
    try {
      final status = _parseAttendanceStatus(event.status);
      final attendance = await _attendanceRepository.createAttendanceRecord(
        date: event.date,
        checkInTime: event.checkInTime,
        checkOutTime: event.checkOutTime,
        notes: event.notes,
        status: status,
      );
      _attendanceHistory = [attendance, ..._attendanceHistory];
      emit(
        AttendanceUpdated(
          attendance: attendance,
          message:
              'Attendance recorded successfully for ${_formatDate(event.date)}',
        ),
      );
      emit(AttendanceDataLoaded(attendances: _attendanceHistory));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(
        AttendanceError(message: 'Failed to add attendance: ${e.toString()}'),
      );
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    }
  }

  AttendanceStatus _parseAttendanceStatus(String status) {
    switch (status.toLowerCase()) {
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
        throw Exception('Invalid attendance status: $status');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}
