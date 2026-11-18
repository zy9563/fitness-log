import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Page masthead used by the four primary tabs. No AppBar, no template.
class LedgerPageHeader extends StatelessWidget {
  const LedgerPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 14),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 40),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kSteel,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class LedgerBackButton extends StatelessWidget {
  const LedgerBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '返回',
      child: InkWell(
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(
              '←',
              style: TextStyle(
                color: kChalk,
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square completion control. The only rounded-by-motion element is the
/// 1px corner; the orange fill is the state, not decoration.
class LedgerCheck extends StatelessWidget {
  const LedgerCheck({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      checked: value,
      button: true,
      label: value ? '已完成' : '未完成',
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? kSafetyOrange : Colors.transparent,
            border: Border.all(
              color: value ? kSafetyOrange : (enabled ? kSteel : kLine),
              width: 1.2,
            ),
          ),
          child: value
              ? const Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: kInk,
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// A thin square arrow used by the calendar, stats and other sequential views.
class LedgerArrow extends StatelessWidget {
  const LedgerArrow({
    super.key,
    required this.left,
    this.onTap,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onLongPressCancel,
    this.enabled = true,
  });

  final bool left;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final VoidCallback? onLongPressCancel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? kChalk : kSteel.withAlpha(90);
    final child = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: enabled ? kLine : kLineSoft),
        color: kInk,
      ),
      alignment: Alignment.center,
      child: Text(
        left ? '‹' : '›',
        style: TextStyle(
          color: color,
          fontSize: 24,
          height: 1,
          fontFamily: kDisplayFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (!enabled) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart == null
          ? null
          : (_) => onLongPressStart!(),
      onLongPressEnd: onLongPressEnd == null ? null : (_) => onLongPressEnd!(),
      onLongPressCancel: onLongPressCancel,
      child: child,
    );
  }
}

/// A square, carbon form dialog used across the redesign.
class LedgerDialog extends StatelessWidget {
  const LedgerDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.eyebrow,
    this.subtitle,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: kCarbon,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kSafetyOrange, width: 2)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: kSafetyOrange,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
              ],
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontSize: 23),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kSteel,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              child,
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 1px section rule with optional inset.
class LedgerRule extends StatelessWidget {
  const LedgerRule({super.key, this.inset = 0, this.color = kLine});

  final double inset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Container(height: 1, color: color),
    );
  }
}

class LedgerStatusLine extends StatelessWidget {
  const LedgerStatusLine({
    super.key,
    required this.active,
    this.width = 2,
    this.height = 22,
  });

  final bool active;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: active ? kSafetyOrange : kLine,
    );
  }
}
