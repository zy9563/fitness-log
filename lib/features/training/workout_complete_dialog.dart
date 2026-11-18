import 'package:flutter/material.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';
import '../../widgets/ledger.dart';

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
    barrierColor: kInk.withAlpha(225),
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
    final theme = Theme.of(context);
    return LedgerDialog(
      eyebrow: 'SESSION CLOSED',
      title: '训练完成',
      subtitle: '今天的记录已经写进本机',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, WorkoutCompleteAction.stay),
          child: const Text('留在本页'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, WorkoutCompleteAction.backToCalendar),
          child: const Text('回到日历'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          _CompleteMetric(
            label: '本次容量',
            value: formatWorkoutVolume(volumes),
            accent: true,
          ),
          _CompleteMetric(label: '完成组数', value: '$totalGroups', unit: '组'),
          const SizedBox(height: 18),
          const LedgerRule(),
          const SizedBox(height: 14),
          Text(
            '每一次完成，都算数。',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kSteel,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteMetric extends StatelessWidget {
  const _CompleteMetric({
    required this.label,
    required this.value,
    this.unit,
    this.accent = false,
  });

  final String label;
  final String value;
  final String? unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLineSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: kSteel,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                color: accent ? kSafetyOrange : kChalk,
                height: 1.1,
              ),
            ),
          ),
          if (unit != null) ...[
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                unit!,
                style: const TextStyle(fontSize: 11, color: kSteel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
