import 'package:flutter/material.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/ledger.dart';
import 'workout_grouping.dart';

/// 训练记录里的一个日期 + 部位分组。
///
/// 日期只出现一次；日期下方是健身房和部位，动作逐行排列。
class WorkoutGroupCard extends StatelessWidget {
  const WorkoutGroupCard({
    super.key,
    required this.group,
    required this.store,
    required this.onTapEntry,
  });

  final WorkoutGroup group;
  final FitnessStore store;
  final ValueChanged<TrainingEntry> onTapEntry;

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymNames = <String>[];
    for (final entry in group.entries) {
      final name = store.gymById(entry.gymId)?.name.trim();
      if (name != null && name.isNotEmpty && !gymNames.contains(name)) {
        gymNames.add(name);
      }
    }
    final gymText = gymNames.isEmpty ? '未知健身房' : gymNames.join(' / ');
    final partText = group.bodyPart.isEmpty ? '未填写部位' : group.bodyPart;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLineSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_two(group.date.month)}.${_two(group.date.day)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 28,
                  height: 0.92,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  weekdayZh(group.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${group.entries.length} 个动作',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '$gymText · $partText',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kSteel,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          const LedgerRule(),
          for (final entry in group.entries)
            _WorkoutActionRow(
              entry: entry,
              sets: store.setsForEntry(entry.id),
              onTap: () => onTapEntry(entry),
            ),
        ],
      ),
    );
  }
}

class _WorkoutActionRow extends StatelessWidget {
  const _WorkoutActionRow({
    required this.entry,
    required this.sets,
    required this.onTap,
  });

  final TrainingEntry entry;
  final List<TrainingSet> sets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = sets
        .map(
          (set) =>
              '${set.groupCount}×${set.reps} '
              '${formatWeightValue(set.weightValue, WeightUnit.fromIndex(set.weightUnitIndex), raw: set.weightRaw)}',
        )
        .join('   ');
    final note = entry.note.trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.exerciseName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      color: kChalk,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: kSteel,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: kChalk.withAlpha(180),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 20,
                  color: kSteel,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
