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
    context.read<PayrollBloc>().add(LoadPayrollHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PayrollBloc>().add(LoadPayrollHistory());
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
            return Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Month Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Gross Pay',
                                  '\$${NumberFormat('#,##0.00').format(state.payrolls.first.grossPay)}',
                                  Icons.trending_up,
                                  AppTheme.successColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Net Pay',
                                  '\$${NumberFormat('#,##0.00').format(state.payrolls.first.netPay)}',
                                  Icons.account_balance_wallet,
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Deductions',
                                  '\$${NumberFormat('#,##0.00').format(state.payrolls.first.deductions)}',
                                  Icons.trending_down,
                                  AppTheme.errorColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Status',
                                  _getStatusText(state.payrolls.first.status),
                                  Icons.info_outline,
                                  _getStatusColor(state.payrolls.first.status),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Payroll History List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.payrolls.length,
                    itemBuilder: (context, index) {
                      final payroll = state.payrolls[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
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
                            '${DateFormat('MMM yyyy').format(payroll.payPeriodStart)} Payslip',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${DateFormat('MMM dd').format(payroll.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payroll.payPeriodEnd)}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
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
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${NumberFormat('#,##0.00').format(payroll.netPay)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Net Pay',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showPayrollDetails(context, payroll);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          return const Center(
            child: Text('No payroll data available'),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
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

  void _showPayrollDetails(BuildContext context, Payroll payroll) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PayrollDetailsSheet(payroll: payroll),
    );
  }
}

class PayrollDetailsSheet extends StatelessWidget {
  final Payroll payroll;

  const PayrollDetailsSheet({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payslip Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pay Period
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pay Period',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM dd').format(payroll.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payroll.payPeriodEnd)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Earnings Section
          Text(
            'Earnings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Basic Salary', payroll.basicSalary),
                  if (payroll.overtime > 0) ...[
                    const Divider(),
                    _buildDetailRow('Overtime', payroll.overtime),
                  ],
                  if (payroll.bonus > 0) ...[
                    const Divider(),
                    _buildDetailRow('Bonus', payroll.bonus),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    'Gross Pay',
                    payroll.grossPay,
                    isTotal: true,
                    color: AppTheme.successColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Deductions Section
          Text(
            'Deductions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Tax & Insurance', payroll.deductions),
                  const Divider(),
                  _buildDetailRow(
                    'Total Deductions',
                    payroll.deductions,
                    isTotal: true,
                    color: AppTheme.errorColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Net Pay
          Card(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Pay',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(payroll.netPay)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Download Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payslip downloaded successfully!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Payslip'),
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
              color: color,
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
