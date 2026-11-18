import 'package:flutter/material.dart';

import '../../core/exercise_group.dart';
import '../../core/theme.dart';
import '../../data/models/exercise_preset.dart';
import '../../widgets/ledger.dart';

class ExerciseFormResult {
  const ExerciseFormResult({
    required this.exerciseName,
    required this.restText,
    required this.note,
    required this.addToPreset,
    required this.presetGroup,
    required this.presetNote,
  });

  final String exerciseName;
  final String restText;
  final String note;
  final bool addToPreset;
  final String presetGroup;
  final String presetNote;
}

class ExerciseFormDialog extends StatefulWidget {
  const ExerciseFormDialog({
    super.key,
    this.initialExerciseName = '',
    this.initialRestText = '90秒',
    this.initialNote = '',
    this.selectedPreset,
    this.isNewAction = false,
    this.initialPresetGroup = '',
  });

  final String initialExerciseName;
  final String initialRestText;
  final String initialNote;
  final ExercisePreset? selectedPreset;
  final bool isNewAction;
  final String initialPresetGroup;

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _restController;
  late final TextEditingController _noteController;
  late final TextEditingController _presetNoteController;
  late bool _addToPreset;
  late String _presetGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.selectedPreset?.name ?? widget.initialExerciseName,
    );
    _restController = TextEditingController(text: widget.initialRestText);
    _noteController = TextEditingController(text: widget.initialNote);
    _presetNoteController = TextEditingController(
      text: widget.selectedPreset?.note ?? '',
    );
    _addToPreset = widget.isNewAction;
    _presetGroup = resolveExerciseGroup(
      widget.selectedPreset?.group ?? widget.initialPresetGroup,
      widget.selectedPreset?.name ?? widget.initialExerciseName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _restController.dispose();
    _noteController.dispose();
    _presetNoteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ExerciseFormResult(
        exerciseName: _nameController.text.trim(),
        restText: _restController.text.trim(),
        note: _noteController.text.trim(),
        addToPreset: _addToPreset,
        presetGroup: _presetGroup,
        presetNote: _addToPreset
            ? _presetNoteController.text.trim()
            : (widget.selectedPreset?.note ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromPreset = widget.selectedPreset != null;
    final title = fromPreset
        ? '添加动作'
        : (widget.isNewAction ? '临时新建动作' : '编辑动作');
    return LedgerDialog(
      eyebrow: fromPreset
          ? 'MOVEMENT / 添加'
          : (widget.isNewAction ? 'MOVEMENT / 新建' : 'MOVEMENT / 编辑'),
      title: title,
      subtitle: fromPreset
          ? '来自动作预设'
          : (widget.isNewAction ? '只记今天，或同时存为预设' : '修改今天的动作信息'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isNewAction && !fromPreset ? '添加动作' : '保存'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: 50,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '动作名称',
                hintText: '例如：史密斯卧推',
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请填写动作名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _restController,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: '组间休息',
                hintText: '例如：90秒 / 2分钟',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: '动作备注 / 感受（可选）',
                hintText: '例如：肩胛收紧、状态不错',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
            if (!fromPreset && widget.isNewAction) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _addToPreset = !_addToPreset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      LedgerCheck(
                        value: _addToPreset,
                        onChanged: (value) =>
                            setState(() => _addToPreset = value),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '同时加入健身房预设',
                              style: TextStyle(fontSize: 13, color: kChalk),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '保存名称、分组和备注',
                              style: TextStyle(fontSize: 10, color: kSteel),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_addToPreset) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final group in kExerciseGroups)
                      InkWell(
                        onTap: () => setState(() => _presetGroup = group),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _presetGroup == group
                                ? kSafetyOrange
                                : Colors.transparent,
                            border: Border.all(
                              color: _presetGroup == group
                                  ? kSafetyOrange
                                  : kLine,
                            ),
                          ),
                          child: Text(
                            group,
                            style: TextStyle(
                              fontSize: 11,
                              color: _presetGroup == group ? kInk : kSteel,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _presetNoteController,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: '预设备注（可选）',
                    counterText: '',
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
