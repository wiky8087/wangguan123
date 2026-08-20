package com.relaygo.app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "relaygo/keep_alive"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startKeepAlive" -> {
                        KeepAliveService.start(this)
                        result.success(true)
                    }
                    "stopKeepAlive" -> {
                        KeepAliveService.stop(this)
                        result.success(true)
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(true)
                    }
                    "startFloatingBall" -> {
                        val style = call.argument<String>("style")
                            ?: "default"
                        if (!Settings.canDrawOverlays(this)) {
                            result.success(false)
                        } else {
                            FloatingBallService.start(this, style)
                            result.success(true)
                        }
                    }
                    "stopFloatingBall" -> {
                        FloatingBallService.stop(this)
                        result.success(true)
                    }
                    "updateFloatingBall" -> {
                        val style = call.argument<String>("style")
                            ?: "default"
                        FloatingBallService.updateStyle(this, style)
                        result.success(true)
                    }
                    "canDrawOverlays" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "requestOverlayPermission" -> {
                        requestOverlayPermission()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        }
    }

    /// 跳转系统「显示在其他应用上层」设置页，引导用户授权悬浮窗权限
    private fun requestOverlayPermission() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName")
        )
        try {
            startActivity(intent)
        } catch (_: Exception) {
            // 部分 ROM 无法跳转到指定包：退化为通用悬浮窗权限设置页
            val fallback = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            try {
                startActivity(fallback)
            } catch (_: Exception) {
                // ignore
            }
        }
    }
}
