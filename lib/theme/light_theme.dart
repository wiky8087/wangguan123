import 'package:flutter/material.dart';
import 'package:relaygo/theme/app_colors.dart';

abstract final class LightTheme {
  LightTheme._();

  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppColors.brandGreen,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFA6F5C4),
    onPrimaryContainer: Color(0xFF00210F),
    secondary: AppColors.brandTeal,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC7EEE1),
    onSecondaryContainer: Color(0xFF00201A),
    tertiary: AppColors.brandLight,
    surface: AppColors.lightBg,
    onSurface: AppColors.lightText,
    onSurfaceVariant: AppColors.lightText2,
    outline: AppColors.lightBorderStrong,
    outlineVariant: AppColors.lightBorder,
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    inverseSurface: Color(0xFF2E3133),
    scrim: Color(0x80000000),
  );

  static ThemeData get data => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.lightBg,
        cardColor: Color(0xFFFFFFFF),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: AppColors.lightText,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.brandGreen,
            foregroundColor: Color(0xFFFFFFFF),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            elevation: 2,
            shadowColor: const Color(0x4D00C853),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.brandGreen),
            foregroundColor: AppColors.brandGreen,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandGreen,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: const Color(0xFFFFFFFF),
          shadowColor: const Color(0x14000000),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.brandGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.lightText3, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.lightText2, fontSize: 14),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFFFFFFFF)
                : AppColors.lightText2,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.brandGreen
                : AppColors.lightSurface3,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          indicatorColor: const Color(0xFFA6F5C4),
          height: 72,
          elevation: 3,
          shadowColor: const Color(0x14000000),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF00210F)
                  : AppColors.lightText2,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF006B3F)
                  : AppColors.lightText2,
              size: 24,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        dividerColor: AppColors.lightBorder,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.brandGreen,
          linearTrackColor: AppColors.lightSurface3,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSurface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.lightBorderStrong),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: AppColors.lightText2,
          textColor: AppColors.lightText,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF2E3133),
          contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFF006B3F),
          unselectedLabelColor: AppColors.lightText2,
          indicatorColor: AppColors.brandGreen,
          dividerColor: AppColors.lightBorder,
        ),
      );
}