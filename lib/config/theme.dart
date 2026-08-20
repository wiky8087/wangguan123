import 'package:flutter/material.dart';
import 'package:relaygo/theme/app_colors.dart';
import 'package:relaygo/theme/light_theme.dart';
import 'package:relaygo/theme/dark_theme.dart';
import 'package:relaygo/theme/theme_ext.dart';

export 'package:relaygo/theme/app_colors.dart';
export 'package:relaygo/theme/theme_ext.dart';

/// RelayGo 主题
///
/// 双主题架构：Light / Dark，基于 Material 3 ColorScheme。
/// 所有颜色应通过 [ThemeColors] 扩展从 BuildContext 获取。
class AppTheme {
  AppTheme._();

  // Brand
  static const Color brandGreen = AppColors.brandGreen;
  static const Color brandTeal = AppColors.brandTeal;
  static const Color brandDark = AppColors.brandDark;
  static const Color brandLight = AppColors.brandLight;

  // Light tokens (backward compatibility)
  static const Color bg = AppColors.lightBg;
  static const Color bg2 = AppColors.lightBg2;
  static const Color surface = AppColors.lightSurface;
  static const Color surface2 = AppColors.lightSurface2;
  static const Color surface3 = AppColors.lightSurface3;
  static const Color border = AppColors.lightBorder;
  static const Color borderStrong = AppColors.lightBorderStrong;
  static const Color text = AppColors.lightText;
  static const Color text2 = AppColors.lightText2;
  static const Color text3 = AppColors.lightText3;

  // Light accent
  static const Color accent = AppColors.lightAccent;
  static const Color accentStrong = AppColors.lightAccentStrong;
  static const Color accentSoft = AppColors.lightAccentSoft;
  static const Color accentLine = AppColors.lightAccentLine;

  // Light semantic
  static const Color success = AppColors.lightSuccess;
  static const Color successSoft = AppColors.lightSuccessSoft;
  static const Color warning = AppColors.lightWarning;
  static const Color warningSoft = AppColors.lightWarningSoft;
  static const Color danger = AppColors.lightDanger;
  static const Color dangerSoft = AppColors.lightDangerSoft;
  static const Color info = AppColors.lightInfo;
  static const Color infoSoft = AppColors.lightInfoSoft;

  // Dark tokens (backward compatibility)
  static const Color dBg = AppColors.darkBg;
  static const Color dBg2 = AppColors.darkBg2;
  static const Color dSurface = AppColors.darkSurface;
  static const Color dSurface2 = AppColors.darkSurface2;
  static const Color dSurface3 = AppColors.darkSurface3;
  static const Color dBorder = AppColors.darkBorder;
  static const Color dBorderStrong = AppColors.darkBorderStrong;
  static const Color dText = AppColors.darkText;
  static const Color dText2 = AppColors.darkText2;
  static const Color dText3 = AppColors.darkText3;

  static const Color dAccent = AppColors.darkAccent;
  static const Color dAccentStrong = AppColors.darkAccentStrong;
  static const Color dAccentSoft = AppColors.darkAccentSoft;
  static const Color dAccentLine = AppColors.darkAccentLine;

  static const Color dSuccess = AppColors.darkSuccess;
  static const Color dWarning = AppColors.darkWarning;
  static const Color dDanger = AppColors.darkDanger;
  static const Color dInfo = AppColors.darkInfo;

  // Typography
  static const String uiFontFamily = 'Inter';
  static const String monoFontFamily = 'monospace';

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 28;

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandGreen, brandTeal],
  );

  static const LinearGradient brandGradientPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandDark, Color(0xFF00897B)],
  );

  static const LinearGradient brandGradientDisabled = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
  );

  static ThemeData get light => LightTheme.data;
  static ThemeData get dark => DarkTheme.data;
}