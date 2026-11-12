import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.errorText,
      onError: AppColors.white,
    );

    final TextTheme textTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySecondary,
      bodySmall: AppTextStyles.small,
      labelLarge: AppTextStyles.button,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightGreen,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          );
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(0, AppConstants.buttonHeight),
          padding: AppConstants.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(0, AppConstants.buttonHeight),
          padding: AppConstants.buttonPadding,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabledText,
          textStyle: AppTextStyles.label,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: AppColors.errorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.errorText,
            width: 1.5,
          ),
        ),
        labelStyle: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodySecondary,
        errorStyle: AppTextStyles.small.copyWith(
          color: AppColors.errorText,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.cardRadius,
          ),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.message.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.buttonRadius,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static ThemeData get dark {
    const Color darkBackground = Color(0xFF121A15);
    const Color darkSurface = Color(0xFF1D2A23);
    const Color darkBorder = Color(0xFF2A3B31);
    const Color darkTextPrimary = Color(0xFFF5F7F6);
    const Color darkTextSecondary = Color(0xFFA3B0A8);

    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppColors.secondary,
      onPrimary: AppColors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.textPrimary,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      error: AppColors.errorText,
      onError: AppColors.white,
    );

    final TextTheme textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      headlineLarge: AppTextStyles.h1.copyWith(color: darkTextPrimary),
      headlineMedium: AppTextStyles.h2.copyWith(color: darkTextPrimary),
      headlineSmall: AppTextStyles.h3.copyWith(color: darkTextPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: darkTextPrimary),
      bodyMedium: AppTextStyles.bodySecondary.copyWith(color: darkTextSecondary),
      bodySmall: AppTextStyles.small.copyWith(color: darkTextSecondary),
      labelLarge: AppTextStyles.button.copyWith(color: darkTextPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: AppColors.primary,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.small.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return AppTextStyles.small.copyWith(
            color: darkTextSecondary,
            fontSize: 11,
          );
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(0, AppConstants.buttonHeight),
          padding: AppConstants.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(0, AppConstants.buttonHeight),
          padding: AppConstants.buttonPadding,
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.disabledText,
          textStyle: AppTextStyles.label,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(color: AppColors.errorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.errorText,
            width: 1.5,
          ),
        ),
        labelStyle: AppTextStyles.label.copyWith(
          color: darkTextSecondary,
        ),
        hintStyle: AppTextStyles.bodySecondary.copyWith(
          color: darkTextSecondary,
        ),
        errorStyle: AppTextStyles.small.copyWith(
          color: AppColors.errorText,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.cardRadius,
          ),
          side: const BorderSide(color: darkBorder),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: AppTextStyles.message.copyWith(
          color: darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.buttonRadius,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
      ),
    );
  }
}
