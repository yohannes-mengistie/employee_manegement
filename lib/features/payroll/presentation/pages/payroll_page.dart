import 'package:employee_manegement/core/models/payroll.dart';
import 'package:employee_manegement/core/theme/app_theme.dart';
import 'package:employee_manegement/features/payroll/presentation/bloc/payroll_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  @override
  void initState() {
    super.initState();
    context.read<PayrollBloc>().add(const LoadEmployeePayroll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Payroll'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PayrollBloc>().add(const LoadEmployeePayroll());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<PayrollBloc, PayrollState>(
        listener: (context, state) {
          if (state is PayrollError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PayrollLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PayrollHistoryLoaded) {
            if (state.payrolls.isEmpty) {
              return const Center(
                child: Text('No payroll data available for this employee'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.payrolls.length,
              itemBuilder: (context, index) {
                final payroll = state.payrolls[index];
                return PayrollExpansionTile(payroll: payroll);
              },
            );
          }

          return const Center(child: Text('No payroll data available'));
        },
      ),
    );
  }
}

class PayrollExpansionTile extends StatelessWidget {
  final Payroll payroll;

  const PayrollExpansionTile({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(payroll.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long,
            color: _getStatusColor(payroll.status),
          ),
        ),
        title: Text(
          '${payroll.name} - ${DateFormat('MMM yyyy').format(payroll.payPeriodStart)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(payroll.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(payroll.status),
                style: TextStyle(
                  color: _getStatusColor(payroll.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${NumberFormat('#,##0.00').format(payroll.netSalary)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Info
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Employee',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '${payroll.name} (${payroll.designation})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          payroll.department.name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pay Period
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay Period',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '${DateFormat('MMM dd').format(payroll.payPeriodStart)} - '
                          '${DateFormat('MMM dd, yyyy').format(payroll.payPeriodEnd)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Earnings
                Text(
                  'Earnings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Basic Salary', payroll.basicSalary),
                if (payroll.allowances > 0) ...[
                  const Divider(),
                  _buildDetailRow('Allowances', payroll.allowances),
                ],
                if (payroll.totalBonus > 0) ...[
                  const Divider(),
                  _buildDetailRow('Bonus', payroll.totalBonus),
                ],
                const Divider(),
                _buildDetailRow(
                  'Gross Pay',
                  payroll.grossPay,
                  isTotal: true,
                  color: AppTheme.successColor,
                ),
                const SizedBox(height: 16),

                // Deductions
                Text(
                  'Deductions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Deductions', payroll.deductions),
                if (payroll.attendanceDeduction > 0) ...[
                  const Divider(),
                  _buildDetailRow(
                    'Attendance Deduction',
                    payroll.attendanceDeduction,
                  ),
                ],
                const Divider(),
                _buildDetailRow(
                  'Total Deductions',
                  payroll.deductions + payroll.attendanceDeduction,
                  isTotal: true,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),

                // Attendance
                Text(
                  'Attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Absent Days',
                  payroll.absentDays.toDouble(),
                  isCount: true,
                ),
                _buildDetailRow(
                  'Half Days',
                  payroll.halfDays.toDouble(),
                  isCount: true,
                ),
                const SizedBox(height: 16),

                // Net Pay
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Pay',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(payroll.netSalary)}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isCount = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
          Text(
            isCount
                ? amount.toInt().toString()
                : '\$${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PayrollStatus status) {
    switch (status) {
      case PayrollStatus.pending:
        return 'Pending';
      case PayrollStatus.processed:
        return 'Processed';
      case PayrollStatus.paid:
        return 'Paid';
    }
  }

  Color _getStatusColor(PayrollStatus status) {
    switch (status) {
      case PayrollStatus.pending:
        return AppTheme.warningColor;
      case PayrollStatus.processed:
        return AppTheme.primaryColor;
      case PayrollStatus.paid:
        return AppTheme.successColor;
    }
  }
}
