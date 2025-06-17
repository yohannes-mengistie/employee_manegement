import 'package:employee_manegement/core/exceptions/api_exceptions.dart';
import 'package:employee_manegement/core/models/payroll.dart';
import 'package:employee_manegement/core/repositories/payroll_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object> get props => [];
}

class LoadPayrollHistory extends PayrollEvent {
  final String? year;

  const LoadPayrollHistory({this.year});

  @override
  List<Object> get props => [year ?? ''];
}

class LoadEmployeePayroll extends PayrollEvent {
  const LoadEmployeePayroll();

  @override
  List<Object> get props => [];
}

// States
abstract class PayrollState extends Equatable {
  const PayrollState();

  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {}

class PayrollLoading extends PayrollState {}

class PayrollHistoryLoaded extends PayrollState {
  final List<Payroll> payrolls;

  const PayrollHistoryLoaded({required this.payrolls});

  @override
  List<Object?> get props => [payrolls];
}

class PayrollError extends PayrollState {
  final String message;

  const PayrollError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  final PayrollRepository _payrollRepository = PayrollRepository();

  PayrollBloc() : super(PayrollInitial()) {
    on<LoadPayrollHistory>(_onLoadPayrollHistory);
    on<LoadEmployeePayroll>(_onLoadEmployeePayroll);
  }

  Future<void> _onLoadPayrollHistory(
    LoadPayrollHistory event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());

    try {
      final payrolls = await _payrollRepository
          .getCurrentEmployeePayrollHistory(year: event.year);
      emit(PayrollHistoryLoaded(payrolls: payrolls));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(
        PayrollError(
          message: 'Failed to load payroll history: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadEmployeePayroll(
    LoadEmployeePayroll event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());

    try {
      final payrolls = await _payrollRepository.getEmployeePayroll();
      emit(PayrollHistoryLoaded(payrolls: payrolls));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(
        PayrollError(
          message: 'Failed to load employee payroll: ${e.toString()}',
        ),
      );
    }
  }
}
