import 'package:flutter/material.dart';

import '../../core/exercise_group.dart';
import '../../core/theme.dart';
import '../../data/models/exercise_preset.dart';
import '../../data/models/gym.dart';
import '../../widgets/ledger.dart';

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
    return LedgerDialog(
      eyebrow: widget.gym == null ? 'NEW GYM' : 'EDIT GYM',
      title: widget.gym == null ? '新建健身房' : '编辑健身房',
      subtitle: '场馆信息只保存在本机',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
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
                hintText: '例如：南京信息工程大学体育馆',
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
                hintText: '器械特点、地址、开放时间',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
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
    return LedgerDialog(
      eyebrow: widget.preset == null ? 'NEW MOVEMENT' : 'EDIT MOVEMENT',
      title: widget.preset == null ? '新增动作预设' : '编辑动作预设',
      subtitle: widget.gymName.isEmpty ? '动作按肌群归组' : '归属：${widget.gymName}',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '分组',
              style: TextStyle(fontSize: 10, color: kSteel, letterSpacing: 1.8),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final group in kExerciseGroups)
                  InkWell(
                    onTap: () => setState(() => _group = group),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _group == group ? kSafetyOrange : kGraphite,
                        border: Border.all(
                          color: _group == group ? kSafetyOrange : kLine,
                        ),
                      ),
                      child: Text(
                        group,
                        style: TextStyle(
                          fontSize: 13,
                          color: _group == group ? kInk : kSteel,
                          fontWeight: _group == group
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
                hintText: '器械编号、动作要点',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
