import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceHistory extends AttendanceEvent {
  final String? monthYear;

  const LoadAttendanceHistory({this.monthYear});

  @override
  List<Object> get props => [monthYear ?? ''];
}

class LoadTodayAttendance extends AttendanceEvent {}

class LoadAttendanceStats extends AttendanceEvent {
  final String? startDate;
  final String? endDate;

  const LoadAttendanceStats({this.startDate, this.endDate});

  @override
  List<Object> get props => [startDate ?? '', endDate ?? ''];
}

class CheckIn extends AttendanceEvent {}

class CheckOut extends AttendanceEvent {
  final int attendanceId;

  const CheckOut({required this.attendanceId});

  @override
  List<Object> get props => [attendanceId];
}

class SearchAttendance extends AttendanceEvent {
  final String? startDate;
  final String? endDate;
  final AttendanceStatus? status;

  const SearchAttendance({this.startDate, this.endDate, this.status});

  @override
  List<Object> get props => [startDate ?? '', endDate ?? '', status ?? ''];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceDataLoaded extends AttendanceState {
  final List<Attendance> attendances;
  final Attendance? todayAttendance;
  final AttendanceStats? stats;

  const AttendanceDataLoaded({
    required this.attendances,
    this.todayAttendance,
    this.stats,
  });

  @override
  List<Object?> get props => [attendances, todayAttendance, stats];
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
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  
  List<Attendance> _attendanceHistory = [];
  Attendance? _todayAttendance;
  AttendanceStats? _stats;

  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<LoadTodayAttendance>(_onLoadTodayAttendance);
    on<LoadAttendanceStats>(_onLoadAttendanceStats);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    on<SearchAttendance>(_onSearchAttendance);
  }

  Future<void> _onLoadAttendanceHistory(
    LoadAttendanceHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    try {
      _attendanceHistory = await _attendanceRepository.getCurrentEmployeeAttendance(
        monthYear: event.monthYear,
      );
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
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
      _todayAttendance = await _attendanceRepository.getTodayAttendance();
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load today\'s attendance: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAttendanceStats(
    LoadAttendanceStats event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      _stats = await _attendanceRepository.getCurrentEmployeeAttendanceStats(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load attendance stats: ${e.toString()}'));
    }
  }

  Future<void> _onCheckIn(
    CheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    emit(AttendanceLoading());
    
    try {
      final attendance = await _attendanceRepository.checkIn();
      _todayAttendance = attendance;
      
      emit(AttendanceUpdated(
        attendance: attendance,
        message: 'Checked in successfully at ${_formatTime(attendance.checkInTime!)}',
      ));
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check in: ${e.toString()}'));
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onCheckOut(
    CheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    emit(AttendanceLoading());
    
    try {
      final attendance = await _attendanceRepository.checkOut(event.attendanceId);
      _todayAttendance = attendance;
      
      emit(AttendanceUpdated(
        attendance: attendance,
        message: 'Checked out successfully at ${_formatTime(attendance.checkOutTime!)}',
      ));
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check out: ${e.toString()}'));
      if (currentState is AttendanceDataLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onSearchAttendance(
    SearchAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    try {
      _attendanceHistory = await _attendanceRepository.searchAttendance(
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );
      
      emit(AttendanceDataLoaded(
        attendances: _attendanceHistory,
        todayAttendance: _todayAttendance,
        stats: _stats,
      ));
    } on ApiException catch (e) {
      emit(AttendanceError(message: e.message));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to search attendance: ${e.toString()}'));
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}
