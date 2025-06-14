import 'package:employee_manegement/core/models/payroll.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


// Events
abstract class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object> get props => [];
}

class LoadPayrollHistory extends PayrollEvent {}

class LoadPayrollDetails extends PayrollEvent {
  final String payrollId;

  const LoadPayrollDetails({required this.payrollId});

  @override
  List<Object> get props => [payrollId];
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
  List<Object> get props => [payrolls];
}

class PayrollDetailsLoaded extends PayrollState {
  final Payroll payroll;

  const PayrollDetailsLoaded({required this.payroll});

  @override
  List<Object> get props => [payroll];
}

class PayrollError extends PayrollState {
  final String message;

  const PayrollError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  PayrollBloc() : super(PayrollInitial()) {
    on<LoadPayrollHistory>(_onLoadPayrollHistory);
    on<LoadPayrollDetails>(_onLoadPayrollDetails);
  }

  Future<void> _onLoadPayrollHistory(
    LoadPayrollHistory event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate dummy payroll data
      final payrolls = List.generate(6, (index) {
        final date = DateTime.now().subtract(Duration(days: 30 * index));
        return Payroll(
          id: 'payroll_${index + 1}',
          employeeId: 'EMP001',
          payPeriodStart: DateTime(date.year, date.month, 1),
          payPeriodEnd: DateTime(date.year, date.month + 1, 0),
          basicSalary: 6250.0,
          overtime: index % 2 == 0 ? 500.0 : 0.0,
          bonus: index == 0 ? 1000.0 : 0.0,
          deductions: 625.0,
          netPay: 6250.0 + (index % 2 == 0 ? 500.0 : 0.0) + (index == 0 ? 1000.0 : 0.0) - 625.0,
          status: index == 0 ? PayrollStatus.processed : PayrollStatus.paid,
          paidDate: index == 0 ? null : date,
        );
      });
      
      emit(PayrollHistoryLoaded(payrolls: payrolls));
    } catch (e) {
      emit(PayrollError(message: e.toString()));
    }
  }

  Future<void> _onLoadPayrollDetails(
    LoadPayrollDetails event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate dummy payroll details
      final payroll = Payroll(
        id: event.payrollId,
        employeeId: 'EMP001',
        payPeriodStart: DateTime.now().subtract(const Duration(days: 30)),
        payPeriodEnd: DateTime.now(),
        basicSalary: 6250.0,
        overtime: 500.0,
        bonus: 1000.0,
        deductions: 625.0,
        netPay: 7125.0,
        status: PayrollStatus.paid,
        paidDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      
      emit(PayrollDetailsLoaded(payroll: payroll));
    } catch (e) {
      emit(PayrollError(message: e.toString()));
    }
  }
}
