import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relaygo/app.dart';
import 'package:relaygo/config/constants.dart';
import 'package:relaygo/config/theme.dart';
import 'package:relaygo/services/keep_alive.dart';
import 'package:relaygo/screens/update_screen.dart';
import 'package:relaygo/screens/license_screen.dart';
import 'package:relaygo/utils/validators.dart';
import 'package:relaygo/l10n/app_strings.dart';

/// 设置页（对应设计稿设置）
///
/// 分组列表：服务器配置 / Key 管理 / 响应缓存与限流 / 模型同步 /
/// 通知与告警 / 后台保活 / 外观与安全 / 数据管理 / 关于。
/// 每组为一张卡片，行内含标题 + 副标题 + 尾部控件（开关 / 选择 / 按钮）。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _port;
  late String _host;
  late String _strategy;
  late String _lang;
  late bool _appLock;
  // 更新：GitHub 发布仓库（方案一 owner/repo）
  late String _githubRepo;
  // 注意：必须在这里立即实例化，否则 initState 访问 _githubCtrl.text 会触发
  // LateInitializationError（页面灰屏）。
  final TextEditingController _githubCtrl = TextEditingController();

  // 日志
  late int _logRetentionDays;
  late int _maxLogEntries;

  // 额度 / 告警
  late double _quotaWarn;
  late double _errorRate;
  late bool _alertsEnabled;

  // 规则 / 限流
  late bool _rulesEnabled;
  late bool _rateLimitEnabled;
  late int _upstreamTimeout;
  late int _maxRetryKeys;

  // —— 响应缓存 ——
  late bool _cacheEnabled;
  late int _cacheTtl;
  late int _cacheMaxEntries;

  // —— 高级限流 ——
  late int _ipRpm;
  late int _globalRpm;
  late int _tokenRpm;
  late double _burst;

  // —— 模型列表同步 ——
  late bool _autoSyncModels;
  late int _modelSyncInterval;
  late bool _autoDisableRemoved;
  late bool _virtualModelsEnabled;

  // —— 自适应 TPM 挡板 ——
  late bool _adaptiveTpm;

  // —— 保活（后台持续运行）——
  late bool _keepAliveEnabled;
  late bool _autoStartOnBoot;
  late bool _ignoreBatteryOptimization;
  late bool _floatingBallEnabled;
  late String _floatingBallStyle;
  late double _floatingBallOpacity;

  // —— Relay 服务访问密钥 ——
  late bool _relayAuthEnabled;
  late String _relayAccessToken;

  final _portCtrl = TextEditingController();
  final _logRetentionCtrl = TextEditingController();
  final _maxLogCtrl = TextEditingController();
  final _timeoutCtrl = TextEditingController();
  final _retryCtrl = TextEditingController();
  final _cacheTtlCtrl = TextEditingController();
  final _cacheMaxCtrl = TextEditingController();
  final _ipRpmCtrl = TextEditingController();
  final _globalRpmCtrl = TextEditingController();
  final _tokenRpmCtrl = TextEditingController();
  final _burstCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = Provider.of<AppState>(context, listen: false).settings;
    _port = s.port;
    _host = s.host;
    _strategy = s.loadBalanceStrategy;
    _lang = s.language;
    _appLock = s.appLockEnabled;
    _logRetentionDays = s.logRetentionDays;
    _maxLogEntries = s.maxLogEntries;
    _quotaWarn = s.quotaWarnThreshold;
    _errorRate = s.errorRateThreshold;
    _alertsEnabled = s.alertsEnabled;
    _rulesEnabled = s.rulesEnabled;
    _rateLimitEnabled = s.rateLimitEnabled;
    _upstreamTimeout = s.upstreamTimeoutSeconds;
    _maxRetryKeys = s.maxRetryKeys;
    _cacheEnabled = s.cacheEnabled;
    _cacheTtl = s.cacheTtlSeconds;
    _cacheMaxEntries = s.cacheMaxEntries;
    _ipRpm = s.ipRateLimitPerMinute;
    _globalRpm = s.globalRpmLimit;
    _tokenRpm = s.tokenRateLimitPerMinute;
    _burst = s.burstMultiplier;
    _autoSyncModels = s.autoSyncModelsOnStartup;
    _modelSyncInterval = s.modelSyncIntervalHours;
    _autoDisableRemoved = s.autoDisableRemovedModels;
    _virtualModelsEnabled = s.virtualModelsEnabled;
    _adaptiveTpm = s.adaptiveTpmEnabled;
    _keepAliveEnabled = s.keepAliveEnabled;
    _autoStartOnBoot = s.autoStartOnBoot;
    _ignoreBatteryOptimization = s.ignoreBatteryOptimization;
    _floatingBallEnabled = s.floatingBallEnabled;
    _floatingBallStyle = s.floatingBallStyle;
    _floatingBallOpacity = s.floatingBallOpacity;
    _relayAuthEnabled = s.relayAuthEnabled;
    _relayAccessToken = s.relayAccessToken ?? _generateAccessToken();
    _githubRepo = s.updateGithubRepo;

    _portCtrl.text = '$_port';
    _githubCtrl.text = _githubRepo;
    _logRetentionCtrl.text = '$_logRetentionDays';
    _maxLogCtrl.text = '$_maxLogEntries';
    _timeoutCtrl.text = '$_upstreamTimeout';
    _retryCtrl.text = '$_maxRetryKeys';
    _cacheTtlCtrl.text = '$_cacheTtl';
    _cacheMaxCtrl.text = '$_cacheMaxEntries';
    _ipRpmCtrl.text = '$_ipRpm';
    _globalRpmCtrl.text = '$_globalRpm';
    _tokenRpmCtrl.text = '$_tokenRpm';
    _burstCtrl.text = _burst.toString();
  }

  /// 生成一个随机访问密钥（前缀 sk-relaygo- 便于工具识别，如 sk-relaygo-xxxx）
  String _generateAccessToken() {
    final rnd = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return 'sk-relaygo-' +
        List.generate(32, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// 复制访问密钥到剪贴板
  Future<void> _copyAccessToken() async {
    if (!_relayAuthEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.tr('请先启用访问密钥'))));
      return;
    }
    await Clipboard.setData(ClipboardData(text: _relayAccessToken));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(L10n.tr('密钥已复制'))));
  }

  /// 重新生成访问密钥（需二次确认：旧密钥立即失效）
  Future<void> _regenerateAccessToken() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.tr('重新生成密钥？')),
        content: Text(L10n.tr('重新生成后旧密钥将立即失效，已配置的工具需要更新。')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L10n.tr('取消'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(L10n.tr('生成密钥'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _relayAccessToken = _generateAccessToken());
  }

  @override
  void dispose() {
    _portCtrl.dispose();
    _githubCtrl.dispose();
    _logRetentionCtrl.dispose();
    _maxLogCtrl.dispose();
    _timeoutCtrl.dispose();
    _retryCtrl.dispose();
    _cacheTtlCtrl.dispose();
    _cacheMaxCtrl.dispose();
    _ipRpmCtrl.dispose();
    _globalRpmCtrl.dispose();
    _tokenRpmCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppState app) async {
    if (Validators.validatePort(_portCtrl.text) != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L10n.tr('端口不合法'))));
      return;
    }
    final newSettings = app.settings.copyWith(
      port: int.parse(_portCtrl.text),
      host: _host,
      loadBalanceStrategy: _strategy,
      language: _lang,
      appLockEnabled: _appLock,
      logRetentionDays:
          int.tryParse(_logRetentionCtrl.text) ?? _logRetentionDays,
      maxLogEntries: int.tryParse(_maxLogCtrl.text) ?? _maxLogEntries,
      quotaWarnThreshold: _quotaWarn,
      errorRateThreshold: _errorRate,
      alertsEnabled: _alertsEnabled,
      rulesEnabled: _rulesEnabled,
      rateLimitEnabled: _rateLimitEnabled,
      upstreamTimeoutSeconds:
          int.tryParse(_timeoutCtrl.text) ?? _upstreamTimeout,
      maxRetryKeys: int.tryParse(_retryCtrl.text) ?? _maxRetryKeys,
      cacheEnabled: _cacheEnabled,
      cacheTtlSeconds: int.tryParse(_cacheTtlCtrl.text) ?? _cacheTtl,
      cacheMaxEntries: int.tryParse(_cacheMaxCtrl.text) ?? _cacheMaxEntries,
      ipRateLimitPerMinute: int.tryParse(_ipRpmCtrl.text) ?? _ipRpm,
      globalRpmLimit: int.tryParse(_globalRpmCtrl.text) ?? _globalRpm,
      tokenRateLimitPerMinute: int.tryParse(_tokenRpmCtrl.text) ?? _tokenRpm,
      burstMultiplier: double.tryParse(_burstCtrl.text) ?? _burst,
      adaptiveTpmEnabled: _adaptiveTpm,
      updateGithubRepo: _githubCtrl.text.trim(),
      autoSyncModelsOnStartup: _autoSyncModels,
      modelSyncIntervalHours: _modelSyncInterval,
      autoDisableRemovedModels: _autoDisableRemoved,
      virtualModelsEnabled: _virtualModelsEnabled,
      keepAliveEnabled: _keepAliveEnabled,
      autoStartOnBoot: _autoStartOnBoot,
      ignoreBatteryOptimization: _ignoreBatteryOptimization,
      floatingBallEnabled: _floatingBallEnabled,
      floatingBallStyle: _floatingBallStyle,
      floatingBallOpacity: _floatingBallOpacity,
      relayAuthEnabled: _relayAuthEnabled,
      relayAccessToken:
          _relayAuthEnabled ? _relayAccessToken : _relayAccessToken,
    );
    await app.saveSettings(newSettings);
    // 开启「忽略电池优化」时，请求系统授权（弹出系统对话框）
    if (_ignoreBatteryOptimization) {
      await _requestBatteryExemption();
    }
    // 开启悬浮条时，检查悬浮窗权限；未授权则引导用户前往系统设置开启
    if (_floatingBallEnabled) {
      await _ensureOverlayPermission();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(L10n.tr('设置已保存'))));
  }

  /// 悬浮条开启前检查「显示在其他应用上层」权限；未授权则弹窗引导。
  Future<void> _ensureOverlayPermission() async {
    final granted = await KeepAliveHelper.canDrawOverlays();
    if (granted) return;
    if (!mounted) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.tr('需要悬浮窗权限')),
        content: Text(L10n.tr('悬浮条需要「显示在其他应用上层」权限，才能常驻屏幕防止后台被系统回收。')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L10n.tr('取消'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(L10n.tr('去授权')),
          ),
        ],
      ),
    );
    if (go == true) {
      await KeepAliveHelper.requestOverlayPermission();
    }
  }

  /// 请求加入电池优化白名单；若系统已忽略则跳过。
  /// 若系统未弹出授权框（部分 ROM 屏蔽），引导用户前往系统设置手动开启。
  Future<void> _requestBatteryExemption() async {
    final ignoring = await KeepAliveHelper.isIgnoringBatteryOptimizations();
    if (ignoring) return;
    await KeepAliveHelper.requestIgnoreBatteryOptimizations();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(L10n.tr('若未弹出授权框，请到「系统设置 → 应用 → 电池优化」中手动允许')),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final t = L10n.instance;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('设置'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _section(t.t('服务器配置')),
          _card([
            _row(
              title: t.t('端口'),
              subtitle: L10n.tr('Relay 服务监听端口'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _monoTag('$_port'),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _editPort(context),
                    child: Text(L10n.tr('修改')),
                  ),
                ],
              ),
            ),
            _row(
              title: t.t('监听地址'),
              subtitle: L10n.tr('0.0.0.0（所有网卡）或 127.0.0.1（仅本机）'),
              trailing: _monoTag(_host),
            ),
            _row(
              title: t.t('负载均衡策略'),
              trailing: _select<String>(
                value: _strategy,
                items: [
                  DropdownMenuItem(
                      value: 'round_robin', child: Text(L10n.tr('轮询'))),
                  DropdownMenuItem(
                      value: 'weighted_round_robin',
                      child: Text(L10n.tr('加权轮询'))),
                  DropdownMenuItem(
                      value: 'priority', child: Text(L10n.tr('优先级'))),
                  DropdownMenuItem(
                      value: 'least_connections',
                      child: Text(L10n.tr('最少连接'))),
                  DropdownMenuItem(
                      value: 'response_time', child: Text(L10n.tr('响应时间'))),
                  DropdownMenuItem(value: 'smart', child: Text(L10n.tr('智能'))),
                ],
                onChanged: (v) => setState(() => _strategy = v!),
              ),
            ),
            _row(
              title: t.t('自动启动'),
              subtitle: L10n.tr('开机后自动运行服务'),
              trailing: _switch(_autoStartOnBoot,
                  (v) => setState(() => _autoStartOnBoot = v)),
            ),
            _row(
              title: t.t('局域网访问'),
              subtitle: L10n.tr('允许局域网内设备连接'),
              trailing: _switch(
                  _host != '127.0.0.1',
                  (v) => setState(
                      () => _host = v ? '0.0.0.0' : '127.0.0.1')),
            ),
          ]),
          _section(t.t('访问密钥')),
          _card([
            _row(
              title: t.t('访问密钥'),
              subtitle: L10n.tr('启用后连接工具需填写此密钥（Authorization: Bearer）'),
              trailing: _switch(
                  _relayAuthEnabled,
                  (v) => setState(() => _relayAuthEnabled = v)),
            ),
            if (_relayAuthEnabled)
              _row(
                title: t.t('密钥'),
                subtitle: _relayAccessToken,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: L10n.tr('复制密钥'),
                      onPressed: _copyAccessToken,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _regenerateAccessToken,
                      child: Text(L10n.tr('生成密钥')),
                    ),
                  ],
                ),
              ),
          ]),
          _section(t.t('Key 管理')),
          _card([
            _row(
              title: t.t('自动测试间隔'),
              trailing: _select<int>(
                value: _modelSyncInterval,
                items: [
                  DropdownMenuItem(value: 1, child: Text(L10n.tr('1 小时'))),
                  DropdownMenuItem(value: 6, child: Text(L10n.tr('6 小时'))),
                  DropdownMenuItem(value: 12, child: Text(L10n.tr('12 小时'))),
                  DropdownMenuItem(value: 24, child: Text(L10n.tr('24 小时'))),
                ],
                onChanged: (v) => setState(() => _modelSyncInterval = v!),
              ),
            ),
            _row(
              title: t.t('失效自动禁用'),
              subtitle: L10n.tr('测试失败自动停用 Key'),
              trailing: _switch(_rateLimitEnabled,
                  (v) => setState(() => _rateLimitEnabled = v)),
            ),
            _row(
              title: t.t('启用规则引擎'),
              subtitle: L10n.tr('按规则智能路由请求'),
              trailing: _switch(
                  _rulesEnabled, (v) => setState(() => _rulesEnabled = v)),
            ),
            _row(
              title: t.t('单请求最多切换 key 数'),
              trailing: _numberField(_retryCtrl, '$_maxRetryKeys'),
            ),
          ]),
          _section(t.t('响应缓存与限流')),
          _card([
            _row(
              title: t.t('启用响应缓存'),
              subtitle: L10n.tr('缓存可复用幂等的 2xx 响应'),
              trailing: _switch(
                  _cacheEnabled, (v) => setState(() => _cacheEnabled = v)),
            ),
            _row(
              title: t.t('缓存 TTL (秒)'),
              trailing: _numberField(_cacheTtlCtrl, '$_cacheTtl'),
            ),
            _row(
              title: t.t('缓存条目上限'),
              trailing: _numberField(_cacheMaxCtrl, '$_cacheMaxEntries'),
            ),
            _row(
              title: t.t('单 IP 每分钟请求上限'),
              subtitle: L10n.tr('0 = 不限制'),
              trailing: _numberField(_ipRpmCtrl, '$_ipRpm'),
            ),
            _row(
              title: t.t('全局每分钟请求上限'),
              subtitle: L10n.tr('0 = 不限制'),
              trailing: _numberField(_globalRpmCtrl, '$_globalRpm'),
            ),
            _row(
              title: t.t('单 key 每分钟 Token 上限'),
              subtitle: L10n.tr('0 = 不限制'),
              trailing: _numberField(_tokenRpmCtrl, '$_tokenRpm'),
            ),
            _row(
              title: t.t('令牌桶突发倍数'),
              trailing: _numberField(_burstCtrl, _burst.toString()),
            ),
            _row(
              title: t.t('自适应 TPM 限流'),
              subtitle: L10n.tr('默认开启。学习上游速率上限并提前挡板，遇到临时 TPM 限流(429)时在同一 key 上等待窗口刷新后自动重试；超出等待预算才提示客户端稍后重发，尽量不中断'),
              trailing: _switch(
                  _adaptiveTpm, (v) => setState(() => _adaptiveTpm = v)),
            ),
          ]),
          _section(t.t('模型同步')),
          _card([
            _row(
              title: t.t('启动时自动同步模型列表'),
              subtitle: L10n.tr('应用启动时从各服务商拉取最新模型'),
              trailing: _switch(
                  _autoSyncModels, (v) => setState(() => _autoSyncModels = v)),
            ),
            _row(
              title: t.t('自动禁用已下线的模型'),
              subtitle: L10n.tr('同步后未出现的历史模型标记为已下线'),
              trailing: _switch(_autoDisableRemoved,
                  (v) => setState(() => _autoDisableRemoved = v)),
            ),
            _row(
              title: t.t('虚拟模型层'),
              subtitle: L10n.tr('默认关闭。关闭时返回真实模型并原样透传；开启后按能力档位收敛为少量虚拟模型'),
              trailing: _switch(_virtualModelsEnabled,
                  (v) => setState(() => _virtualModelsEnabled = v)),
            ),
          ]),
          _section(t.t('通知与告警')),
          _card([
            _row(
              title: t.t('启用告警'),
              subtitle: L10n.tr('额度 / 错误率触发时通知'),
              trailing: _switch(
                  _alertsEnabled, (v) => setState(() => _alertsEnabled = v)),
            ),
            _row(
              title: t.t('额度预警阈值'),
              subtitle: L10n.fmt('达到 {pct}% 触发预警',
                  {'pct': '${(_quotaWarn * 100).toStringAsFixed(0)}'}),
              trailing: _slider(
                value: _quotaWarn,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                label: '${(_quotaWarn * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => _quotaWarn = v),
              ),
            ),
            _row(
              title: t.t('错误率告警阈值'),
              subtitle: L10n.fmt('超过 {pct}% 触发',
                  {'pct': '${(_errorRate * 100).toStringAsFixed(0)}'}),
              trailing: _slider(
                value: _errorRate,
                min: 0.1,
                max: 1.0,
                divisions: 18,
                label: '${(_errorRate * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => _errorRate = v),
              ),
            ),
          ]),
          _section(t.t('日志管理')),
          _card([
            _row(
              title: t.t('日志保留天数'),
              subtitle: L10n.tr('0 = 不自动清理'),
              trailing: _numberField(_logRetentionCtrl, '$_logRetentionDays'),
            ),
            _row(
              title: t.t('日志条数上限'),
              trailing: _numberField(_maxLogCtrl, '$_maxLogEntries'),
            ),
            _row(
              title: t.t('上游超时 (秒)'),
              trailing: _numberField(_timeoutCtrl, '$_upstreamTimeout'),
            ),
          ]),
          _section(t.t('后台保活')),
          _card([
            _row(
              title: t.t('后台保活'),
              subtitle: L10n.tr('前台服务 + 常驻通知，防止系统回收进程'),
              trailing: _switch(
                  _keepAliveEnabled, (v) => setState(() => _keepAliveEnabled = v)),
            ),
            _row(
              title: t.t('忽略电池优化'),
              subtitle: L10n.tr('加入白名单，避免 Doze 模式被杀'),
              trailing: _switch(_ignoreBatteryOptimization, (v) async {
                setState(() => _ignoreBatteryOptimization = v);
                if (v) await _requestBatteryExemption();
              }),
            ),
            _row(
              title: t.t('悬浮条'),
              subtitle: L10n.tr('半透明悬浮条常驻屏幕，贴边隐藏，轻触唤起'),
              trailing: _switch(
                  _floatingBallEnabled,
                  (v) => setState(() => _floatingBallEnabled = v)),
            ),
            if (_floatingBallEnabled)
              _row(
                title: t.t('主题色'),
                trailing: _select<String>(
                  value: _floatingBallStyle,
                  items: [
                    for (final c in Constants.floatingBarColors)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _colorDot(c),
                            const SizedBox(width: 8),
                            Text(_colorName(c)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => _floatingBallStyle = v!),
                ),
),
            if (_floatingBallEnabled)
              _row(
                title: t.t('透明度'),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: _floatingBallOpacity,
                    min: 0.2,
                    max: 1.0,
                    divisions: 8,
                    label: '${(_floatingBallOpacity * 100).toStringAsFixed(0)}%',
                    activeColor: AppTheme.brandGreen,
                    onChanged: (v) =>
                        setState(() => _floatingBallOpacity = v),
                  ),
                ),
              ),
          ]),
          _section(t.t('外观与安全')),
          _card([
            _row(
              title: t.t('语言'),
              trailing: _select<String>(
                value: _lang,
                items: [
                  DropdownMenuItem(value: 'zh', child: Text(L10n.tr('中文'))),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) {
                  setState(() {
                    _lang = v!;
                    L10n.instance.setLanguage(v);
                  });
                },
              ),
            ),
            _row(
              title: t.t('应用锁'),
              subtitle: L10n.tr('（生物识别 / PIN）'),
              trailing:
                  _switch(_appLock, (v) => setState(() => _appLock = v)),
            ),
          ]),
          _section(t.t('关于')),
          _card([
            _row(
              leading: const Icon(Icons.info_outline,
                  size: 20, color: AppTheme.brandGreen),
              title: Constants.appName,
              subtitle: 'v${Constants.appVersion}',
              trailing: _chip(L10n.tr('最新版'), AppTheme.surface2, AppTheme.text2),
            ),
            _row(
              title: t.t('检查更新'),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _checkUpdate(context),
                child: Text(L10n.tr('检查')),
              ),
            ),
            _row(
              title: t.t('GitHub 发布仓库'),
              subtitle: _githubRepo.isEmpty
                  ? L10n.tr('未配置，走静态清单回退')
                  : _githubRepo,
              trailing: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _editGithubRepo(context),
                child: Text(L10n.tr('设置')),
              ),
            ),
            _row(
              title: t.t('开源协议'),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _showLicense(context),
                child: Text(L10n.tr('查看')),
              ),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t.t('保存设置')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _save(app),
          ),
        ),
      ),
    );
  }

  // ———————— 分组标题（对应设计稿 section label）———————
  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.04,
            color: Color(0xFF006B3F),
          ),
        ),
      );

  // ———————— 卡片（对应设计稿 m3-card，行间分隔线）———————
  Widget _card(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              if (i > 0)
                const Divider(
                    height: 1, thickness: 1, indent: 16, color: AppTheme.border),
              rows[i],
            ],
          );
        }),
      ),
    );
  }

  // ———————— 行（对应设计稿 m3-row）———————
  Widget _row({
    Widget? leading,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.text2)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _monoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 12,
          color: AppTheme.text2,
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _switch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.brandGreen,
    );
  }

  Color _colorValue(String style) {
    switch (style) {
      case Constants.floatingBarColorBlue:
        return const Color(0xFF2196F3);
      case Constants.floatingBarColorPurple:
        return const Color(0xFF9C27B0);
      case Constants.floatingBarColorOrange:
        return const Color(0xFFFF9800);
      case Constants.floatingBarColorRed:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF34D193);
    }
  }

  String _colorName(String style) {
    switch (style) {
      case Constants.floatingBarColorBlue:
        return L10n.tr('蓝色');
      case Constants.floatingBarColorPurple:
        return L10n.tr('紫色');
      case Constants.floatingBarColorOrange:
        return L10n.tr('橙色');
      case Constants.floatingBarColorRed:
        return L10n.tr('红色');
      default:
        return L10n.tr('绿色');
    }
  }

  Widget _colorDot(String style) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _colorValue(style),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _select<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    // 防御：升级后保留的持久化设置可能残留不在下拉项中的值，
    // DropdownButton 会因此断言导致整页灰屏。这里仅在展示时回退到首个
    // 合法项，不修改真实设置，用户下次保存即修复。
    final safeValue =
        items.any((i) => i.value == value) ? value : items.first.value;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: safeValue,
          isDense: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 13, color: AppTheme.text, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.expand_more, size: 18),
        ),
      ),
    );
  }

  Widget _slider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    // 防御：持久化值可能越界或未对齐到 divisions 档位，Slider 会因此断言
    // 导致整页灰屏。这里先钳制到 [min,max]，再吸附到最近的档位。
    final raw = value.clamp(min, max);
    final snapped = divisions > 0
        ? (min + ((raw - min) / ((max - min) / divisions)).round() *
            ((max - min) / divisions))
        : raw;
    return SizedBox(
      width: 160,
      child: Slider(
        value: snapped,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        activeColor: AppTheme.brandGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _numberField(TextEditingController ctrl, String hint) {
    return SizedBox(
      width: 90,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _editPort(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.tr('修改端口')),
        content: TextField(
          controller: _portCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(labelText: L10n.tr('监听端口')),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(L10n.tr('取消'))),
          TextButton(
            onPressed: () {
              setState(() => _port = int.tryParse(_portCtrl.text) ?? _port);
              Navigator.pop(ctx);
            },
            child: Text(L10n.tr('确定')),
          ),
        ],
      ),
    );
  }

  void _checkUpdate(BuildContext context) {
    // 方案一：进入「关于与更新」页进行手动检查 / 下载 / 安装
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const UpdateScreen()),
    );
  }

  void _editGithubRepo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.tr('GitHub 发布仓库')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _githubCtrl,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: L10n.tr('格式：owner/repo'),
                hintText: 'owner/relaygo',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              L10n.tr('留空将回退到静态更新清单'),
              style: const TextStyle(fontSize: 12, color: AppTheme.text2),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(L10n.tr('取消'))),
          TextButton(
            onPressed: () {
              setState(() {
                _githubRepo = _githubCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: Text(L10n.tr('确定')),
          ),
        ],
      ),
    );
  }

  void _showLicense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LicenseScreen()),
    );
  }
}