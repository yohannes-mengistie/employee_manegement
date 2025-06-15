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
   factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      payPeriodStart: DateTime.parse(json['payPeriodStart']),
      payPeriodEnd: DateTime.parse(json['payPeriodEnd']),
      basicSalary: (json['basicSalary'] as num).toDouble(),
      overtime: (json['overtime'] as num).toDouble(),
      bonus: (json['bonus'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      netPay: (json['netPay'] as num).toDouble(),
      status: _parsePayrollStatus(json['status']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'payPeriodStart': payPeriodStart.toIso8601String(),
      'payPeriodEnd': payPeriodEnd.toIso8601String(),
      'basicSalary': basicSalary,
      'overtime': overtime,
      'bonus': bonus,
      'deductions': deductions,
      'netPay': netPay,
      'status': status.name.toUpperCase(),
      if (paidDate != null) 'paidDate': paidDate!.toIso8601String(),
    };
  }
  static PayrollStatus _parsePayrollStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PayrollStatus.pending;
      case 'processed':
        return PayrollStatus.processed;
      case 'paid':
        return PayrollStatus.paid;
      default:
        throw ArgumentError('Invalid payroll status: $status');
    }
  }
   // Add copyWith method for easier updates
  Payroll copyWith({
    String? id,
    String? employeeId,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    double? basicSalary,
    double? overtime,
    double? bonus,
    double? deductions,
    double? netPay,
    PayrollStatus? status,
    DateTime? paidDate,
  }) {
    return Payroll(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      basicSalary: basicSalary ?? this.basicSalary,
      overtime: overtime ?? this.overtime,
      bonus: bonus ?? this.bonus,
      deductions: deductions ?? this.deductions,
      netPay: netPay ?? this.netPay,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
    );
  }


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
