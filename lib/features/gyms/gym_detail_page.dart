import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/exercise_group.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';
import 'gym_dialogs.dart';

class GymDetailPage extends StatelessWidget {
  const GymDetailPage({super.key, required this.gymId});

  final int gymId;

  Future<void> _editGym(BuildContext context, Gym gym) async {
    final result = await showDialog<GymFormResult>(
      context: context,
      builder: (_) => GymFormDialog(gym: gym),
    );
    if (result == null || !context.mounted) return;
    try {
      await context.read<FitnessStore>().updateGym(
        gym,
        name: result.name,
        note: result.note,
      );
      if (context.mounted) showInfoSnack(context, '健身房信息已更新');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _deleteGym(BuildContext context, Gym gym) async {
    final confirmed = await confirmAction(
      context,
      title: '删除健身房？',
      message:
          '将永久删除“${gym.name}”、它的全部动作预设和训练记录，无法撤销。\n\n'
          '建议先导出 Excel 备份。',
      confirmText: '永久删除',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<FitnessStore>().deleteGym(gym.id);
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _addPreset(
    BuildContext context,
    Gym gym, {
    String initialGroup = '',
  }) async {
    final result = await showDialog<PresetFormResult>(
      context: context,
      builder: (_) =>
          PresetFormDialog(gymName: gym.name, initialGroup: initialGroup),
    );
    if (result == null || !context.mounted) return;
    try {
      await context.read<FitnessStore>().createPreset(
        gymId: gym.id,
        name: result.name,
        group: result.group,
        note: result.note,
      );
      if (context.mounted) showInfoSnack(context, '动作预设已添加');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _editPreset(
    BuildContext context,
    Gym gym,
    ExercisePreset preset,
  ) async {
    final result = await showDialog<PresetFormResult>(
      context: context,
      builder: (_) => PresetFormDialog(preset: preset, gymName: gym.name),
    );
    if (result == null || !context.mounted) return;
    try {
      await context.read<FitnessStore>().updatePreset(
        preset,
        name: result.name,
        group: result.group,
        note: result.note,
      );
      if (context.mounted) showInfoSnack(context, '动作预设已更新');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _deletePreset(
    BuildContext context,
    ExercisePreset preset,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: '删除动作预设？',
      message: '将删除“${preset.name}”。历史训练记录不会删除。',
      confirmText: '删除',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<FitnessStore>().deletePreset(preset.id);
      if (context.mounted) showInfoSnack(context, '动作预设已删除');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final gym = store.gymById(gymId);
    final theme = Theme.of(context);
    if (gym == null) {
      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const LedgerBackButton(),
              const SizedBox(height: 30),
              const EmptyState(title: '健身房不存在', message: '它可能已经被删除。'),
            ],
          ),
        ),
      );
    }

    final presets = store.presetsForGym(gymId);
    final grouped = store.groupedPresetsForGym(gymId);
    final activeGroups = grouped.values
        .where((items) => items.isNotEmpty)
        .length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            Row(
              children: [
                const LedgerBackButton(),
                const Spacer(),
                TextButton(
                  onPressed: () => _editGym(context, gym),
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () => _deleteGym(context, gym),
                  style: TextButton.styleFrom(foregroundColor: kDangerRed),
                  child: const Text('删除'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LedgerPageHeader(
              title: gym.name,
              subtitle: '${presets.length} 个动作 · $activeGroups 组有内容',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: kSafetyOrange, width: 2),
                  top: BorderSide(color: kLineSoft),
                  bottom: BorderSide(color: kLineSoft),
                ),
              ),
              child: Text(
                gym.note.trim().isEmpty
                    ? '这个健身房还没有备注。点右上角“编辑”补充器械或地址。'
                    : gym.note.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kSteel,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(width: 3, height: 18, color: kSafetyOrange),
                const SizedBox(width: 9),
                Text(
                  '动作预设',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _addPreset(context, gym),
                  child: const Text('+ 新增'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (presets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Text(
                  '还没有动作预设。展开任意分组即可添加；录入训练时也会按分组快速查找。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kSteel,
                    height: 1.55,
                  ),
                ),
              ),
            for (var i = 0; i < kExerciseGroups.length; i++)
              _PresetGroup(
                key: PageStorageKey<String>(
                  'gym-${gym.id}-preset-group-${kExerciseGroups[i]}',
                ),
                index: (i + 1).toString().padLeft(2, '0'),
                gym: gym,
                group: kExerciseGroups[i],
                items: grouped[kExerciseGroups[i]] ?? const <ExercisePreset>[],
                onAdd: (group) => _addPreset(context, gym, initialGroup: group),
                onEdit: (preset) => _editPreset(context, gym, preset),
                onDelete: (preset) => _deletePreset(context, preset),
              ),
          ],
        ),
      ),
    );
  }
}

class _PresetGroup extends StatefulWidget {
  const _PresetGroup({
    super.key,
    required this.index,
    required this.gym,
    required this.group,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final String index;
  final Gym gym;
  final String group;
  final List<ExercisePreset> items;
  final ValueChanged<String> onAdd;
  final ValueChanged<ExercisePreset> onEdit;
  final ValueChanged<ExercisePreset> onDelete;

  @override
  State<_PresetGroup> createState() => _PresetGroupState();
}

class _PresetGroupState extends State<_PresetGroup> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _open ? kCarbon : Colors.transparent,
        border: Border(
          top: BorderSide(
            color: _open ? kSafetyOrange : kLine,
            width: _open ? 1.5 : 1,
          ),
          bottom: const BorderSide(color: kLineSoft),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      widget.index,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: kSafetyOrange,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.group,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 17,
                        color: kChalk,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.items.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kSteel,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _open ? '−' : '+',
                    style: const TextStyle(
                      fontSize: 20,
                      color: kSteel,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(34, 0, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '该分组暂无动作',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: kSteel,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => widget.onAdd(widget.group),
                            child: const Text('+ 添加'),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final preset in widget.items)
                      _PresetRow(
                        preset: preset,
                        group: widget.group,
                        onEdit: () => widget.onEdit(preset),
                        onDelete: () => widget.onDelete(preset),
                      ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => widget.onAdd(widget.group),
                      child: const Text('+ 添加到本组'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.preset,
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final ExercisePreset preset;
  final String group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = preset.note.trim();
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kLineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: kChalk,
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: kSteel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '更多',
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('编辑')),
              PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                '···',
                style: TextStyle(fontSize: 15, color: kSteel, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
