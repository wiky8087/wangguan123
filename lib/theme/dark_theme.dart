import 'package:flutter/material.dart';
import 'package:relaygo/theme/app_colors.dart';

abstract final class DarkTheme {
  DarkTheme._();

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.darkAccent,
    onPrimary: Color(0xFF00391C),
    primaryContainer: Color(0xFF00522A),
    onPrimaryContainer: Color(0xFFA6F5C4),
    secondary: AppColors.brandTeal,
    onSecondary: Color(0xFF003731),
    secondaryContainer: Color(0xFF00493C),
    onSecondaryContainer: Color(0xFFC7EEE1),
    surface: AppColors.darkBg,
    onSurface: AppColors.darkText,
    onSurfaceVariant: AppColors.darkText2,
    outline: AppColors.darkBorderStrong,
    outlineVariant: AppColors.darkBorder,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    inverseSurface: Color(0xFFE3E3E3),
    scrim: Color(0x80000000),
  );

  static ThemeData get data => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.darkBg,
        cardColor: AppColors.darkSurface,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBg,
          foregroundColor: AppColors.darkText,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.darkText,
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
            backgroundColor: AppColors.darkAccent,
            foregroundColor: const Color(0xFF00391C),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            elevation: 2,
            shadowColor: const Color(0x4D69F0AE),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.darkAccent),
            foregroundColor: AppColors.darkAccent,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkAccent,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: AppColors.darkSurface,
          shadowColor: const Color(0x80000000),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.darkText3, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.darkText2, fontSize: 14),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF00391C)
                : AppColors.darkText2,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.darkAccent
                : AppColors.darkSurface3,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          indicatorColor: const Color(0xFF00522A),
          height: 72,
          elevation: 3,
          shadowColor: const Color(0x80000000),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFFA6F5C4)
                  : AppColors.darkText2,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.darkAccent
                  : AppColors.darkText2,
              size: 24,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: Color(0xFF00391C),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        dividerColor: AppColors.darkBorder,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.darkAccent,
          linearTrackColor: AppColors.darkSurface3,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.darkBorderStrong),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: AppColors.darkText2,
          textColor: AppColors.darkText,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurface2,
          contentTextStyle: const TextStyle(color: AppColors.darkText, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.darkAccent,
          unselectedLabelColor: AppColors.darkText2,
          indicatorColor: AppColors.darkAccent,
          dividerColor: AppColors.darkBorder,
        ),
      );
}