import 'package:flutter/material.dart';
import 'package:relaygo/config/theme.dart';
import 'package:relaygo/models/request_log.dart';
import 'package:relaygo/utils/formatters.dart';

/// 单条日志卡片（对应设计稿请求日志条目）
///
/// 上行：状态箭头 + 方法路径（mono）；中行：服务商/模型标签 + 状态徽章；
/// 下行：耗时 + token 用量。状态颜色编码（成功绿 / 4xx 橙 / 错误红）。
/// 整卡可点击（[onTap]），点击后进入日志详情页。
class LogListItem extends StatelessWidget {
  final RequestLog log;
  final VoidCallback? onTap;

  const LogListItem({Key? key, required this.log, this.onTap})
      : super(key: key);

  /// 状态颜色编码：5xx/代理错误=红，4xx=橙，其余=绿
  Color _statusColor(BuildContext context) {
    if (log.isError) return Theme.of(context).colorScheme.error;
    if (log.statusCode >= 400 && log.statusCode < 500) {
      return const Color(0xFFFF9800);
    }
    return const Color(0xFF4CAF50);
  }

  /// 状态徽章配色（对应设计稿 status-chip ok/bad）
  Color _chipBg(BuildContext context) {
    if (log.isError || (log.statusCode >= 400 && log.statusCode < 500)) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color _chipFg(BuildContext context) {
    if (log.isError || (log.statusCode >= 400 && log.statusCode < 500)) {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    final chipBg = _chipBg(context);
    final chipFg = _chipFg(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上行：状态箭头 + 方法路径
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${log.method} ${log.path}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.monoFontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right,
                        size: 18,
                        color: Theme.of(context).colorScheme.outline),
                ],
              ),
              // 中行：服务商/模型标签 + 状态徽章
              const SizedBox(height: 8),
              Row(
                children: [
                  _monoTag(context, log.provider),
                  if (log.model.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _monoTag(context, log.model),
                  ],
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${log.statusCode}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: chipFg,
                        fontFamily: AppTheme.monoFontFamily,
                      ),
                    ),
                  ),
                ],
              ),
              // 下行：耗时 + token + 错误信息
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 13,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDuration(log.durationMs),
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (log.totalTokens > 0) ...[
                    const SizedBox(width: 14),
                    Icon(Icons.token,
                        size: 13,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      '${Formatters.formatNumber(log.totalTokens)} tokens',
                      style: TextStyle(
                          fontSize: 11.5,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                  const Spacer(),
                  if (log.error != null && log.error!.isNotEmpty)
                    Flexible(
                      child: Text(
                        log.error!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    )
                  else
                    Text(
                      Formatters.formatRelative(log.timestamp),
                      style: TextStyle(
                          fontSize: 11.5,
                          color: Theme.of(context).colorScheme.outline),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monoTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 11.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
