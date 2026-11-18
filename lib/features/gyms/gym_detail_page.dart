import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/exercise_group.dart';
import '../../data/fitness_store.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/exercise_group_badge.dart';
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
    if (gym == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('健身房')),
        body: const EmptyState(
          icon: Icons.storefront_outlined,
          title: '健身房不存在',
          message: '它可能已经被删除。',
        ),
      );
    }

    final presets = store.presetsForGym(gymId);
    final grouped = store.groupedPresetsForGym(gymId);
    final activeGroups = grouped.values
        .where((items) => items.isNotEmpty)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: Text(gym.name),
        actions: [
          IconButton(
            tooltip: '编辑健身房',
            onPressed: () => _editGym(context, gym),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _deleteGym(context, gym);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('删除健身房')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppSectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gym.note.trim().isEmpty
                            ? '这个健身房还没有备注。可以点击右上角编辑。'
                            : gym.note.trim(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Row(
                children: [
                  Text(
                    '动作预设',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${presets.length} 个 · $activeGroups 组有动作',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _addPreset(context, gym),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新增'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                children: [
                  if (presets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                      child: Text(
                        '还没有动作预设。展开下方任意分组即可添加，'
                        '录入训练时也会按分组快速查找。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final group in kExerciseGroups)
                    _buildPresetGroup(
                      context,
                      gym,
                      group,
                      grouped[group] ?? const <ExercisePreset>[],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPreset(context, gym),
        icon: const Icon(Icons.add),
        label: const Text('新增动作'),
      ),
    );
  }

  Widget _buildPresetGroup(
    BuildContext context,
    Gym gym,
    String group,
    List<ExercisePreset> items,
  ) {
    final theme = Theme.of(context);
    return AppSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('gym-${gym.id}-preset-group-$group'),
          maintainState: true,
          tilePadding: const EdgeInsets.only(left: 14, right: 8),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: ExerciseGroupBadge(group: group),
          title: Text(
            group,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            '${items.length} 个动作',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '该分组暂无动作',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _addPreset(context, gym, initialGroup: group),
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('添加'),
                    ),
                  ],
                ),
              )
            else
              for (final preset in items)
                _PresetRow(
                  preset: preset,
                  group: group,
                  onEdit: () => _editPreset(context, gym, preset),
                  onDelete: () => _deletePreset(context, preset),
                ),
          ],
        ),
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
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 7, 2, 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.isEmpty ? '分组：$group' : '分组：$group · $note',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                PopupMenuItem(value: 'edit', child: Text('编辑')),
                PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
