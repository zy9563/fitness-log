import 'package:flutter/material.dart';

import '../core/app_exception.dart';
import '../core/theme.dart' as app_theme;

/// Empty state without a hero icon. A single steel rule marks the absence.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData? icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 34, height: 1, color: app_theme.kSteel),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.left,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 21),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: app_theme.kSteel,
                  height: 1.65,
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

/// A full-bleed ledger section separated by 1px hairlines.
///
/// The old card API is kept so secondary screens migrate without churn. The
/// visual treatment is intentionally nothing like the v1 rounded card: no
/// radius, no shadow, no edge fade; one orange cap for a primary section.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(0, 18, 0, 18),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.elevated = false,
    this.edgeFadeRange = 0,
    this.minCardOpacity = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool elevated;

  // Retained for source compatibility with v1 call sites; ignored by design.
  final double edgeFadeRange;
  final double minCardOpacity;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Theme(data: app_theme.cardTheme(context), child: child),
    );

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: app_theme.kCarbon,
          border: Border(
            top: BorderSide(
              color: elevated ? app_theme.kSafetyOrange : app_theme.kLine,
              width: elevated ? 1.5 : 1,
            ),
            bottom: const BorderSide(color: app_theme.kLine),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  overlayColor: const WidgetStatePropertyAll(Color(0x14FF4E12)),
                  child: content,
                ),
        ),
      ),
    );
  }
}

/// Informational strip: a 2px rail, not a tinted rounded card.
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
    final theme = Theme.of(context);
    final tint = color ?? app_theme.kSafetyOrange;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: app_theme.kInk,
        border: Border(
          left: BorderSide(color: tint, width: 2),
          top: const BorderSide(color: app_theme.kLineSoft),
          bottom: const BorderSide(color: app_theme.kLineSoft),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.65,
                color: app_theme.kSteel,
              ),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
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
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: 3, height: 17, color: app_theme.kSafetyOrange),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontSize: 21),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: app_theme.kSteel,
                      height: 1.45,
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
    barrierColor: const Color(0xC0000000),
    builder: (dialogContext) {
      return _LedgerDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        destructive: destructive,
      );
    },
  );
  return result ?? false;
}

class _LedgerDialog extends StatelessWidget {
  const _LedgerDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.destructive,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        decoration: const BoxDecoration(
          color: app_theme.kCarbon,
          border: Border(
            top: BorderSide(color: app_theme.kSafetyOrange, width: 2),
            left: BorderSide(color: app_theme.kLine),
            right: BorderSide(color: app_theme.kLine),
            bottom: BorderSide(color: app_theme.kLine),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 23),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: app_theme.kSteel,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: destructive
                      ? FilledButton.styleFrom(
                          backgroundColor: app_theme.kDangerRed,
                          foregroundColor: app_theme.kInk,
                        )
                      : null,
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
