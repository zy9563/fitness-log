import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../widgets/ledger.dart';
import 'workout_group_card.dart';
import 'workout_grouping.dart';

/// 同部位往期训练，按日期由近及远。
///
/// 从训练日的“本地记录”进入，不包含今天。
class BodyPartHistoryPage extends StatelessWidget {
  const BodyPartHistoryPage({
    super.key,
    required this.bodyPart,
    required this.onOpenEntry,
  });

  final String bodyPart;
  final ValueChanged<TrainingEntry> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final today = dateOnly(DateTime.now());
    final entries = store.entries
        .where(
          (entry) =>
              entry.bodyPart.trim() == bodyPart &&
              dateOnly(entry.date).isBefore(today),
        )
        .toList();
    final groups = groupWorkoutEntries(entries);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                LedgerBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 10),
                Text(
                  'BODY PART / 往期',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LedgerPageHeader(
              title: bodyPart.isEmpty ? '未填写部位' : bodyPart,
              subtitle: '往期训练 · 按日期由近及远',
              trailing: Text(
                '${groups.length} 次',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: kSteel,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const LedgerRule(),
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 36),
                child: Text(
                  '这个部位还没有往期记录。',
                  style: TextStyle(color: kSteel, height: 1.6),
                ),
              )
            else
              for (final group in groups)
                WorkoutGroupCard(
                  group: group,
                  store: store,
                  onTapEntry: onOpenEntry,
                ),
          ],
        ),
      ),
    );
  }
}
