import 'package:flutter/material.dart';

import '../../../core/date_x.dart';
import '../../../core/exercise_group.dart';
import '../../../data/models/exercise_preset.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/exercise_group_badge.dart';

class PresetPickerResult {
  const PresetPickerResult({
    this.presets = const <ExercisePreset>[],
    this.createNew = false,
  });

  final List<ExercisePreset> presets;
  final bool createNew;
}

/// 按肌群折叠展示的动作选择器。
///
/// 可以一次勾选多个动作；已存在于当天的动作会显示为不可选。
Future<PresetPickerResult?> showExercisePresetPicker({
  required BuildContext context,
  required Map<String, List<ExercisePreset>> groupedPresets,
  required Set<String> existingNames,
  required String bodyPart,
}) {
  return showModalBottomSheet<PresetPickerResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.88,
        child: ExercisePresetPickerSheet(
          groupedPresets: groupedPresets,
          existingNames: existingNames,
          bodyPart: bodyPart,
        ),
      );
    },
  );
}

class ExercisePresetPickerSheet extends StatefulWidget {
  const ExercisePresetPickerSheet({
    super.key,
    required this.groupedPresets,
    required this.existingNames,
    required this.bodyPart,
  });

  final Map<String, List<ExercisePreset>> groupedPresets;

  /// 已归一化的动作名，今天已经添加过的动作不可重复勾选。
  final Set<String> existingNames;
  final String bodyPart;

  @override
  State<ExercisePresetPickerSheet> createState() =>
      _ExercisePresetPickerSheetState();
}

class _ExercisePresetPickerSheetState extends State<ExercisePresetPickerSheet> {
  /// 按点击先后保存，批量添加时保持这个顺序。
  final List<int> _selectedIds = <int>[];

  List<ExercisePreset> get _allPresets => [
    for (final group in kExerciseGroups) ...?widget.groupedPresets[group],
  ];

  List<ExercisePreset> get _selectedPresets {
    final byId = <int, ExercisePreset>{
      for (final preset in _allPresets) preset.id: preset,
    };
    return [
      for (final id in _selectedIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  bool _isExisting(ExercisePreset preset) =>
      widget.existingNames.contains(normalizeLookupName(preset.name));

  int _selectedInGroup(String group) =>
      (widget.groupedPresets[group] ?? const [])
          .where((preset) => _selectedIds.contains(preset.id))
          .length;

  void _toggle(ExercisePreset preset) {
    if (_isExisting(preset)) return;
    setState(() {
      if (_selectedIds.contains(preset.id)) {
        _selectedIds.remove(preset.id);
      } else {
        _selectedIds.add(preset.id);
      }
    });
  }

  void _confirm() {
    final selected = _selectedPresets;
    if (selected.isEmpty) return;
    Navigator.pop(context, PresetPickerResult(presets: selected));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selectedIds.length;
    final hasPresets = _allPresets.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择动作',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.bodyPart.isEmpty
                          ? '按肌群展开，可勾选多个动作'
                          : '本次部位：${widget.bodyPart} · 可勾选多个动作',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AppSectionCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.zero,
            minCardOpacity: 1,
            child: ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withAlpha(24),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              title: const Text('临时新建动作'),
              subtitle: const Text('不加入预设，直接填写动作'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(
                context,
                const PresetPickerResult(createNew: true),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: hasPresets
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  children: [
                    for (final group in kExerciseGroups)
                      if ((widget.groupedPresets[group] ?? const []).isNotEmpty)
                        _buildGroup(context, group),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      '这个健身房还没有动作预设。\n'
                      '可以先临时新建动作，或去“健身房”里添加预设。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
        ),
        _buildBottomBar(context, selectedCount),
      ],
    );
  }

  Widget _buildGroup(BuildContext context, String group) {
    final theme = Theme.of(context);
    final items = widget.groupedPresets[group] ?? const <ExercisePreset>[];
    final selectedCount = _selectedInGroup(group);
    return AppSectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      minCardOpacity: 1,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('preset-picker-group-$group'),
          maintainState: true,
          tilePadding: const EdgeInsets.only(left: 12, right: 8),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: ExerciseGroupBadge(group: group, radius: 16),
          title: Row(
            children: [
              Text(
                group,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${items.length} 个',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '已选 $selectedCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            for (final preset in items)
              _PresetCheckboxTile(
                preset: preset,
                group: group,
                existing: _isExisting(preset),
                selected: _selectedIds.contains(preset.id),
                onChanged: () => _toggle(preset),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int selectedCount) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedCount == 0 ? '勾选动作后可批量加入今天' : '已选择 $selectedCount 个动作',
              style: theme.textTheme.bodySmall?.copyWith(
                color: selectedCount == 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
                fontWeight: selectedCount == 0
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: selectedCount == 0 ? null : _confirm,
            icon: const Icon(Icons.check, size: 18),
            label: Text(selectedCount == 0 ? '添加动作' : '添加 $selectedCount 个'),
          ),
        ],
      ),
    );
  }
}

class _PresetCheckboxTile extends StatelessWidget {
  const _PresetCheckboxTile({
    required this.preset,
    required this.group,
    required this.existing,
    required this.selected,
    required this.onChanged,
  });

  final ExercisePreset preset;
  final String group;
  final bool existing;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = preset.note.trim();
    final subtitle = existing
        ? '今天已添加，无需重复勾选'
        : note.isEmpty
        ? '分组：$group'
        : '分组：$group · $note';
    return CheckboxListTile(
      value: existing || selected,
      onChanged: existing ? null : (_) => onChanged(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.only(left: 14, right: 8),
      dense: true,
      title: Text(
        preset.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: existing ? theme.colorScheme.onSurfaceVariant : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
