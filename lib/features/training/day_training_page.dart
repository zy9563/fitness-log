import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/exercise_group.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';
import '../gyms/gym_dialogs.dart';
import 'exercise_form_dialog.dart';
import 'set_form_dialog.dart';
import 'widgets/body_part_field.dart';
import 'widgets/exercise_preset_picker.dart';
import 'workout_complete_dialog.dart';

class DayTrainingPage extends StatefulWidget {
  const DayTrainingPage({super.key, required this.date, this.initialGymId});

  final DateTime date;
  final int? initialGymId;

  @override
  State<DayTrainingPage> createState() => _DayTrainingPageState();
}

class _DayTrainingPageState extends State<DayTrainingPage> {
  int? _gymId;
  late final TextEditingController _bodyPartController;
  bool _sessionEnded = false;

  @override
  void initState() {
    super.initState();
    final store = context.read<FitnessStore>();
    _gymId =
        widget.initialGymId ??
        store.latestGymIdForDate(widget.date) ??
        (store.gyms.length == 1 ? store.gyms.first.id : null);
    _bodyPartController = TextEditingController();
    _syncBodyPart();
    _bodyPartController.addListener(_onBodyPartChanged);
  }

  @override
  void dispose() {
    _bodyPartController
      ..removeListener(_onBodyPartChanged)
      ..dispose();
    super.dispose();
  }

  void _onBodyPartChanged() {
    if (mounted) setState(() {});
  }

  void _syncBodyPart() {
    final gymId = _gymId;
    if (gymId == null) {
      _bodyPartController.text = '';
      return;
    }
    final entries = context.read<FitnessStore>().entriesForDateGym(
      widget.date,
      gymId,
    );
    var existing = '';
    for (final entry in entries) {
      if (entry.bodyPart.trim().isNotEmpty) {
        existing = entry.bodyPart.trim();
        break;
      }
    }
    _bodyPartController.text = existing;
  }

  Future<void> _saveBodyPartIfNeeded() async {
    final gymId = _gymId;
    final bodyPart = _bodyPartController.text.trim();
    if (gymId == null || bodyPart.isEmpty) return;
    final store = context.read<FitnessStore>();
    final entries = store.entriesForDateGym(widget.date, gymId);
    if (entries.isNotEmpty &&
        entries.any((entry) => entry.bodyPart.trim() != bodyPart)) {
      await store.updateBodyPartForDateGym(widget.date, gymId, bodyPart);
    }
  }

  Future<Gym?> _pickGym() async {
    final store = context.read<FitnessStore>();
    final selected = await showModalBottomSheet<Gym>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCarbon,
      barrierColor: kInk.withAlpha(210),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 560),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kSafetyOrange, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '选择健身房',
                          style: Theme.of(
                            sheetContext,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('×'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    '这次训练记录会归到所选健身房。',
                    style: Theme.of(
                      sheetContext,
                    ).textTheme.labelSmall?.copyWith(color: kSteel),
                  ),
                ),
                const LedgerRule(),
                InkWell(
                  onTap: () async {
                    final gym = await _createGym(sheetContext);
                    if (gym != null && sheetContext.mounted) {
                      Navigator.pop(sheetContext, gym);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: kLineSoft)),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          '+',
                          style: TextStyle(
                            fontSize: 18,
                            color: kSafetyOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '新建健身房',
                          style: TextStyle(fontSize: 14, color: kChalk),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final gym in store.gyms)
                        InkWell(
                          onTap: () => Navigator.pop(sheetContext, gym),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: kLineSoft),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gym.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: kChalk,
                                        ),
                                      ),
                                      if (gym.note.trim().isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          gym.note.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: kSteel,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Text(
                                  '›',
                                  style: TextStyle(fontSize: 20, color: kSteel),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return selected;
  }

  Future<Gym?> _createGym(BuildContext context) async {
    final result = await showDialog<GymFormResult>(
      context: context,
      builder: (_) => const GymFormDialog(),
    );
    if (result == null || !context.mounted) return null;
    try {
      return await context.read<FitnessStore>().createGym(
        name: result.name,
        note: result.note,
      );
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
      return null;
    }
  }

  Future<void> _selectGym() async {
    final gym = await _pickGym();
    if (gym != null && mounted) {
      setState(() => _gymId = gym.id);
      _syncBodyPart();
    }
  }

  Future<void> _addExercise() async {
    final gymId = _gymId;
    if (gymId == null) {
      await _selectGym();
      return;
    }
    final bodyPart = _bodyPartController.text.trim();
    if (bodyPart.isEmpty) {
      showInfoSnack(context, '请先填写本次训练部位');
      return;
    }
    await _saveBodyPartIfNeeded();
    if (!mounted) return;
    final store = context.read<FitnessStore>();
    final existingNames = store
        .entriesForDateGym(widget.date, gymId)
        .map((entry) => normalizeLookupName(entry.exerciseName))
        .toSet();
    final selection = await showExercisePresetPicker(
      context: context,
      groupedPresets: store.groupedPresetsForGym(gymId),
      existingNames: existingNames,
      bodyPart: bodyPart,
    );
    if (selection == null || !mounted) return;

    if (selection.createNew) {
      final result = await showDialog<ExerciseFormResult>(
        context: context,
        builder: (_) => ExerciseFormDialog(
          isNewAction: true,
          initialRestText: '90秒',
          initialPresetGroup: groupFromBodyPart(bodyPart) ?? '',
        ),
      );
      if (result == null || !mounted) return;
      await _createEntryFromForm(
        store: store,
        gymId: gymId,
        bodyPart: bodyPart,
        result: result,
        editFirstSet: true,
      );
      return;
    }

    if (selection.presets.length == 1) {
      final preset = selection.presets.first;
      final result = await showDialog<ExerciseFormResult>(
        context: context,
        builder: (_) =>
            ExerciseFormDialog(selectedPreset: preset, initialRestText: '90秒'),
      );
      if (result == null || !mounted) return;
      await _createEntryFromForm(
        store: store,
        gymId: gymId,
        bodyPart: bodyPart,
        result: result,
        editFirstSet: true,
      );
      return;
    }

    await _batchAddPresets(
      store: store,
      gymId: gymId,
      bodyPart: bodyPart,
      presets: selection.presets,
    );
  }

  Future<void> _createEntryFromForm({
    required FitnessStore store,
    required int gymId,
    required String bodyPart,
    required ExerciseFormResult result,
    required bool editFirstSet,
  }) async {
    try {
      final entry = await store.createEntry(
        gymId: gymId,
        date: widget.date,
        bodyPart: bodyPart,
        exerciseName: result.exerciseName,
        restText: result.restText,
        note: result.note,
        addToPreset: result.addToPreset,
        presetGroup: result.presetGroup,
        presetNote: result.presetNote,
      );
      final unit =
          store.lastWeightUnitIndexForExercise(entry.exerciseName) ??
          WeightUnit.kg.index;
      final firstSet = await store.addSet(
        entry: entry,
        groupCount: 1,
        weightUnitIndex: unit,
        reps: 8,
      );
      if (mounted && _sessionEnded) {
        setState(() => _sessionEnded = false);
      }
      if (editFirstSet && mounted) {
        await _editOrAddSet(entry: entry, existing: firstSet);
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _batchAddPresets({
    required FitnessStore store,
    required int gymId,
    required String bodyPart,
    required List<ExercisePreset> presets,
  }) async {
    var added = 0;
    final failures = <String>[];
    for (final preset in presets) {
      try {
        final entry = await store.createEntry(
          gymId: gymId,
          date: widget.date,
          bodyPart: bodyPart,
          exerciseName: preset.name,
          restText: '90秒',
          addToPreset: false,
        );
        final unit =
            store.lastWeightUnitIndexForExercise(entry.exerciseName) ??
            WeightUnit.kg.index;
        await store.addSet(
          entry: entry,
          groupCount: 1,
          weightUnitIndex: unit,
          reps: 8,
        );
        added++;
      } catch (error) {
        failures.add('${preset.name}：$error');
      }
    }
    if (!mounted) return;
    if (added > 0) {
      if (_sessionEnded) {
        setState(() => _sessionEnded = false);
      }
      final suffix = failures.isEmpty
          ? ''
          : '，${failures.length} 个未添加（${failures.first}）';
      showInfoSnack(context, '已添加 $added 个动作，默认 1 组 × 8 次，可在动作卡片中修改$suffix');
    } else {
      showErrorSnack(context, failures.isEmpty ? '添加动作失败' : failures.join('；'));
    }
  }

  Future<void> _editEntry(TrainingEntry entry) async {
    final store = context.read<FitnessStore>();
    final result = await showDialog<ExerciseFormResult>(
      context: context,
      builder: (_) => ExerciseFormDialog(
        initialExerciseName: entry.exerciseName,
        initialRestText: entry.restText,
        initialNote: entry.note,
      ),
    );
    if (result == null || !mounted) return;
    try {
      await store.updateEntry(
        entry,
        bodyPart: entry.bodyPart,
        exerciseName: result.exerciseName,
        restText: result.restText,
        note: result.note,
      );
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _editOrAddSet({
    required TrainingEntry entry,
    TrainingSet? existing,
  }) async {
    final store = context.read<FitnessStore>();
    final entrySets = store.setsForEntry(entry.id);
    final fallbackUnit = entrySets.isEmpty
        ? store.lastWeightUnitIndexForExercise(entry.exerciseName)
        : entrySets.last.weightUnitIndex;
    final result = await showDialog<SetFormResult>(
      context: context,
      builder: (_) =>
          SetFormDialog(existing: existing, defaultUnitIndex: fallbackUnit),
    );
    if (result == null || !mounted) return;
    try {
      if (existing == null) {
        await store.addSet(
          entry: entry,
          groupCount: result.groupCount,
          weightValue: result.weightValue,
          weightUnitIndex: result.weightUnitIndex,
          reps: result.reps,
          note: result.note,
          weightRaw: result.weightRaw,
        );
      } else {
        await store.updateSet(
          existing,
          groupCount: result.groupCount,
          weightValue: result.weightValue,
          weightUnitIndex: result.weightUnitIndex,
          reps: result.reps,
          note: result.note,
          weightRaw: result.weightRaw,
        );
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _deleteEntry(TrainingEntry entry) async {
    final confirmed = await confirmAction(
      context,
      title: '删除动作？',
      message: '将删除“${entry.exerciseName}”及其全部组记录。',
      confirmText: '删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<FitnessStore>().deleteEntry(entry.id);
      if (mounted) showInfoSnack(context, '动作已删除');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _deleteSet(TrainingSet set) async {
    final confirmed = await confirmAction(
      context,
      title: '删除这一行组？',
      message: '删除后，后面的组别序号会自动重排。',
      confirmText: '删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<FitnessStore>().deleteSet(set);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Map<WeightUnit, double> _volumesForEntries(
    FitnessStore store,
    List<TrainingEntry> entries,
  ) {
    final volumes = <WeightUnit, double>{};
    for (final entry in entries) {
      for (final set in store.setsForEntry(entry.id)) {
        final unit = WeightUnit.fromIndex(set.weightUnitIndex);
        final value = set.weightValue;
        if (unit == null || value == null) continue;
        volumes[unit] =
            (volumes[unit] ?? 0) + value * set.groupCount * set.reps;
      }
    }
    return volumes;
  }

  Future<void> _showCompletion({
    required FitnessStore store,
    required List<TrainingEntry> entries,
    required int totalGroups,
  }) async {
    final action = await showWorkoutCompleteDialog(
      context: context,
      volumes: _volumesForEntries(store, entries),
      totalGroups: totalGroups,
    );
    if (!mounted) return;
    if (action == WorkoutCompleteAction.backToCalendar) {
      Navigator.pop(context);
    }
  }

  Future<void> _endToday({
    required FitnessStore store,
    required List<TrainingEntry> entries,
    required int totalGroups,
  }) async {
    final confirmed = await confirmAction(
      context,
      title: '结束今日任务？',
      message: '所有动作都已经勾选完成。\n\n现在结束今天的训练吗？',
      confirmText: '结束训练',
      cancelText: '继续训练',
    );
    if (!confirmed || !mounted) return;
    setState(() => _sessionEnded = true);
    await _showCompletion(
      store: store,
      entries: entries,
      totalGroups: totalGroups,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final gym = store.gymById(_gymId);
    final entries = gym == null
        ? const <TrainingEntry>[]
        : store.entriesForDateGym(widget.date, gym.id);
    final bodyPartEmpty = _bodyPartController.text.trim().isEmpty;
    final totalGroups = entries.fold<int>(
      0,
      (sum, entry) => sum + store.totalGroupCountForEntry(entry.id),
    );
    final totalReps = entries.fold<int>(
      0,
      (sum, entry) => sum + store.totalRepsForEntry(entry.id),
    );
    final allCompleted =
        entries.isNotEmpty && entries.every((entry) => entry.completed);
    final dateLabel =
        '${widget.date.month.toString().padLeft(2, '0')}.'
        '${widget.date.day.toString().padLeft(2, '0')}';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kInk,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                children: [
                  LedgerBackButton(onTap: () => Navigator.maybePop(context)),
                  const SizedBox(width: 8),
                  Text(
                    '训练日',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kSteel,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    gym == null ? '待选健身房' : '本地记录',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: gym == null ? kSteel : kSafetyOrange,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateLabel,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 48,
                          height: 0.92,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(
                          '${weekdayZh(widget.date)} · ${widget.date.year}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kSteel,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionEyebrow(index: '01', label: '训练部位'),
                  const SizedBox(height: 8),
                  BodyPartField(
                    controller: _bodyPartController,
                    suggestions: store.bodyPartSuggestions(),
                  ),
                  const SizedBox(height: 24),
                  const _SectionEyebrow(index: '02', label: '健身房'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gym?.name ?? '还没有选择健身房',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            color: gym == null ? kSteel : kChalk,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _selectGym,
                        child: Text(gym == null ? '选择' : '切换'),
                      ),
                    ],
                  ),
                  if (gym != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Metric(value: '${entries.length}', label: '动作'),
                        _Metric(value: '$totalGroups', label: '组数'),
                        _Metric(value: '$totalReps', label: '次数'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  const _SectionEyebrow(index: '03', label: '动作与组'),
                  if (gym == null)
                    _LedgerEmpty(
                      title: store.gyms.isEmpty ? '先新建一家健身房。' : '先选择健身房。',
                      message: store.gyms.isEmpty
                          ? '健身房是训练记录的归属；建好之后，动作预设也归它。'
                          : '选择健身房后，才能添加动作和组记录。',
                      actionLabel: store.gyms.isEmpty ? '新建健身房' : '选择健身房',
                      onAction: store.gyms.isEmpty
                          ? () async {
                              final created = await _createGym(context);
                              if (created != null && mounted) {
                                setState(() => _gymId = created.id);
                              }
                            }
                          : _selectGym,
                    )
                  else if (entries.isEmpty)
                    _LedgerEmpty(
                      title: bodyPartEmpty ? '先填写本次训练部位。' : '今天还没有动作记录。',
                      message: bodyPartEmpty
                          ? '部位只填一次，今天所有动作共用；可以写“胸，三头”。'
                          : '从动作预设里选，或临时新建一个动作。',
                      actionLabel: bodyPartEmpty ? null : '添加动作',
                      onAction: bodyPartEmpty ? null : _addExercise,
                    )
                  else ...[
                    const SizedBox(height: 4),
                    for (final entry in entries)
                      _EntryLedger(
                        entry: entry,
                        sets: store.setsForEntry(entry.id),
                        onToggle: (value) async {
                          try {
                            await store.toggleEntryCompleted(entry, value);
                            if (!value && mounted && _sessionEnded) {
                              setState(() => _sessionEnded = false);
                            }
                          } catch (error) {
                            if (context.mounted) showErrorSnack(context, error);
                          }
                        },
                        onEdit: () => _editEntry(entry),
                        onDelete: () => _deleteEntry(entry),
                        onAddSet: () => _editOrAddSet(entry: entry),
                        onEditSet: (set) =>
                            _editOrAddSet(entry: entry, existing: set),
                        onDeleteSet: _deleteSet,
                      ),
                    if (!bodyPartEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(148, 46),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onPressed: _addExercise,
                            child: const Text('+ 继续添加动作'),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const LedgerStatusLine(active: false, height: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '修改会即时保存到本机。换机前请先导出 Excel 备份。',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kSteel,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _CommandBar(
              gymSelected: gym != null,
              bodyPartEmpty: bodyPartEmpty,
              hasEntries: entries.isNotEmpty,
              allCompleted: allCompleted,
              sessionEnded: _sessionEnded,
              onSelectGym: _selectGym,
              onAddExercise: _addExercise,
              onPrimary: () {
                if (_sessionEnded) {
                  _showCompletion(
                    store: store,
                    entries: entries,
                    totalGroups: totalGroups,
                  );
                } else {
                  _endToday(
                    store: store,
                    entries: entries,
                    totalGroups: totalGroups,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.index, required this.label});

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          index,
          style: theme.textTheme.labelSmall?.copyWith(
            color: kSafetyOrange,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: kSteel,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: LedgerRule(color: kLineSoft)),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 27,
              height: 1,
              color: kChalk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: kSteel, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _LedgerEmpty extends StatelessWidget {
  const _LedgerEmpty({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kLine),
          bottom: BorderSide(color: kLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              color: kChalk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kSteel,
              height: 1.6,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EntryLedger extends StatelessWidget {
  const _EntryLedger({
    required this.entry,
    required this.sets,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSet,
    required this.onEditSet,
    required this.onDeleteSet,
  });

  final TrainingEntry entry;
  final List<TrainingSet> sets;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSet;
  final ValueChanged<TrainingSet> onEditSet;
  final ValueChanged<TrainingSet> onDeleteSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLine)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: entry.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: entry.completed ? kSteel : kChalk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        entry.bodyPart,
                        if (entry.restText.trim().isNotEmpty)
                          '休息 ${entry.restText.trim()}',
                      ].join('  ·  '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: kSteel,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '更多',
                padding: EdgeInsets.zero,
                color: kGraphite,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('编辑动作')),
                  PopupMenuItem(value: 'delete', child: Text('删除动作')),
                ],
                child: const SizedBox(
                  width: 38,
                  height: 48,
                  child: Center(
                    child: Text(
                      '···',
                      style: TextStyle(
                        color: kSteel,
                        fontSize: 18,
                        height: 1,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              LedgerCheck(
                value: entry.completed,
                onChanged: onToggle,
                size: 32,
                hitSize: 52,
              ),
            ],
          ),
          if (entry.note.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                entry.note.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kSteel,
                  height: 1.45,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (sets.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '还没有组记录。',
                style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
              ),
            )
          else ...[
            const _SetHeader(),
            for (final set in sets)
              _SetLedgerRow(
                set: set,
                onEdit: () => onEditSet(set),
                onDelete: () => onDeleteSet(set),
              ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(112, 46),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: onAddSet,
              child: const Text('+ 添加一组'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetHeader extends StatelessWidget {
  const _SetHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: kSteel, letterSpacing: 1);
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLineSoft)),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('组', style: style)),
          Expanded(child: Text('重量', style: style)),
          SizedBox(
            width: 48,
            child: Text('次数', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _SetLedgerRow extends StatelessWidget {
  const _SetLedgerRow({
    required this.set,
    required this.onEdit,
    required this.onDelete,
  });

  final TrainingSet set;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = WeightUnit.fromIndex(set.weightUnitIndex);
    final weightText = formatWeightValue(
      set.weightValue,
      unit,
      raw: set.weightRaw,
    );
    final unresolved = set.weightValue == null && set.weightRaw.isNotEmpty;
    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${set.groupIndex}'.padLeft(2, '0'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kSteel,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Text(
                weightText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: unresolved ? kDangerRed : kChalk,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${set.reps}',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kChalk,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(
              width: 36,
              height: 24,
              child: InkWell(
                onTap: onDelete,
                child: const Center(
                  child: Text(
                    '×',
                    style: TextStyle(color: kSteel, fontSize: 18, height: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.gymSelected,
    required this.bodyPartEmpty,
    required this.hasEntries,
    required this.allCompleted,
    required this.sessionEnded,
    required this.onSelectGym,
    required this.onAddExercise,
    required this.onPrimary,
  });

  final bool gymSelected;
  final bool bodyPartEmpty;
  final bool hasEntries;
  final bool allCompleted;
  final bool sessionEnded;
  final VoidCallback onSelectGym;
  final VoidCallback onAddExercise;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd = gymSelected && !bodyPartEmpty;

    Widget left;
    if (!gymSelected) {
      left = OutlinedButton(onPressed: onSelectGym, child: const Text('选择健身房'));
    } else if (bodyPartEmpty) {
      left = Text(
        '填写训练部位后，才能添加动作。',
        style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
      );
    } else if (hasEntries && allCompleted) {
      left = FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(172, 48)),
        onPressed: onPrimary,
        child: Text(sessionEnded ? '查看训练总结' : '结束今日训练'),
      );
    } else if (hasEntries) {
      left = Text(
        '勾选全部动作后结束',
        style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
      );
    } else {
      left = const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(top: BorderSide(color: kLine)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: left),
            ),
            if (canAdd)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(124, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: onAddExercise,
                child: const Text('+ 添加动作'),
              ),
          ],
        ),
      ),
    );
  }
}
