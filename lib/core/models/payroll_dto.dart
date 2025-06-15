// DTOs to match your NestJS backend
class CreatePayrollDto {
  final int employeeId;
  final String payPeriodStart;
  final String payPeriodEnd;
  final double basicSalary;
  final double? overtime;
  final double? bonus;
  final double? deductions;

  const CreatePayrollDto({
    required this.employeeId,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.basicSalary,
    this.overtime,
    this.bonus,
    this.deductions,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'payPeriodStart': payPeriodStart,
      'payPeriodEnd': payPeriodEnd,
      'basicSalary': basicSalary,
      if (overtime != null) 'overtime': overtime,
      if (bonus != null) 'bonus': bonus,
      if (deductions != null) 'deductions': deductions,
    };
  }
}

class UpdatePayrollDto {
  final double? basicSalary;
  final double? overtime;
  final double? bonus;
  final double? deductions;
  final String? status;

  const UpdatePayrollDto({
    this.basicSalary,
    this.overtime,
    this.bonus,
    this.deductions,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (basicSalary != null) data['basicSalary'] = basicSalary;
    if (overtime != null) data['overtime'] = overtime;
    if (bonus != null) data['bonus'] = bonus;
    if (deductions != null) data['deductions'] = deductions;
    if (status != null) data['status'] = status;
    return data;
  }
}

class CreatePayrollSettingDto {
  final double? basicSalary;
  final double? overtimeRate;
  final double? taxRate;
  final double? socialSecurityRate;
  final String? payFrequency;
  final Map<String, dynamic>? additionalSettings;

  const CreatePayrollSettingDto({
    this.basicSalary,
    this.overtimeRate,
    this.taxRate,
    this.socialSecurityRate,
    this.payFrequency,
    this.additionalSettings,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (basicSalary != null) data['basicSalary'] = basicSalary;
    if (overtimeRate != null) data['overtimeRate'] = overtimeRate;
    if (taxRate != null) data['taxRate'] = taxRate;
    if (socialSecurityRate != null) data['socialSecurityRate'] = socialSecurityRate;
    if (payFrequency != null) data['payFrequency'] = payFrequency;
    if (additionalSettings != null) data['additionalSettings'] = additionalSettings;
    return data;
  }
}

class CreatePayrollItemDto {
  final int payrollId;
  final String itemType;
  final String description;
  final double amount;
  final bool isDeduction;

  const CreatePayrollItemDto({
    required this.payrollId,
    required this.itemType,
    required this.description,
    required this.amount,
    required this.isDeduction,
  });

  Map<String, dynamic> toJson() {
    return {
      'payrollId': payrollId,
      'itemType': itemType,
      'description': description,
      'amount': amount,
      'isDeduction': isDeduction,
    };
  }
}

// Response models to match your backend
class PayrollSummary {
  final double totalGrossPay;
  final double totalDeductions;
  final double totalNetPay;
  final int totalEmployees;
  final String period;

  const PayrollSummary({
    required this.totalGrossPay,
    required this.totalDeductions,
    required this.totalNetPay,
    required this.totalEmployees,
    required this.period,
  });

  factory PayrollSummary.fromJson(Map<String, dynamic> json) {
    return PayrollSummary(
      totalGrossPay: (json['totalGrossPay'] ?? 0.0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0.0).toDouble(),
      totalNetPay: (json['totalNetPay'] ?? 0.0).toDouble(),
      totalEmployees: json['totalEmployees'] ?? 0,
      period: json['period'] ?? '',
    );
  }
}

class PayslipDetail {
  final int id;
  final int employeeId;
  final String employeeName;
  final String payPeriod;
  final double basicSalary;
  final double overtime;
  final double bonus;
  final double deductions;
  final double netPay;
  final String status;
  final List<PayrollItem> items;

  const PayslipDetail({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.payPeriod,
    required this.basicSalary,
    required this.overtime,
    required this.bonus,
    required this.deductions,
    required this.netPay,
    required this.status,
    required this.items,
  });

  factory PayslipDetail.fromJson(Map<String, dynamic> json) {
    return PayslipDetail(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      payPeriod: json['payPeriod'] ?? '',
      basicSalary: (json['basicSalary'] ?? 0.0).toDouble(),
      overtime: (json['overtime'] ?? 0.0).toDouble(),
      bonus: (json['bonus'] ?? 0.0).toDouble(),
      deductions: (json['deductions'] ?? 0.0).toDouble(),
      netPay: (json['netPay'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => PayrollItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class PayrollItem {
  final int id;
  final String itemType;
  final String description;
  final double amount;
  final bool isDeduction;

  const PayrollItem({
    required this.id,
    required this.itemType,
    required this.description,
    required this.amount,
    required this.isDeduction,
  });

  factory PayrollItem.fromJson(Map<String, dynamic> json) {
    return PayrollItem(
      id: json['id'] ?? 0,
      itemType: json['itemType'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      isDeduction: json['isDeduction'] ?? false,
    );
  }
}
