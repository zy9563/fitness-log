import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';
import '../training/day_training_page.dart';
import 'exercise_progress_page.dart';
import 'workout_group_card.dart';
import 'workout_grouping.dart';

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
      helpText: '筛选训练日期',
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

  Future<void> _pickGym(FitnessStore store) async {
    final picked = await _showChoiceSheet<int>(
      title: '筛选健身房',
      subtitle: '只看某一家场馆的记录',
      options: [(0, '全部健身房'), for (final gym in store.gyms) (gym.id, gym.name)],
      selected: _gymId ?? 0,
    );
    if (picked == null || !mounted) return;
    setState(() => _gymId = picked == 0 ? null : picked);
  }

  Future<void> _pickBodyPart(List<String> bodyParts) async {
    final picked = await _showChoiceSheet<String>(
      title: '筛选部位',
      subtitle: '今天练的是哪一块',
      options: [('', '全部部位'), for (final part in bodyParts) (part, part)],
      selected: _bodyPart ?? '',
    );
    if (picked == null || !mounted) return;
    setState(() => _bodyPart = picked.isEmpty ? null : picked);
  }

  Future<T?> _showChoiceSheet<T>({
    required String title,
    required String subtitle,
    required List<(T, String)> options,
    required T selected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: kCarbon,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.bodySmall?.copyWith(color: kSteel),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
                const LedgerRule(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final active = option.$1 == selected;
                      return InkWell(
                        onTap: () => Navigator.pop(sheetContext, option.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: kLineSoft),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.$2,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: active ? kSafetyOrange : kChalk,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (active)
                                const Text(
                                  '已选',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kSafetyOrange,
                                    letterSpacing: 1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _range = null;
      _gymId = null;
      _bodyPart = null;
      _exerciseController.clear();
    });
  }

  List<TrainingEntry> _filtered(FitnessStore store) {
    final query = normalizeLookupName(_exerciseController.text);
    final result = <TrainingEntry>[];
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
      result.add(entry);
    }
    result.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final entries = _filtered(store);
    final groups = groupWorkoutEntries(entries);
    final bodyParts = store.bodyPartSuggestions();
    final hasFilters =
        _range != null ||
        _gymId != null ||
        _bodyPart != null ||
        _exerciseController.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
          children: [
            LedgerPageHeader(
              title: '记录',
              subtitle: '训练历史 · 共 ${entries.length} 个动作',
              trailing: TextButton(
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
                child: const Text('动作变化 →'),
              ),
            ),
            const SizedBox(height: 18),
            _FilterPanel(
              range: _range,
              gymName: _gymId == null
                  ? '全部'
                  : store.gymById(_gymId!)?.name ?? '全部',
              bodyPart: _bodyPart ?? '全部',
              controller: _exerciseController,
              hasFilters: hasFilters,
              onPickRange: _pickRange,
              onClearRange: () => setState(() => _range = null),
              onPickGym: () => _pickGym(store),
              onPickBodyPart: () => _pickBodyPart(bodyParts),
              onClear: _clearFilters,
              onQueryChanged: () => setState(() {}),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(width: 3, height: 18, color: kSafetyOrange),
                const SizedBox(width: 9),
                Text(
                  '训练记录',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: kChalk,
                  ),
                ),
                const Spacer(),
                Text(
                  '${groups.length} 次',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const LedgerRule(),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: EmptyState(
                  title: '没有找到记录',
                  message: hasFilters
                      ? '可以调整日期、健身房、部位或动作关键词。'
                      : '去日历点一个日期，记录第一次训练吧。',
                  action: hasFilters
                      ? TextButton(
                          onPressed: _clearFilters,
                          child: const Text('清除筛选'),
                        )
                      : null,
                ),
              )
            else
              for (final group in groups)
                WorkoutGroupCard(
                  group: group,
                  store: store,
                  onTapEntry: (entry) {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DayTrainingPage(
                          date: entry.date,
                          initialGymId: entry.gymId,
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.range,
    required this.gymName,
    required this.bodyPart,
    required this.controller,
    required this.hasFilters,
    required this.onPickRange,
    required this.onClearRange,
    required this.onPickGym,
    required this.onPickBodyPart,
    required this.onClear,
    required this.onQueryChanged,
  });

  final DateTimeRange? range;
  final String gymName;
  final String bodyPart;
  final TextEditingController controller;
  final bool hasFilters;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;
  final VoidCallback onPickGym;
  final VoidCallback onPickBodyPart;
  final VoidCallback onClear;
  final VoidCallback onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(
          top: BorderSide(color: kSafetyOrange, width: 1.5),
          bottom: BorderSide(color: kLine),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          _FilterRow(
            label: '日期',
            value: range == null
                ? '全部'
                : '${formatDate(range!.start)} — ${formatDate(range!.end)}',
            active: range != null,
            onTap: onPickRange,
            onClear: range == null ? null : onClearRange,
          ),
          _FilterRow(
            label: '健身房',
            value: gymName,
            active: gymName != '全部',
            onTap: onPickGym,
          ),
          _FilterRow(
            label: '部位',
            value: bodyPart,
            active: bodyPart != '全部',
            onTap: onPickBodyPart,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: (_) => onQueryChanged(),
            style: const TextStyle(color: kChalk, fontSize: 14),
            decoration: InputDecoration(
              hintText: '动作关键词，例如：卧推',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              filled: true,
              fillColor: kGraphite,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kLine),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kLine),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kSafetyOrange, width: 1.5),
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : InkWell(
                      onTap: () {
                        controller.clear();
                        onQueryChanged();
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '清空',
                          style: TextStyle(fontSize: 11, color: kSteel),
                        ),
                      ),
                    ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 36,
              ),
            ),
          ),
          if (hasFilters)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClear,
                child: const Text(
                  '清除全部筛选',
                  style: TextStyle(fontSize: 12, color: kSteel),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: kSteel,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? kSafetyOrange : kChalk,
                ),
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text('×', style: TextStyle(color: kSteel)),
                ),
              ),
            const Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: kSteel,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
