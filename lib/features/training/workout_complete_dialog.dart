import 'package:flutter/material.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';

enum WorkoutCompleteAction { stay, backToCalendar }

/// 本次训练总结：容量按单位分开累计，不做跨单位换算。
String formatWorkoutVolume(Map<WeightUnit, double> volumes) {
  final parts = <String>[];
  for (final unit in WeightUnit.values) {
    final value = volumes[unit] ?? 0;
    if (value <= 0) continue;
    parts.add('${formatWeight(value)} ${unit.label}');
  }
  return parts.isEmpty ? '—' : parts.join(' / ');
}

Future<WorkoutCompleteAction?> showWorkoutCompleteDialog({
  required BuildContext context,
  required Map<WeightUnit, double> volumes,
  required int totalGroups,
}) {
  return showDialog<WorkoutCompleteAction>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(92),
    builder: (_) =>
        WorkoutCompleteDialog(volumes: volumes, totalGroups: totalGroups),
  );
}

class WorkoutCompleteDialog extends StatelessWidget {
  const WorkoutCompleteDialog({
    super.key,
    required this.volumes,
    required this.totalGroups,
  });

  final Map<WeightUnit, double> volumes;
  final int totalGroups;

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF1E2329);
    const valueColor = Color(0xFF2F3540);
    const labelColor = Color(0xFF8A919B);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: '训练完成庆祝',
                  child: const ExcludeSemantics(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: 64, height: 1.1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '训练完成',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SummaryMetric(
                        label: '本次容量',
                        value: formatWorkoutVolume(volumes),
                        valueColor: valueColor,
                        labelColor: labelColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryMetric(
                        label: '组数',
                        value: '$totalGroups',
                        valueColor: valueColor,
                        labelColor: labelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '每一次完成，都算数。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, WorkoutCompleteAction.stay),
                      style: TextButton.styleFrom(
                        foregroundColor: labelColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('留在本页'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        WorkoutCompleteAction.backToCalendar,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('回到日历'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
