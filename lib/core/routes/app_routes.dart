import 'package:employee_manegement/features/attendance/presentation/pages/attendance_page.dart';
import 'package:employee_manegement/features/auth/presentation/pages/login_page.dart';
import 'package:employee_manegement/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:employee_manegement/features/payroll/presentation/pages/payroll_page.dart';
import 'package:employee_manegement/features/profile/presentation/pages/profile_page.dart';
import 'package:employee_manegement/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String payroll = '/payroll';
  static const String attendance = '/attendance';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case payroll:
        return MaterialPageRoute(builder: (_) => const PayrollPage());
      case attendance:
        return MaterialPageRoute(builder: (_) => const AttendancePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
