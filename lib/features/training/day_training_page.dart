import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/exercise_group.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/app_widgets.dart';
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
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    '选择健身房',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    '这次训练记录会归到所选健身房。',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_business_outlined),
                  title: const Text('新建健身房'),
                  onTap: () async {
                    final gym = await _createGym(sheetContext);
                    if (gym != null && sheetContext.mounted) {
                      Navigator.pop(sheetContext, gym);
                    }
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: store.gyms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final gym = store.gyms[index];
                      return ListTile(
                        leading: const Icon(Icons.storefront),
                        title: Text(gym.name),
                        subtitle: gym.note.trim().isEmpty
                            ? null
                            : Text(
                                gym.note.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(sheetContext, gym),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${formatDateChinese(widget.date)} ${weekdayZh(widget.date)}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本次训练部位',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '先填一次，今天所有动作共用这个部位。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                BodyPartField(
                  controller: _bodyPartController,
                  suggestions: store.bodyPartSuggestions(),
                ),
              ],
            ),
          ),
          AppSectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(28),
                      child: Icon(
                        Icons.storefront,
                        color: Theme.of(context).colorScheme.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '健身房',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            gym?.name ?? '还没有选择',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _selectGym,
                      child: Text(gym == null ? '选择' : '切换'),
                    ),
                  ],
                ),
                if (gym != null) ...[
                  const Divider(height: 22),
                  Row(
                    children: [
                      _SummaryItem(value: '${entries.length}', label: '动作'),
                      _SummaryItem(value: '$totalGroups', label: '总组数'),
                      _SummaryItem(value: '$totalReps', label: '总次数'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (gym == null)
            AppSectionCard(
              child: EmptyState(
                icon: Icons.storefront_outlined,
                title: store.gyms.isEmpty ? '先新建健身房' : '先选择健身房',
                message: store.gyms.isEmpty
                    ? '记录当天训练前，需要先有一家健身房。'
                    : '选择健身房后，才能添加动作和组记录。',
                action: FilledButton.icon(
                  onPressed: store.gyms.isEmpty
                      ? () async {
                          final created = await _createGym(context);
                          if (created != null && mounted) {
                            setState(() => _gymId = created.id);
                          }
                        }
                      : _selectGym,
                  icon: const Icon(Icons.add),
                  label: Text(store.gyms.isEmpty ? '新建健身房' : '选择健身房'),
                ),
              ),
            )
          else if (entries.isEmpty)
            AppSectionCard(
              child: EmptyState(
                icon: bodyPartEmpty
                    ? Icons.accessibility_new
                    : Icons.fitness_center,
                title: bodyPartEmpty ? '先填写本次训练部位' : '今天还没有动作记录',
                message: bodyPartEmpty
                    ? '在上方填写一次部位（可自由组合，如“胸，三头”），'
                          '再添加动作。'
                    : '从动作预设选择，或临时新建一个动作。'
                          '每个动作下可以添加多行组。',
                action: bodyPartEmpty
                    ? null
                    : FilledButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('添加动作'),
                      ),
              ),
            )
          else ...[
            const SectionTitle('动作与组'),
            for (final entry in entries)
              _EntryCard(
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
                onEditSet: (set) => _editOrAddSet(entry: entry, existing: set),
                onDeleteSet: _deleteSet,
              ),
            const SizedBox(height: 4),
            if (!bodyPartEmpty)
              OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('继续添加动作'),
              ),
          ],
          const SizedBox(height: 10),
          const AppInfoBanner(
            icon: Icons.cloud_off_outlined,
            text:
                '修改会即时保存到本机 Isar 数据库。卸载 App 会清除全部数据，'
                '换机前请先导出 Excel 备份。',
          ),
        ],
      ),
      floatingActionButton: gym == null || bodyPartEmpty
          ? null
          : allCompleted
          ? FloatingActionButton.extended(
              onPressed: _sessionEnded
                  ? () => _showCompletion(
                      store: store,
                      entries: entries,
                      totalGroups: totalGroups,
                    )
                  : () => _endToday(
                      store: store,
                      entries: entries,
                      totalGroups: totalGroups,
                    ),
              icon: Icon(
                _sessionEnded
                    ? Icons.emoji_events_outlined
                    : Icons.flag_outlined,
              ),
              label: Text(_sessionEnded ? '查看训练总结' : '结束今日训练'),
            )
          : FloatingActionButton.extended(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('添加动作'),
            ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
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
    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: entry.completed,
                onChanged: (value) => onToggle(value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: entry.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: entry.completed
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 8,
                      runSpacing: 3,
                      children: [
                        _MetaChip(
                          icon: Icons.accessibility_new,
                          text: entry.bodyPart,
                        ),
                        if (entry.restText.trim().isNotEmpty)
                          _MetaChip(
                            icon: Icons.timer_outlined,
                            text: '休息 ${entry.restText.trim()}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '更多',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('编辑动作')),
                  PopupMenuItem(value: 'delete', child: Text('删除动作')),
                ],
              ),
            ],
          ),
          if (entry.note.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                entry.note.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          const Divider(height: 16),
          if (sets.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
              child: Text(
                '还没有组记录',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final set in sets)
              _SetRow(
                set: set,
                onEdit: () => onEditSet(set),
                onDelete: () => onDeleteSet(set),
              ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onAddSet,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加一组'),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
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
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(70),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 2, 7),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '第${set.groupIndex}行',
                  style: theme.textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  '${set.groupCount} 组 × $weightText × ${set.reps} 次',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: unresolved ? theme.colorScheme.error : null,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 18),
                tooltip: '删除',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
