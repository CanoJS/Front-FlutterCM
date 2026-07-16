import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutral50, 
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary600,
        primary: AppColors.primary600,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary600, 
        foregroundColor: Colors.white,        
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}