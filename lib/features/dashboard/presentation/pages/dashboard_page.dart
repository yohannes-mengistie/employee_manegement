import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:employee_manegement/core/models/create_leave_dto.dart';
import 'package:employee_manegement/core/routes/app_routes.dart';
import 'package:employee_manegement/core/theme/app_theme.dart';
import 'package:employee_manegement/core/theme/theme_cubit.dart';
import 'package:employee_manegement/core/widgets/theme_selector_dialog.dart';
import 'package:employee_manegement/features/attendance/presentation/pages/attendance_page.dart';
import 'package:employee_manegement/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_manegement/features/dashboard/presentation/bloc/leave_bloc.dart';
import 'package:employee_manegement/features/payroll/presentation/pages/payroll_page.dart';
import 'package:employee_manegement/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const ProfilePage(),
    const PayrollPage(),
    const AttendancePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payroll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Theme Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            state.employee.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Theme Button
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, themeMode) {
                              return IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const ThemeSelectorDialog(),
                                  );
                                },
                                icon: Icon(
                                  _getThemeIcon(themeMode),
                                  color: AppTheme.primaryColor,
                                ),
                                tooltip: 'Change Theme',
                              );
                            },
                          ),
                          // Logout Button
                          IconButton(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(Icons.logout),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Company Description
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Digit Tech Solutions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Digit Tech Solutions is a leading innovator in technology, empowering businesses with cutting-edge solutions in Addis Ababa and beyond.',
                                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.accentColor,
                                      height: 1.5,
                                    ),
                                speed: const Duration(milliseconds: 50),
                              ),
                              TypewriterAnimatedText(
                                'Our mission is to drive digital transformation through creativity, collaboration, and excellence.',
                                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                speed: const Duration(milliseconds: 50),
                              ),
                              TypewriterAnimatedText(
                                'Join us in shaping the future of technology with passion and innovation.',
                                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                speed: const Duration(milliseconds: 50),
                              ),
                            ],
                            repeatForever: true,
                            pause: const Duration(seconds: 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                 Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          context,
                          'Check In/Out',
                          Icons.fingerprint,
                          AppTheme.primaryColor,
                          () {
                            _navigateToAttendance(context);
                          },
                        ),
                        _buildActionCard(
                          context,
                          'View Payslips',
                          Icons.receipt_long,
                          AppTheme.accentColor,
                          () {
                            _navigateToPayroll(context);
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Apply Leave',
                          Icons.event_busy,
                          AppTheme.warningColor,
                          () {
                            _showLeaveApplicationDialog(context);
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Profile', // Changed from 'Change Theme' to 'Profile'
                          Icons.person, // Changed icon to represent Profile
                          Colors.blue, // Changed color (you can adjust to match AppTheme)
                          () {
                            _navigateToProfile(context); // New navigation function
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
      default:
        return Icons.settings_system_daydream;
    }
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAttendance(BuildContext context) {
    final dashboardState = context.findAncestorStateOfType<_DashboardPageState>();
    if (dashboardState != null) {
      dashboardState.setState(() {
        dashboardState._selectedIndex = 3;
      });
    }
  }


  void _navigateToProfile(BuildContext context) {
    final dashboardState = context.findAncestorStateOfType<_DashboardPageState>();
    if (dashboardState != null) {
      dashboardState.setState(() {
        dashboardState._selectedIndex = 1; // Index 1 corresponds to ProfilePage
      });
    }
  }

  void _navigateToPayroll(BuildContext context) {
    final dashboardState = context.findAncestorStateOfType<_DashboardPageState>();
    if (dashboardState != null) {
      dashboardState.setState(() {
        dashboardState._selectedIndex = 2;
      });
    }
  }

  void _showLeaveApplicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => LeaveBloc(),
        child: const LeaveApplicationDialog(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// Leave Application Dialog Widget
class LeaveApplicationDialog extends StatefulWidget {
  const LeaveApplicationDialog({super.key});

  @override
  State<LeaveApplicationDialog> createState() => _LeaveApplicationDialogState();
}

class _LeaveApplicationDialogState extends State<LeaveApplicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'maternity';

  final List<String> _leaveTypes = [
    'annual',
    'sick',
    'maternity',
    'unpaid',
    'other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;
    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leave application submitted successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_leaveType: ${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                  ),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Apply for Leave'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Leave Type Dropdown
                DropdownButtonFormField<String>(
                  value: _leaveType,
                  decoration: const InputDecoration(
                    labelText: 'Leave Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _leaveTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _leaveType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Start Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _startDate != null
                          ? DateFormat('MMM dd, yyyy').format(_startDate!)
                          : 'Select start date',
                      style: TextStyle(
                        color: _startDate != null ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _endDate != null
                          ? DateFormat('MMM dd, yyyy').format(_endDate!)
                          : 'Select end date',
                      style: TextStyle(
                        color: _endDate != null ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reason
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),

                // Duration Display
                if (_startDate != null && _endDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${_endDate!.difference(_startDate!).inDays + 1} day(s)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          BlocBuilder<LeaveBloc, LeaveState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is LeaveLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate() &&
                            _startDate != null &&
                            _endDate != null) {
                          final leaveDto = CreateLeaveDto(
                            tenantId: authState.employee.tenantId ?? 2,
                            employeeId: authState.employee.employeeId ?? 6,
                            leavePolicyId: 1,
                            startDate: _startDate!,
                            endDate: _endDate!,
                            duration: _endDate!.difference(_startDate!).inDays + 1,
                            leaveType: _leaveType,
                            reason: _reasonController.text,
                            status: 'pending',
                          );
                          context.read<LeaveBloc>().add(SubmitLeave(leaveDto: leaveDto));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      },
                child: state is LeaveLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              );
            },
          ),
        ],
      ),
    );
  }
}