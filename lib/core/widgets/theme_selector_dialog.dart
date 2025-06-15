import 'package:employee_manegement/core/theme/app_theme.dart';
import 'package:employee_manegement/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentTheme) {
        final themeCubit = context.read<ThemeCubit>();
        final currentThemeMode = themeCubit.getCurrentThemeMode();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.palette_outlined),
              SizedBox(width: 12),
              Text('Choose Theme'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Light Theme',
                'Bright and clean interface',
                Icons.light_mode,
                AppThemeMode.light,
                currentThemeMode,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'Dark Theme',
                'Easy on the eyes in low light',
                Icons.dark_mode,
                AppThemeMode.dark,
                currentThemeMode,
                Colors.indigo,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'System Theme',
                'Follows your device settings',
                Icons.settings_system_daydream,
                AppThemeMode.system,
                currentThemeMode,
                Colors.green,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode themeMode,
    AppThemeMode currentThemeMode,
    Color iconColor,
  ) {
    final isSelected = themeMode == currentThemeMode;

    return InkWell(
      onTap: () {
        context.read<ThemeCubit>().setTheme(themeMode);
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${title.toLowerCase()}'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
