import 'package:employee_manegement/core/routes/app_routes.dart';
import 'package:employee_manegement/core/services/storage_service.dart';
import 'package:employee_manegement/core/theme/app_theme.dart';
import 'package:employee_manegement/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:employee_manegement/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_manegement/features/payroll/presentation/bloc/payroll_bloc.dart';
import 'package:employee_manegement/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => PayrollBloc()),
        BlocProvider(create: (context) => AttendanceBloc()),
      ],
      child: MaterialApp(
        title: 'Employee Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
