import 'package:flutter/material.dart';

import '../../core/exercise_group.dart';
import '../../data/models/exercise_preset.dart';

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
    return AlertDialog(
      title: Text(
        fromPreset ? '添加动作' : (widget.isNewAction ? '临时新建动作' : '编辑动作'),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 50,
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
                const SizedBox(height: 2),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _addToPreset,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('同时加入该健身房动作预设'),
                  subtitle: const Text('保存动作名称、分组和备注'),
                  onChanged: (value) {
                    setState(() => _addToPreset = value ?? false);
                  },
                ),
                if (_addToPreset) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _presetGroup,
                    decoration: const InputDecoration(labelText: '预设分组'),
                    items: [
                      for (final group in kExerciseGroups)
                        DropdownMenuItem(value: group, child: Text(group)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _presetGroup = value);
                      }
                    },
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('添加动作')),
      ],
    );
  }
}
