
import 'package:employee_manegement/core/models/create_leave_dto.dart';
import 'package:employee_manegement/core/repositories/leave_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object> get props => [];
}

class SubmitLeave extends LeaveEvent {
  final CreateLeaveDto leaveDto;

  const SubmitLeave({required this.leaveDto});

  @override
  List<Object> get props => [leaveDto];
}

abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveSuccess extends LeaveState {
  final Map<String, dynamic> response;

  const LeaveSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _leaveRepository;

  LeaveBloc({LeaveRepository? leaveRepository})
      : _leaveRepository = leaveRepository ?? LeaveRepository(),
        super(LeaveInitial()) {
    on<SubmitLeave>(_onSubmitLeave);
  }

  Future<void> _onSubmitLeave(SubmitLeave event, Emitter<LeaveState> emit) async {
    emit(LeaveLoading());
    try {
      final response = await _leaveRepository.requestLeave(event.leaveDto);
      emit(LeaveSuccess(response: response));
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }
}