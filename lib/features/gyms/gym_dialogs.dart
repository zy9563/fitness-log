import 'package:flutter/material.dart';

import '../../core/exercise_group.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';

class GymFormResult {
  const GymFormResult({required this.name, required this.note});

  final String name;
  final String note;
}

class GymFormDialog extends StatefulWidget {
  const GymFormDialog({super.key, this.gym});

  final Gym? gym;

  @override
  State<GymFormDialog> createState() => _GymFormDialogState();
}

class _GymFormDialogState extends State<GymFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gym?.name ?? '');
    _noteController = TextEditingController(text: widget.gym?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      GymFormResult(
        name: _nameController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gym == null ? '新建健身房' : '编辑健身房'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 30,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '健身房名称',
                  hintText: '例如：公司附近的店',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入健身房名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  hintText: '例如：离家近、停车方便',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }
}

class PresetFormResult {
  const PresetFormResult({
    required this.name,
    required this.group,
    required this.note,
  });

  final String name;
  final String group;
  final String note;
}

class PresetFormDialog extends StatefulWidget {
  const PresetFormDialog({
    super.key,
    this.preset,
    this.gymName = '',
    this.initialGroup = '',
  });

  final ExercisePreset? preset;
  final String gymName;

  /// 从某个折叠分组里点“添加”时，默认选中该分组。
  final String initialGroup;

  @override
  State<PresetFormDialog> createState() => _PresetFormDialogState();
}

class _PresetFormDialogState extends State<PresetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late String _group;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset?.name ?? '');
    _noteController = TextEditingController(text: widget.preset?.note ?? '');
    _group = resolveExerciseGroup(
      widget.preset?.group ?? widget.initialGroup,
      widget.preset?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PresetFormResult(
        name: _nameController.text.trim(),
        group: _group,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.preset == null ? '新增动作预设' : '编辑动作预设'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.gymName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '健身房：${widget.gymName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              DropdownButtonFormField<String>(
                initialValue: _group,
                decoration: const InputDecoration(
                  labelText: '分组',
                  helperText: '预设页和添加动作时按此分组折叠',
                  helperMaxLines: 2,
                ),
                items: [
                  for (final group in kExerciseGroups)
                    DropdownMenuItem(value: group, child: Text(group)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _group = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: '动作名称',
                  hintText: '例如：史密斯卧推',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入动作名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  hintText: '器械编号、动作要点等',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }
}
