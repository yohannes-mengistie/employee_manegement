import 'package:employee_manegement/core/models/attendance.dart';
import 'package:employee_manegement/core/theme/app_theme.dart';
import 'package:employee_manegement/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AttendanceBloc>().add(const LoadAttendanceHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Record', icon: Icon(Icons.edit)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(const LoadAttendanceHistory());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [AttendanceFormTab(), AttendanceHistoryTab()],
        ),
      ),
    );
  }
}

class AttendanceFormTab extends StatelessWidget {
  const AttendanceFormTab({super.key});

  @override
  Widget build(BuildContext context) {
    final checkInController = TextEditingController();
    final checkOutController = TextEditingController();
    final notesController = TextEditingController();
    final statusController = TextEditingController(text: 'present');
    final dateFormat = DateFormat('HH:mm');
    final currentDate = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Attendance Record',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                initialValue: DateFormat('yyyy-MM-dd').format(currentDate),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: checkInController,
                      decoration: InputDecoration(
                        labelText: 'Check In Time',
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.input,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  hourMinuteTextColor: Theme.of(context).colorScheme.primary,
                                  dialHandColor: Theme.of(context).colorScheme.primary,
                                  entryModeIconColor: Theme.of(context).colorScheme.primary,
                                ),
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  surface: Theme.of(context).colorScheme.surface,
                                  onSurface: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (picked != null) {
                          checkInController.text =
                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: checkOutController,
                      decoration: InputDecoration(
                        labelText: 'Check Out Time',
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.input,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  hourMinuteTextColor: Theme.of(context).colorScheme.primary,
                                  dialHandColor: Theme.of(context).colorScheme.primary,
                                  entryModeIconColor: Theme.of(context).colorScheme.primary,
                                ),
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  surface: Theme.of(context).colorScheme.surface,
                                  onSurface: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (picked != null) {
                          checkOutController.text =
                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  'present',
                  'absent',
                  'late',
                  'half_day',
                  'work_from_home',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                value: statusController.text,
                onChanged: (value) {
                  if (value != null) {
                    statusController.text = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      checkInController.clear();
                      checkOutController.clear();
                      notesController.clear();
                      statusController.text = 'present';
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (checkInController.text.isEmpty ||
                          checkOutController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please fill all required fields.',
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }

                      try {
                        final date = DateTime.parse(
                          '${DateFormat('yyyy-MM-dd').format(currentDate)}T00:00:00Z',
                        );

                        final checkIn = dateFormat.parse(
                          checkInController.text,
                        );
                        final checkOut = dateFormat.parse(
                          checkOutController.text,
                        );
                        if (checkOut.isBefore(checkIn) ||
                            checkOut.isAtSameMomentAs(checkIn)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Check-out time must be after check-in time.',
                              ),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }

                        context.read<AttendanceBloc>().add(
                          AddAttendance(
                            date: date,
                            checkInTime: checkInController.text,
                            checkOutTime: checkOutController.text,
                            notes:
                                notesController.text.isEmpty
                                    ? null
                                    : notesController.text,
                            status: statusController.text,
                          ),
                        );

                        checkInController.clear();
                        checkOutController.clear();
                        notesController.clear();
                        statusController.text = 'present';
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Invalid input format.'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Submit Attendance'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceHistoryTab extends StatelessWidget {
  const AttendanceHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading attendance history...'),
              ],
            ),
          );
        }

        if (state is AttendanceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading attendance history',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AttendanceBloc>().add(
                      const LoadAttendanceHistory(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AttendanceDataLoaded) {
          if (state.attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No attendance history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your attendance records will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.attendances.length,
            itemBuilder: (context, index) {
              final attendance = state.attendances[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        attendance.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(attendance.status),
                      color: _getStatusColor(attendance.status),
                    ),
                  ),
                  title: Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(attendance.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (attendance.checkInTime != null)
                        Text('In: ${attendance.checkInTime}'),
                      if (attendance.checkOutTime != null)
                        Text('Out: ${attendance.checkOutTime}'),
                      if (attendance.notes != null)
                        Text('Notes: ${attendance.notes}'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            attendance.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(attendance.status),
                          style: TextStyle(
                            color: _getStatusColor(attendance.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      attendance.totalWorkingTime != null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDuration(attendance.totalWorkingTime!),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Hours',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                          : null,
                ),
              );
            },
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading attendance history...'),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.successColor;
      case AttendanceStatus.late:
        return AppTheme.warningColor;
      case AttendanceStatus.absent:
        return AppTheme.errorColor;
      case AttendanceStatus.half_day:
        return AppTheme.primaryColor;
      case AttendanceStatus.work_from_home:
        return AppTheme.secondaryColor;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.half_day:
        return Icons.access_time;
      case AttendanceStatus.work_from_home:
        return Icons.beach_access;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.half_day:
        return 'Half Day';
      case AttendanceStatus.work_from_home:
        return 'Work From Home';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
