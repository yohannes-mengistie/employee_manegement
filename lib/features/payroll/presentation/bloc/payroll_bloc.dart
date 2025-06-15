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

class LoadPayrollDetails extends PayrollEvent {
  final String payrollId;

  const LoadPayrollDetails({required this.payrollId});

  @override
  List<Object> get props => [payrollId];
}

class LoadPayrollSummary extends PayrollEvent {
  final int? month;
  final int? year;

  const LoadPayrollSummary({this.month, this.year});

  @override
  List<Object> get props => [month ?? 0, year ?? 0];
}

class LoadPayslips extends PayrollEvent {}

class LoadPayslipDetails extends PayrollEvent {
  final int payslipId;

  const LoadPayslipDetails({required this.payslipId});

  @override
  List<Object> get props => [payslipId];
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
  final PayrollSummary? summary;

  const PayrollHistoryLoaded({
    required this.payrolls,
    this.summary,
  });

  @override
  List<Object?> get props => [payrolls, summary];
}

class PayrollDetailsLoaded extends PayrollState {
  final Payroll payroll;

  const PayrollDetailsLoaded({required this.payroll});

  @override
  List<Object> get props => [payroll];
}

class PayslipDetailsLoaded extends PayrollState {
  final PayslipDetail payslipDetail;

  const PayslipDetailsLoaded({required this.payslipDetail});

  @override
  List<Object> get props => [payslipDetail];
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
    on<LoadPayrollDetails>(_onLoadPayrollDetails);
    on<LoadPayrollSummary>(_onLoadPayrollSummary);
    on<LoadPayslips>(_onLoadPayslips);
    on<LoadPayslipDetails>(_onLoadPayslipDetails);
  }

  Future<void> _onLoadPayrollHistory(
    LoadPayrollHistory event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      // Load both payroll history and summary
      final payrolls = await _payrollRepository.getCurrentEmployeePayrollHistory(
        year: event.year,
      );
      
      PayrollSummary? summary;
      try {
        summary = await _payrollRepository.getPayrollSummary(
          year: event.year != null ? int.tryParse(event.year!) : null,
        );
      } catch (e) {
        // Continue without summary if it fails
        print('Failed to load payroll summary: $e');
      }
      
      emit(PayrollHistoryLoaded(payrolls: payrolls, summary: summary));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payroll history: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPayrollDetails(
    LoadPayrollDetails event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      // For backward compatibility, create a dummy payroll
      // In a real implementation, you'd fetch from your backend
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
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payroll details: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPayrollSummary(
    LoadPayrollSummary event,
    Emitter<PayrollState> emit,
  ) async {
    try {
      final summary = await _payrollRepository.getPayrollSummary(
        month: event.month,
        year: event.year,
      );
      
      // Convert summary to payroll list for compatibility
      final payrolls = <Payroll>[];
      
      emit(PayrollHistoryLoaded(payrolls: payrolls, summary: summary));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payroll summary: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPayslips(
    LoadPayslips event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      final payrolls = await _payrollRepository.getCurrentEmployeePayslips();
      emit(PayrollHistoryLoaded(payrolls: payrolls));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payslips: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPayslipDetails(
    LoadPayslipDetails event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    
    try {
      final payslipDetail = await _payrollRepository.getPayslipDetails(event.payslipId);
      emit(PayslipDetailsLoaded(payslipDetail: payslipDetail));
    } on ApiException catch (e) {
      emit(PayrollError(message: e.message));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payslip details: ${e.toString()}'));
    }
  }
}
