class CreateLeaveDto {
  final int tenantId;
  final int employeeId;
  final int leavePolicyId;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final String leaveType;
  final String reason;
  final String status;

  CreateLeaveDto({
    required this.tenantId,
    required this.employeeId,
    required this.leavePolicyId,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.leaveType,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'employeeId': employeeId,
      'leavePolicyId': leavePolicyId,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'duration': duration,
      'leaveType': leaveType,
      'reason': reason,
      'status': status,
    };
  }
}