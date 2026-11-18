import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/edge_fade_list_view.dart';
import '../training/day_training_page.dart';
import 'exercise_progress_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _exerciseController = TextEditingController();
  DateTimeRange? _range;
  int? _gymId;
  String? _bodyPart;

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _range,
      currentDate: DateTime.now(),
      helpText: '选择日期区间',
      saveText: '确定',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _range = DateTimeRange(
        start: dateOnly(picked.start),
        end: dateOnly(picked.end),
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _range = null;
      _gymId = null;
      _bodyPart = null;
      _exerciseController.clear();
    });
  }

  List<_HistoryRow> _filtered(FitnessStore store) {
    final query = normalizeLookupName(_exerciseController.text);
    final result = <_HistoryRow>[];
    for (final entry in store.entries) {
      final gym = store.gymById(entry.gymId);
      if (gym == null) continue;
      if (_gymId != null && entry.gymId != _gymId) continue;
      if (_bodyPart != null && entry.bodyPart.trim() != _bodyPart) continue;
      if (_range != null) {
        final day = dateOnly(entry.date);
        if (day.isBefore(_range!.start) || day.isAfter(_range!.end)) continue;
      }
      if (query.isNotEmpty &&
          !normalizeLookupName(entry.exerciseName).contains(query)) {
        continue;
      }
      result.add(
        _HistoryRow(entry: entry, gym: gym, sets: store.setsForEntry(entry.id)),
      );
    }
    result.sort((a, b) {
      final dateCompare = b.entry.date.compareTo(a.entry.date);
      if (dateCompare != 0) return dateCompare;
      return a.entry.sortOrder.compareTo(b.entry.sortOrder);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final rows = _filtered(store);
    final bodyParts = store.bodyPartSuggestions();
    final hasFilters =
        _range != null ||
        _gymId != null ||
        _bodyPart != null ||
        _exerciseController.text.trim().isNotEmpty;

    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('记录'),
        actions: [
          IconButton(
            tooltip: '动作变化',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ExerciseProgressPage(
                    initialGymId: _gymId,
                    initialExercise: _exerciseController.text.trim(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.trending_up),
          ),
        ],
      ),
      body: EdgeFadeListView(
        padding: EdgeInsets.fromLTRB(16, topInset, 16, 120),
        topFadeHeight: topInset + 16,
        bottomFadeHeight: 130,
        children: [
          AppSectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickRange,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          _range == null
                              ? '全部日期'
                              : '${formatDate(_range!.start)} ~ ${formatDate(_range!.end)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (_range != null)
                      IconButton(
                        tooltip: '清除日期',
                        onPressed: () => setState(() => _range = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: ValueKey<int>(_gymId ?? 0),
                  initialValue: _gymId ?? 0,
                  decoration: const InputDecoration(labelText: '健身房'),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('全部健身房')),
                    for (final gym in store.gyms)
                      DropdownMenuItem(
                        value: gym.id,
                        child: Text(gym.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _gymId = value == 0 ? null : value);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(_bodyPart ?? ''),
                  initialValue: _bodyPart ?? '',
                  decoration: const InputDecoration(labelText: '部位'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('全部部位')),
                    for (final part in bodyParts)
                      DropdownMenuItem(value: part, child: Text(part)),
                  ],
                  onChanged: (value) {
                    setState(
                      () => _bodyPart = (value == null || value.isEmpty)
                          ? null
                          : value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _exerciseController,
                  decoration: InputDecoration(
                    labelText: '动作名称',
                    hintText: '输入关键词，例如：卧推',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _exerciseController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _exerciseController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (hasFilters) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off, size: 17),
                      label: const Text('清除筛选'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SectionTitle('训练记录', subtitle: '共 ${rows.length} 个动作'),
          if (rows.isEmpty)
            AppSectionCard(
              child: EmptyState(
                icon: Icons.history,
                title: '没有找到记录',
                message: hasFilters
                    ? '可以调整日期、健身房、部位或动作关键词。'
                    : '去日历点一个日期，记录第一次训练吧。',
                action: hasFilters
                    ? OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('清除筛选'),
                      )
                    : null,
              ),
            )
          else
            for (final row in rows)
              _HistoryCard(
                row: row,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DayTrainingPage(
                        date: row.entry.date,
                        initialGymId: row.entry.gymId,
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}

class _HistoryRow {
  const _HistoryRow({
    required this.entry,
    required this.gym,
    required this.sets,
  });

  final TrainingEntry entry;
  final Gym gym;
  final List<TrainingSet> sets;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.row, required this.onTap});

  final _HistoryRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setList = row.sets;
    final totalGroups = setList.fold<int>(
      0,
      (sum, set) => sum + set.groupCount,
    );
    return AppSectionCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.entry.exerciseName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${formatDate(row.entry.date)} ${weekdayZh(row.entry.date)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '${row.gym.name} · ${row.entry.bodyPart} · $totalGroups 组',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (setList.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final set in setList)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${set.groupCount} 组 × '
                    '${formatWeightValue(set.weightValue, WeightUnit.fromIndex(set.weightUnitIndex), raw: set.weightRaw)} × ${set.reps} 次'
                    '${set.note.trim().isEmpty ? '' : ' · ${set.note}'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
            ],
            if (row.entry.note.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                row.entry.note.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
