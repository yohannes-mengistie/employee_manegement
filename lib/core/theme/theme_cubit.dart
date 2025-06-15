import 'package:employee_manegement/core/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


enum AppThemeMode { light, dark, system }

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';

  void _loadTheme() {
    final savedTheme = StorageService.getString(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          emit(ThemeMode.light);
          break;
        case 'dark':
          emit(ThemeMode.dark);
          break;
        case 'system':
        default:
          emit(ThemeMode.system);
          break;
      }
    }
  }

  void setTheme(AppThemeMode themeMode) {
    ThemeMode mode;
    String themeString;
    
    switch (themeMode) {
      case AppThemeMode.light:
        mode = ThemeMode.light;
        themeString = 'light';
        break;
      case AppThemeMode.dark:
        mode = ThemeMode.dark;
        themeString = 'dark';
        break;
      case AppThemeMode.system:
        mode = ThemeMode.system;
        themeString = 'system';
        break;
    }
    
    StorageService.setString(_themeKey, themeString);
    emit(mode);
  }

  AppThemeMode getCurrentThemeMode() {
    switch (state) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
      default:
        return AppThemeMode.system;
    }
  }

  String getThemeDisplayName() {
    switch (getCurrentThemeMode()) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}
