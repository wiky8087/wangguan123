import 'package:flutter/material.dart';
import 'package:relaygo/theme/app_colors.dart';

extension ThemeColors on BuildContext {
  ThemeData get _theme => Theme.of(this);
  ColorScheme get _cs => _theme.colorScheme;

  // Text levels
  Color get textPrimary => _cs.onSurface;
  Color get textSecondary => _cs.onSurfaceVariant;
  Color get textHint => _cs.outline;
  Color get textDisabled => _cs.onSurface.withValues(alpha: 0.38);

  // Surface levels
  Color get surfaceBg => _cs.surface;
  Color get surfaceCard => _theme.cardColor;
  Color get surfaceElevated => _cs.surfaceContainerLow;
  Color get surfaceContainer => _cs.surfaceContainer;

  // Border
  Color get borderColor => _cs.outlineVariant;
  Color get borderStrong => _cs.outline;

  // Brand
  Color get brandGreen => _cs.primary;
  Color get brandTeal => _cs.secondary;
  Color get brandDark => _cs.primary.withValues(alpha: 0.8);
  Color get brandLight => _cs.tertiary;

  // Semantic
  Color get successColor => _isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
  Color get warningColor => _isDark ? AppColors.darkWarning : AppColors.lightWarning;
  Color get dangerColor => _isDark ? AppColors.darkDanger : AppColors.lightDanger;
  Color get infoColor => _isDark ? AppColors.darkInfo : AppColors.lightInfo;

  Color get successSoftColor =>
      _isDark ? AppColors.darkSuccess.withValues(alpha: 0.12) : AppColors.lightSuccessSoft;
  Color get warningSoftColor =>
      _isDark ? AppColors.darkWarning.withValues(alpha: 0.14) : AppColors.lightWarningSoft;
  Color get dangerSoftColor =>
      _isDark ? AppColors.darkDanger.withValues(alpha: 0.12) : AppColors.lightDangerSoft;
  Color get infoSoftColor =>
      _isDark ? AppColors.lightInfo.withValues(alpha: 0.12) : AppColors.lightInfoSoft;

  bool get _isDark => _theme.brightness == Brightness.dark;
}

extension ThemeGetters on BuildContext {
  Color get scaffoldBackgroundColor => _theme.scaffoldBackgroundColor;
  Color get dividerColor => _theme.dividerColor;
  Color get disabledColor => _theme.disabledColor;
  Color get hintColor => _theme.hintColor;

  ThemeData get _theme => Theme.of(this);
}