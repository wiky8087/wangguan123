import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 保活服务封装（Android 前台服务 + 电池优化白名单）
///
/// 通过 MethodChannel 与原生层通信：
///  - [start] / [stop]：启动 / 停止前台保活服务（常驻通知提升进程优先级）
///  - [isIgnoringBatteryOptimizations] / [requestIgnoreBatteryOptimizations]：
///    查询 / 请求加入电池优化白名单（避免 Doze 模式被杀）
///
/// 非 Android 平台（桌面 / iOS / Web）直接返回安全默认值，不抛异常。
///
/// 注意：命名为 [KeepAliveHelper] 以避开 Flutter 内置的 [KeepAlive] widget。
class KeepAliveHelper {
  static const MethodChannel _channel = MethodChannel('relaygo/keep_alive');

  /// 当前平台是否支持保活（仅 Android 原生实现）
  static bool get isSupported =>
      !kIsWeb && Platform.isAndroid;

  /// 启动前台保活服务
  static Future<bool> start() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('startKeepAlive') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 停止前台保活服务
  static Future<bool> stop() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('stopKeepAlive') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 是否已加入电池优化白名单（非 Android 视为已忽略）
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!isSupported) return true;
    try {
      return await _channel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          true;
    } catch (_) {
      return true;
    }
  }

  /// 请求加入电池优化白名单（弹出系统授权对话框）
  static Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!isSupported) return false;
    try {
      return await _channel
              .invokeMethod<bool>('requestIgnoreBatteryOptimizations') ??
          false;
    } catch (_) {
      return false;
    }
  }

  // ———————— 悬浮条（前台服务 + 悬浮窗，双保险保活）————————

  /// 启动悬浮条（前台服务 + 系统悬浮窗）。
  ///
  /// 悬浮窗常驻可见会让系统认为应用正处于前台使用状态，配合前台服务
  /// 双保险，显著降低代理服务在后台被系统回收的概率。
  static Future<bool> startFloatingBall(String style) async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>(
              'startFloatingBall', {'style': style}) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 停止悬浮条
  static Future<bool> stopFloatingBall() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('stopFloatingBall') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 切换悬浮条样式（悬浮条运行中生效）
  static Future<bool> updateFloatingBall(String style) async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>(
              'updateFloatingBall', {'style': style}) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 是否已授予悬浮窗权限
  static Future<bool> canDrawOverlays() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 请求悬浮窗权限（跳转系统「显示在其他应用上层」设置页）
  static Future<void> requestOverlayPermission() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } catch (_) {
      // 部分 ROM 无法跳转：由调用方引导用户手动开启
    }
  }
}
