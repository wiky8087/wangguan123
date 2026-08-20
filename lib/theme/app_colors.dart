import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color brandGreen = Color(0xFF00C853);
  static const Color brandTeal = Color(0xFF00BFA5);
  static const Color brandDark = Color(0xFF009624);
  static const Color brandLight = Color(0xFF69F0AE);

  // Light tokens
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightBg2 = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFF7F8FA);
  static const Color lightSurface2 = Color(0xFFF0F2F5);
  static const Color lightSurface3 = Color(0xFFE9ECEF);
  static const Color lightBorder = Color(0xFFE0E2E6);
  static const Color lightBorderStrong = Color(0xFFC4C7CC);
  static const Color lightText = Color(0xFF1A1C1E);
  static const Color lightText2 = Color(0xFF44474E);
  static const Color lightText3 = Color(0xFF8A9099);

  // Light accent
  static const Color lightAccent = Color(0xFF00C853);
  static const Color lightAccentStrong = Color(0xFF00BFA5);
  static const Color lightAccentSoft = Color(0x1F00C853);
  static const Color lightAccentLine = Color(0x5900C853);

  // Light semantic
  static const Color lightSuccess = Color(0xFF4CAF50);
  static const Color lightSuccessSoft = Color(0x1F4CAF50);
  static const Color lightWarning = Color(0xFFFF9800);
  static const Color lightWarningSoft = Color(0x24FF9800);
  static const Color lightDanger = Color(0xFFF44336);
  static const Color lightDangerSoft = Color(0x1FF44336);
  static const Color lightInfo = Color(0xFF2196F3);
  static const Color lightInfoSoft = Color(0x1F2196F3);

  // Dark tokens
  static const Color darkBg = Color(0xFF121212);
  static const Color darkBg2 = Color(0xFF1A1D21);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurface2 = Color(0xFF23262B);
  static const Color darkSurface3 = Color(0xFF2A2E34);
  static const Color darkBorder = Color(0xFF3A3F46);
  static const Color darkBorderStrong = Color(0xFF8A9099);
  static const Color darkText = Color(0xFFE3E3E3);
  static const Color darkText2 = Color(0xFFC4C7CE);
  static const Color darkText3 = Color(0xFF7C828C);

  // Dark accent
  static const Color darkAccent = Color(0xFF69F0AE);
  static const Color darkAccentStrong = Color(0xFF00BFA5);
  static const Color darkAccentSoft = Color(0x1F69F0AE);
  static const Color darkAccentLine = Color(0x5969F0AE);

  // Dark semantic
  static const Color darkSuccess = Color(0xFF4CAF50);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkDanger = Color(0xFFFFB4AB);
  static const Color darkInfo = Color(0xFF64B5F6);
}