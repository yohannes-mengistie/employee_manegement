import 'package:employee_manegement/core/models/attendance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceHistory extends AttendanceEvent {}

class CheckIn extends AttendanceEvent {}

class CheckOut extends AttendanceEvent {}

class LoadTodayAttendance extends AttendanceEvent {}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<Attendance> attendances;

  const AttendanceHistoryLoaded({required this.attendances});

  @override
  List<Object> get props => [attendances];
}

class TodayAttendanceLoaded extends AttendanceState {
  final Attendance? todayAttendance;

  const TodayAttendanceLoaded({this.todayAttendance});

  @override
  List<Object?> get props => [todayAttendance];
}

class AttendanceDataLoaded extends AttendanceState {
  final List<Attendance> attendances;
  final Attendance? todayAttendance;

  const AttendanceDataLoaded({
    required this.attendances,
    this.todayAttendance,
  });

  @override
  List<Object?> get props => [attendances, todayAttendance];
}

class AttendanceUpdated extends AttendanceState {
  final Attendance attendance;
  final String message;

  const AttendanceUpdated({
    required this.attendance,
    required this.message,
  });

  @override
  List<Object> get props => [attendance, message];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];

  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<LoadTodayAttendance>(_onLoadTodayAttendance);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
  }

  Future<void> _onLoadAttendanceHistory(
    LoadAttendanceHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate dummy attendance data for the last 30 days
      final attendances = <Attendance>[];
      final now = DateTime.now();
      
      for (int i = 1; i <= 30; i++) {
        final date = now.subtract(Duration(days: i));
        
        // Skip weekends
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          continue;
        }
        
        final checkInTime = DateTime(
          date.year,
          date.month,
          date.day,
          8 + (i % 3), // Vary check-in time between 8-10 AM
          (i * 15) % 60,
        );
        
        final checkOutTime = DateTime(
          date.year,
          date.month,
          date.day,
          17 + (i % 2), // Vary check-out time between 17-18 PM
          (i * 20) % 60,
        );
        
        attendances.add(
          Attendance(
            id: 'attendance_$i',
            employeeId: 'EMP001',
            date: date,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            status: _getAttendanceStatus(checkInTime, checkOutTime),
          ),
        );
      }
      
      _attendanceHistory = attendances;
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
      ));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load attendance history: ${e.toString()}'));
    }
  }


  Future<void> _onLoadTodayAttendance(
    LoadTodayAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For demo purposes, we'll start with no attendance for today
      // In a real app, this would check the backend for existing attendance
      _todayAttendance = null;
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
      ));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load today\'s attendance: ${e.toString()}'));
    }
  }

  Future<void> _onCheckIn(
    CheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    // Store current state
    final currentState = state;
    emit(AttendanceLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      _todayAttendance = Attendance(
        id: 'attendance_today',
        employeeId: 'EMP001',
        date: today,
        checkInTime: now,
        checkOutTime: null,
        status: _getAttendanceStatus(now, null),
      );
      
      emit(AttendanceUpdated(
        attendance: _todayAttendance!,
        message: 'Checked in successfully at ${_formatTime(now)}',
      ));
      
      // Return to data loaded state
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
      ));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check in: ${e.toString()}'));
      // Restore previous state on error
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onCheckOut(
    CheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    if (_todayAttendance == null || _todayAttendance!.checkInTime == null) {
      emit(const AttendanceError(message: 'Please check in first'));
      return;
    }

    // Store current state
    final currentState = state;
    emit(AttendanceLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      
      _todayAttendance = _todayAttendance!.copyWith(
        checkOutTime: now,
        status: _getAttendanceStatus(_todayAttendance!.checkInTime!, now),
      );
      
      emit(AttendanceUpdated(
        attendance: _todayAttendance!,
        message: 'Checked out successfully at ${_formatTime(now)}',
      ));
      
      // Return to data loaded state
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
      ));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check out: ${e.toString()}'));
      // Restore previous state on error
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    }
  }

  AttendanceStatus _getAttendanceStatus(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null) return AttendanceStatus.absent;
    
    // Consider late if check-in is after 9:30 AM
    final lateThreshold = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
      9,
      30,
    );
    
    if (checkIn.isAfter(lateThreshold)) {
      return AttendanceStatus.late;
    }
    
    return AttendanceStatus.present;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
