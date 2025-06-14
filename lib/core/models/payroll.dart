import 'package:equatable/equatable.dart';

class Payroll extends Equatable {
  final String id;
  final String employeeId;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double basicSalary;
  final double overtime;
  final double bonus;
  final double deductions;
  final double netPay;
  final PayrollStatus status;
  final DateTime? paidDate;

  const Payroll({
    required this.id,
    required this.employeeId,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.basicSalary,
    required this.overtime,
    required this.bonus,
    required this.deductions,
    required this.netPay,
    required this.status,
    this.paidDate,
  });

  double get grossPay => basicSalary + overtime + bonus;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        payPeriodStart,
        payPeriodEnd,
        basicSalary,
        overtime,
        bonus,
        deductions,
        netPay,
        status,
        paidDate,
      ];
}

enum PayrollStatus { pending, processed, paid }
