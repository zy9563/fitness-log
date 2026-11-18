import 'package:flutter/material.dart';

import '../core/app_exception.dart';
import '../core/theme.dart' as app_theme;
import 'edge_fade_list_view.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

/// 统一卡片：圆角、细边、柔和阴影，并自动按卡片底色调整文字颜色。
///
/// 卡片背景会随它在页面中的位置计算一个 0~1 的不透明度：
/// 越靠近 AppBar / 底部导航栏，背景越透明；离开边缘恢复不透明。
/// 页面边缘的整体淡出由 EdgeFadeListView 负责。
/// 统一卡片：圆角、细边、柔和阴影，并自动按卡片底色调整文字颜色。
///
/// 卡片背景透明度会根据它在页面中的位置动态变化：
/// 靠近 AppBar / 底部导航栏时逐渐变透明，离开边缘恢复不透明。
/// 页面级别的上下渐变蒙层由 [EdgeFadeListView] 负责，两者互不替代。
class AppSectionCard extends StatefulWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.onTap,
    this.elevated = false,
    this.edgeFadeRange = 140,
    this.minCardOpacity = 0.52,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool elevated;

  /// 距离上下安全边缘多少像素开始衰减，越大过渡越长。
  final double edgeFadeRange;

  /// 卡片在边缘处的最低背景不透明度。
  final double minCardOpacity;

  @override
  State<AppSectionCard> createState() => _AppSectionCardState();
}

class _AppSectionCardState extends State<AppSectionCard> {
  final _cardKey = GlobalKey();
  final _opacity = ValueNotifier<double>(1);
  ScrollController? _scrollController;
  ScrollPosition? _fallbackPosition;
  bool _measureScheduled = false;
  double _lastOpacity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = EdgeFadeScope.maybeOf(context);
    final controller = scope?.controller;
    if (!identical(controller, _scrollController)) {
      _scrollController?.removeListener(_onScroll);
      _scrollController = controller;
      _scrollController?.addListener(_onScroll);
    }

    // 详情页等不使用 EdgeFadeListView 的页面，回退到最近的 Scrollable。
    final fallback = scope == null
        ? Scrollable.maybeOf(context)?.position
        : null;
    if (!identical(fallback, _fallbackPosition)) {
      _fallbackPosition?.removeListener(_onScroll);
      _fallbackPosition = fallback;
      _fallbackPosition?.addListener(_onScroll);
    }
    _scheduleMeasure();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _fallbackPosition?.removeListener(_onScroll);
    _opacity.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      _measure();
    });
  }

  void _measure() {
    if (!mounted) return;
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final center = top + box.size.height / 2;
    final media = MediaQuery.of(context);
    final topSafe = media.padding.top + kToolbarHeight + 6;
    final bottomSafe = media.size.height - media.padding.bottom - 92;
    final range = widget.edgeFadeRange <= 0 ? 1.0 : widget.edgeFadeRange;
    final topFactor = ((center - topSafe) / range).clamp(0.0, 1.0);
    final bottomFactor = ((bottomSafe - center) / range).clamp(0.0, 1.0);
    final raw = topFactor < bottomFactor ? topFactor : bottomFactor;
    final eased = raw * raw * (3 - 2 * raw);
    final minOpacity = widget.minCardOpacity.clamp(0.0, 1.0);
    final value = minOpacity + (1 - minOpacity) * eased;
    if ((value - _lastOpacity).abs() < 0.01) return;
    _lastOpacity = value;
    _opacity.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = theme.cardColor;
    final themed = Theme(
      data: app_theme.cardTheme(context),
      child: widget.child,
    );
    final content = Material(
      color: Colors.transparent,
      child: Padding(padding: widget.padding, child: themed),
    );
    final tappable = widget.onTap == null
        ? content
        : InkWell(onTap: widget.onTap, child: content);

    return ValueListenableBuilder<double>(
      valueListenable: _opacity,
      builder: (context, opacity, _) {
        final alpha = (255 * opacity).round();
        final borderAlpha = (95 * opacity).round();
        final shadowAlpha = (widget.elevated ? 14 : 8) * opacity;
        return Padding(
          key: _cardKey,
          padding: widget.margin,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: card.withAlpha(alpha),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(borderAlpha),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(shadowAlpha.round()),
                  blurRadius: widget.elevated ? 18 : 12,
                  offset: Offset(0, widget.elevated ? 7 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: tappable,
            ),
          ),
        );
      },
    );
  }
}

class AppInfoBanner extends StatelessWidget {
  const AppInfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.action,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = app_theme.cardTheme(context);
    final tint = color ?? theme.colorScheme.primary;
    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 11, 11),
        decoration: BoxDecoration(
          color: tint.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tint.withAlpha(55)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: tint),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.55,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = '确定',
  String cancelText = '取消',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelText),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: app_theme.kDangerRed,
                    foregroundColor: Colors.white,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void showErrorSnack(BuildContext context, Object error) {
  final message = error is AppException ? error.message : '操作失败：$error';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showInfoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
