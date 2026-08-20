package com.relaygo.app

import android.animation.Animator
import android.animation.ValueAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

class FloatingBallService : Service() {

    companion object {
        private const val CHANNEL_ID = "floating_ball"
        private const val NOTIFICATION_ID = 1002

        const val ACTION_START = "com.relaygo.app.action.FB_START"
        const val ACTION_STOP = "com.relaygo.app.action.FB_STOP"
        const val ACTION_UPDATE_STYLE = "com.relaygo.app.action.FB_UPDATE_STYLE"
        const val EXTRA_STYLE = "style"

        private const val BAR_HEIGHT_DP = 36
        private const val BAR_MIN_WIDTH_DP = 150
        private const val CORNER_RADIUS_DP = 14
        private const val EDGE_THRESHOLD_DP = 60
        private const val SNAP_ANIM_MS = 250L

        @Volatile
        private var currentStyle: String = "green"

        @JvmStatic
        fun currentStyle(): String = currentStyle

        @JvmStatic
        fun start(context: Context, style: String) {
            currentStyle = style
            val intent = Intent(context, FloatingBallService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_STYLE, style)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        @JvmStatic
        fun stop(context: Context) {
            val intent = Intent(context, FloatingBallService::class.java)
            try { context.stopService(intent) } catch (_: Exception) { }
        }

        @JvmStatic
        fun updateStyle(context: Context, style: String) {
            currentStyle = style
            val intent = Intent(context, FloatingBallService::class.java)
                .setAction(ACTION_UPDATE_STYLE)
                .putExtra(EXTRA_STYLE, style)
            try { context.startService(intent) } catch (_: Exception) { }
        }
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    private var barView: View? = null
    private var panelView: View? = null
    private var statusDot: View? = null
    private var barBackground: GradientDrawable? = null

    private var accentColor = Color.rgb(52, 211, 153)
    private var barOpacity = 204

    private val density by lazy { resources.displayMetrics.density }

    private var panelVisible = false
    private var isAnimating = false

    private var touchStartX = 0f
    private var touchStartY = 0f
    private var winStartX = 0
    private var winStartY = 0
    private var isDragging = false
    private var moved = false
    private var dragThreshold = 0

    private var barWidth = 0
    private var barHeight = 0

    override fun onCreate() {
        super.onCreate()
        createChannel()
        dragThreshold = ViewConfiguration.get(this).scaledTouchSlop
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopForeground(true)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_UPDATE_STYLE -> {
                intent.getStringExtra(EXTRA_STYLE)?.let { style ->
                    currentStyle = style
                    applyStyle(style)
                }
                return START_STICKY
            }
            else -> {
                val style = intent?.getStringExtra(EXTRA_STYLE) ?: currentStyle
                currentStyle = style
                applyStyle(style)
                startAsForeground()
                showFloatingBar()
                return START_STICKY
            }
        }
    }

    private fun startAsForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun showFloatingBar() {
        if (overlayView != null) return
        if (!Settings.canDrawOverlays(this)) return

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val root = FrameLayout(this)
        root.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )

        barWidth = dp(BAR_MIN_WIDTH_DP)
        barHeight = dp(BAR_HEIGHT_DP)
        val bar = buildBar()
        root.addView(bar)

        val panel = buildPanel()
        val panelLp = FrameLayout.LayoutParams(dp(190), FrameLayout.LayoutParams.WRAP_CONTENT)
        panelLp.topMargin = dp(BAR_HEIGHT_DP + 4)
        root.addView(panel, panelLp)
        panel.visibility = View.GONE
        panelView = panel

        barView = root

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            android.graphics.PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = screenWidthPx() - barWidth - dp(12)
        params.y = screenHeightPx() / 3
        layoutParams = params

        bar.setOnTouchListener { _, event -> handleTouch(event) }
        panel.setOnTouchListener { _, _ -> true }

        try {
            windowManager?.addView(root, params)
            overlayView = root
            barView?.post {
                barWidth = bar.width.coerceAtLeast(dp(BAR_MIN_WIDTH_DP))
                barHeight = bar.height.coerceAtLeast(dp(BAR_HEIGHT_DP))
            }
        } catch (_: Exception) { }
    }

    private fun buildBar(): View {
        val bar = LinearLayout(this)
        bar.orientation = LinearLayout.HORIZONTAL
        bar.gravity = Gravity.CENTER_VERTICAL
        bar.setPadding(dp(12), 0, dp(12), 0)

        val bg = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(CORNER_RADIUS_DP).toFloat()
            setColor(Color.argb(barOpacity, 18, 18, 18))
            setStroke(dp(1), Color.argb(50, 255, 255, 255))
        }
        bar.background = bg
        barBackground = bg

        val dot = View(this)
        val dotLp = LinearLayout.LayoutParams(dp(7), dp(7))
        dotLp.rightMargin = dp(7)
        val dotBg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(accentColor)
        }
        dot.background = dotBg
        bar.addView(dot, dotLp)
        statusDot = dot

        val label = TextView(this)
        label.text = "RelayGo"
        label.setTextColor(Color.WHITE)
        label.textSize = 13f
        label.typeface = android.graphics.Typeface.DEFAULT_BOLD
        label.includeFontPadding = false
        bar.addView(label)

        val status = TextView(this)
        status.text = "运行中"
        status.setTextColor(Color.argb(180, 255, 255, 255))
        status.textSize = 10f
        status.includeFontPadding = false
        val statusLp = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        statusLp.leftMargin = dp(6)
        bar.addView(status, statusLp)

        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            dp(BAR_HEIGHT_DP)
        )
        bar.layoutParams = lp
        return bar
    }

    private fun buildPanel(): View {
        val panel = LinearLayout(this)
        panel.orientation = LinearLayout.VERTICAL
        panel.setPadding(dp(12), dp(10), dp(12), dp(10))
        panel.gravity = Gravity.CENTER_VERTICAL
        panel.background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(12).toFloat()
            setColor(Color.argb(220, 18, 18, 18))
            setStroke(dp(1), Color.argb(40, 255, 255, 255))
        }

        val statusRow = LinearLayout(this)
        statusRow.orientation = LinearLayout.HORIZONTAL
        statusRow.gravity = Gravity.CENTER_VERTICAL

        val dot = View(this)
        val dotLp = LinearLayout.LayoutParams(dp(6), dp(6))
        val dotBg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(accentColor)
        }
        dot.background = dotBg
        statusRow.addView(dot, dotLp)

        val st = TextView(this)
        st.text = "代理运行中"
        st.setTextColor(Color.WHITE)
        st.textSize = 13f
        val sLp = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        sLp.leftMargin = dp(8)
        statusRow.addView(st, sLp)
        panel.addView(statusRow)

        val btnRow = LinearLayout(this)
        btnRow.orientation = LinearLayout.HORIZONTAL
        btnRow.gravity = Gravity.CENTER_VERTICAL
        val btnRowLp = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        btnRowLp.topMargin = dp(10)
        panel.addView(btnRow, btnRowLp)

        val openBtn = TextView(this)
        openBtn.text = "打开应用"
        openBtn.gravity = Gravity.CENTER
        openBtn.setTextColor(Color.WHITE)
        openBtn.textSize = 12f
        openBtn.background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(8).toFloat()
            setColor(accentColor)
        }
        val openLp = LinearLayout.LayoutParams(0, dp(32), 1f)
        openLp.rightMargin = dp(8)
        openBtn.setOnClickListener { openApp() }
        btnRow.addView(openBtn, openLp)

        val closeBtn = TextView(this)
        closeBtn.text = "关闭悬浮条"
        closeBtn.gravity = Gravity.CENTER
        closeBtn.setTextColor(Color.WHITE)
        closeBtn.textSize = 12f
        closeBtn.background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(8).toFloat()
            setColor(Color.rgb(71, 85, 105))
        }
        val closeLp = LinearLayout.LayoutParams(0, dp(32), 1f)
        closeBtn.setOnClickListener { stopSelf() }
        btnRow.addView(closeBtn, closeLp)

        return panel
    }

    private fun handleTouch(event: MotionEvent): Boolean {
        val params = layoutParams ?: return true
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchStartX = event.rawX
                touchStartY = event.rawY
                winStartX = params.x
                winStartY = params.y
                isDragging = true
                moved = false
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                if (!isDragging) return true
                val dx = event.rawX - touchStartX
                val dy = event.rawY - touchStartY
                if (!moved && (kotlin.math.abs(dx) > dragThreshold ||
                        kotlin.math.abs(dy) > dragThreshold)
                ) {
                    moved = true
                    if (panelVisible) togglePanel(false)
                }
                if (moved) {
                    params.x = winStartX + dx.toInt()
                    params.y = winStartY + dy.toInt()
                    try {
                        windowManager?.updateViewLayout(overlayView, params)
                    } catch (_: Exception) { }
                }
                return true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isDragging = false
                if (!moved) {
                    togglePanel(!panelVisible)
                } else {
                    snapToEdge()
                }
                return true
            }
        }
        return true
    }

    private fun togglePanel(show: Boolean) {
        val panel = panelView ?: return
        if (show == panelVisible) return
        panelVisible = show

        if (show) {
            panel.visibility = View.VISIBLE
            panel.translationY = -16f
            panel.alpha = 0f
            panel.animate()
                .translationY(0f)
                .alpha(1f)
                .setDuration(200)
                .start()
        } else {
            panel.animate()
                .alpha(0f)
                .translationY(-16f)
                .setDuration(150)
                .withEndAction { panel.visibility = View.GONE }
                .start()
        }
    }

    private fun snapToEdge() {
        if (isAnimating) return
        val params = layoutParams ?: return
        val sw = screenWidthPx()
        val sh = screenHeightPx()
        // 使用悬浮条实际渲染宽度（WRAP_CONTENT 内容宽度），
        // 避免用初始估算宽度导致右侧吸附后留缝
        val w = (overlayView?.width ?: 0).takeIf { it > 0 }
            ?: barWidth.coerceAtLeast(dp(BAR_MIN_WIDTH_DP))
        val h = barHeight.coerceAtLeast(dp(BAR_HEIGHT_DP))
        val threshold = dp(EDGE_THRESHOLD_DP)

        val distLeft = params.x
        val distRight = sw - (params.x + w)
        val nearLeft = distLeft <= distRight
        val distFromEdge = if (nearLeft) distLeft else distRight

        if (distFromEdge > threshold) {
            return
        }

        val targetX = if (nearLeft) dp(4) else sw - w - dp(4)
        val targetY = params.y.coerceIn(0, (sh - h).coerceAtLeast(0))
        val startX = params.x

        if (panelVisible) togglePanel(false)

        isAnimating = true
        val animator = ValueAnimator.ofInt(startX, targetX).apply {
            duration = SNAP_ANIM_MS
            addUpdateListener {
                params.x = it.animatedValue as Int
                try {
                    windowManager?.updateViewLayout(overlayView, params)
                } catch (_: Exception) { }
            }
            addListener(object : Animator.AnimatorListener {
                override fun onAnimationEnd(animator: Animator) {
                    params.y = targetY
                    isAnimating = false
                }
                override fun onAnimationStart(animator: Animator) {}
                override fun onAnimationCancel(animator: Animator) { isAnimating = false }
                override fun onAnimationRepeat(animator: Animator) {}
            })
        }
        animator.start()
    }

    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        try { startActivity(intent) } catch (_: Exception) { }
    }

    private fun applyStyle(style: String) {
        val parts = style.split(":")
        val colorName = parts[0]
        if (parts.size > 1) {
            val opacityFloat = parts[1].toFloatOrNull() ?: 0.8f
            barOpacity = (opacityFloat.coerceIn(0.2f, 1.0f) * 255).toInt()
        }
        accentColor = colorForName(colorName)

        barBackground?.setColor(Color.argb(barOpacity, 18, 18, 18))

        val dot = statusDot ?: return
        val bg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(accentColor)
        }
        dot.background = bg
    }

    private fun colorForName(name: String): Int = when (name) {
        "blue" -> Color.rgb(33, 150, 243)
        "purple" -> Color.rgb(156, 39, 176)
        "orange" -> Color.rgb(255, 152, 0)
        "red" -> Color.rgb(244, 67, 54)
        else -> Color.rgb(52, 211, 153)
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java)
        val pending = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("RelayGo")
            .setContentText("悬浮条运行中")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pending)
            .setOngoing(true)
            .setShowWhen(false)
            .build()
    }

    private fun createChannel() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID, "悬浮条",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "悬浮条保活服务"
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun dp(v: Int): Int = (v * density).toInt()
    private fun screenWidthPx(): Int = resources.displayMetrics.widthPixels
    private fun screenHeightPx(): Int = resources.displayMetrics.heightPixels

    override fun onDestroy() {
        try {
            overlayView?.let { windowManager?.removeView(it) }
        } catch (_: Exception) { }
        overlayView = null
        barView = null
        panelView = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}