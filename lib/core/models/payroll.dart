import 'package:equatable/equatable.dart';

class Department extends Equatable {
  final int id;
  final int tenantId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Department({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      tenantId: json['tenantId'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, tenantId, name, createdAt, updatedAt];
}

class Payroll extends Equatable {
  final int id;
  final int employeeId;
  final String name;
  final Department department;
  final String designation;
  final double basicSalary;
  final double allowances;
  final double totalBonus;
  final double deductions;
  final double attendanceDeduction;
  final double netSalary;
  final int absentDays;
  final int halfDays;
  final PayrollStatus status;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime? paidDate;

  const Payroll({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.designation,
    required this.basicSalary,
    required this.allowances,
    required this.totalBonus,
    required this.deductions,
    required this.attendanceDeduction,
    required this.netSalary,
    required this.absentDays,
    required this.halfDays,
    required this.status,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    this.paidDate,
  });

  double get grossPay => basicSalary + allowances + totalBonus;

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] as int,
      employeeId: json['employeeId'] as int,
      name: json['name'] as String,
      department: Department.fromJson(
        json['department'] as Map<String, dynamic>,
      ),
      designation: json['designation'] as String,
      basicSalary: (json['basicSalary'] as num).toDouble(),
      allowances: (json['allowances'] as num).toDouble(),
      totalBonus: (json['totalBonus'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      attendanceDeduction: (json['attendanceDeduction'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      absentDays: json['absentDays'] as int,
      halfDays: json['halfDays'] as int,
      status: _parsePayrollStatus(json['status'] as String),
      payPeriodStart: DateTime.parse(
        json['payPeriodStart'] ?? DateTime.now().toIso8601String(),
      ),
      payPeriodEnd: DateTime.parse(
        json['payPeriodEnd'] ?? DateTime.now().toIso8601String(),
      ),
      paidDate:
          json['paidDate'] != null
              ? DateTime.parse(json['paidDate'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'department': department.toJson(),
      'designation': designation,
      'basicSalary': basicSalary,
      'allowances': allowances,
      'totalBonus': totalBonus,
      'deductions': deductions,
      'attendanceDeduction': attendanceDeduction,
      'netSalary': netSalary,
      'absentDays': absentDays,
      'halfDays': halfDays,
      'status': status.name.toLowerCase(),
      'payPeriodStart': payPeriodStart.toIso8601String(),
      'payPeriodEnd': payPeriodEnd.toIso8601String(),
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

  Payroll copyWith({
    int? id,
    int? employeeId,
    String? name,
    Department? department,
    String? designation,
    double? basicSalary,
    double? allowances,
    double? totalBonus,
    double? deductions,
    double? attendanceDeduction,
    double? netSalary,
    int? absentDays,
    int? halfDays,
    PayrollStatus? status,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    DateTime? paidDate,
  }) {
    return Payroll(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      totalBonus: totalBonus ?? this.totalBonus,
      deductions: deductions ?? this.deductions,
      attendanceDeduction: attendanceDeduction ?? this.attendanceDeduction,
      netSalary: netSalary ?? this.netSalary,
      absentDays: absentDays ?? this.absentDays,
      halfDays: halfDays ?? this.halfDays,
      status: status ?? this.status,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    name,
    department,
    designation,
    basicSalary,
    allowances,
    totalBonus,
    deductions,
    attendanceDeduction,
    netSalary,
    absentDays,
    halfDays,
    status,
    payPeriodStart,
    payPeriodEnd,
    paidDate,
  ];
}

enum PayrollStatus { pending, processed, paid }
