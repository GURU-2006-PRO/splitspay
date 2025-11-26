import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF21808D);        // Teal
  static const primaryLight = Color(0xFF32B8C6);
  static const primaryDark = Color(0xFF1A6671);
  
  // Surfaces
  static const surface = Color(0xFFFCFCF9);        // Cream
  static const background = Color(0xFFF5F5F5);     // Light Cream
  
  // Text
  static const textPrimary = Color(0xFF134252);    // Dark slate
  static const textSecondary = Color(0xFF626C71);  // Grey
  
  // Status
  static const success = Color(0xFF21808D);
  static const error = Color(0xFFC0152F);
  static const warning = Color(0xFFA84B2F);
  
  // Other
  static const divider = Color(0xFFE0E0E0);
  static const cardBorder = Color(0xFFE8E8E8);
}

class AppTextStyles {
  static const headline1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const headline2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const headline3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary);
  static const body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary);
  static const caption = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const full = 999.0;
}

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
    onBackground: AppColors.textPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.headline3,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.button,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      textStyle: AppTextStyles.button,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.all(AppSpacing.md),
  ),
  /* cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    margin: EdgeInsets.zero,
  ), */
);
