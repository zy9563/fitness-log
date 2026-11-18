import 'package:flutter/material.dart';

import '../../../core/date_x.dart';
import '../../../core/exercise_group.dart';
import '../../../core/theme.dart';
import '../../../data/models/exercise_preset.dart';
import '../../../widgets/ledger.dart';

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
    backgroundColor: kCarbon,
    barrierColor: kInk.withAlpha(210),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetContext) {
      return Container(
        height: MediaQuery.sizeOf(sheetContext).height * 0.9,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kSafetyOrange, width: 2)),
        ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择动作',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.bodyPart.isEmpty
                          ? '按肌群展开，可勾选多个动作'
                          : '本次部位：${widget.bodyPart} · 点选顺序即添加顺序',
                      style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('×'),
              ),
            ],
          ),
        ),
        const LedgerRule(),
        InkWell(
          onTap: () =>
              Navigator.pop(context, const PresetPickerResult(createNew: true)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kLineSoft)),
            ),
            child: Row(
              children: [
                const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 18,
                    color: kSafetyOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '临时新建动作',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                          color: kChalk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '不加入预设，直接填写动作',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: kSteel,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('›', style: TextStyle(fontSize: 20, color: kSteel)),
              ],
            ),
          ),
        ),
        Expanded(
          child: hasPresets
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  children: [
                    for (var i = 0; i < kExerciseGroups.length; i++)
                      if ((widget.groupedPresets[kExerciseGroups[i]] ??
                              const [])
                          .isNotEmpty)
                        _PickerGroup(
                          key: PageStorageKey<String>(
                            'picker-${kExerciseGroups[i]}',
                          ),
                          index: (i + 1).toString().padLeft(2, '0'),
                          group: kExerciseGroups[i],
                          items:
                              widget.groupedPresets[kExerciseGroups[i]] ??
                              const [],
                          selectedIds: _selectedIds,
                          isExisting: _isExisting,
                          onToggle: _toggle,
                        ),
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
                        color: kSteel,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
        ),
        _buildBottomBar(context, selectedCount),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, int selectedCount) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedCount == 0 ? '勾选动作后可批量加入今天' : '已选择 $selectedCount 个动作',
              style: theme.textTheme.labelSmall?.copyWith(
                color: selectedCount == 0 ? kSteel : kSafetyOrange,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: selectedCount == 0 ? null : _confirm,
            style: FilledButton.styleFrom(
              minimumSize: const Size(128, 44),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(selectedCount == 0 ? '添加动作' : '添加 $selectedCount 个'),
          ),
        ],
      ),
    );
  }
}

class _PickerGroup extends StatefulWidget {
  const _PickerGroup({
    super.key,
    required this.index,
    required this.group,
    required this.items,
    required this.selectedIds,
    required this.isExisting,
    required this.onToggle,
  });

  final String index;
  final String group;
  final List<ExercisePreset> items;
  final List<int> selectedIds;
  final bool Function(ExercisePreset) isExisting;
  final ValueChanged<ExercisePreset> onToggle;

  @override
  State<_PickerGroup> createState() => _PickerGroupState();
}

class _PickerGroupState extends State<_PickerGroup> {
  bool _open = false;

  int get _selectedCount => widget.items
      .where((preset) => widget.selectedIds.contains(preset.id))
      .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
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
            key: PageStorageKey<String>('preset-picker-group-${widget.group}'),
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
                  Text(
                    widget.group,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      color: kChalk,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.items.length} 个',
                    style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
                  ),
                  if (_selectedCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '已选 $_selectedCount',
                      style: const TextStyle(
                        fontSize: 10,
                        color: kSafetyOrange,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                  const Spacer(),
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
            for (final preset in widget.items)
              _PickerRow(
                preset: preset,
                existing: widget.isExisting(preset),
                selected: widget.selectedIds.contains(preset.id),
                onToggle: () => widget.onToggle(preset),
              ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.preset,
    required this.existing,
    required this.selected,
    required this.onToggle,
  });

  final ExercisePreset preset;
  final bool existing;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = preset.note.trim();
    return InkWell(
      onTap: existing ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          children: [
            LedgerCheck(
              value: existing || selected,
              onChanged: existing ? null : (_) => onToggle(),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: existing
                          ? kSteel
                          : selected
                          ? kSafetyOrange
                          : kChalk,
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
            if (existing)
              const Text(
                '已添加',
                style: TextStyle(
                  fontSize: 10,
                  color: kSteel,
                  letterSpacing: 0.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
