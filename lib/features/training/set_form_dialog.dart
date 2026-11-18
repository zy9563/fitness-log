import 'package:flutter/material.dart';

import '../../core/date_x.dart';
import '../../core/input_formatters.dart';
import '../../core/weight.dart';
import '../../data/models/training_set.dart';

class SetFormResult {
  const SetFormResult({
    required this.groupCount,
    required this.weightValue,
    required this.weightUnitIndex,
    required this.reps,
    required this.note,
    required this.weightRaw,
  });

  final int groupCount;
  final double? weightValue;
  final int? weightUnitIndex;
  final int reps;
  final String note;
  final String weightRaw;
}

class SetFormDialog extends StatefulWidget {
  const SetFormDialog({super.key, this.existing, this.defaultUnitIndex});

  final TrainingSet? existing;
  final int? defaultUnitIndex;

  @override
  State<SetFormDialog> createState() => _SetFormDialogState();
}

class _SetFormDialogState extends State<SetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _groupController;
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _noteController;
  late WeightUnit _unit;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _groupController = TextEditingController(
      text: (existing?.groupCount ?? 1).toString(),
    );
    _weightController = TextEditingController(
      text: existing?.weightValue == null
          ? ''
          : formatWeight(existing!.weightValue),
    );
    _repsController = TextEditingController(
      text: (existing?.reps ?? 8).toString(),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _unit =
        WeightUnit.fromIndex(existing?.weightUnitIndex) ??
        WeightUnit.fromIndex(widget.defaultUnitIndex) ??
        WeightUnit.kg;
  }

  @override
  void dispose() {
    _groupController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final groupCount = int.parse(_groupController.text.trim());
    final reps = int.parse(_repsController.text.trim());
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? null : double.parse(weightText);
    Navigator.pop(
      context,
      SetFormResult(
        groupCount: groupCount,
        weightValue: weight,
        weightUnitIndex: _unit.index,
        reps: reps,
        note: _noteController.text.trim(),
        weightRaw: weight == null ? (widget.existing?.weightRaw ?? '') : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingRaw = widget.existing?.weightRaw.trim() ?? '';
    final showRawWarning =
        existingRaw.isNotEmpty && widget.existing?.weightValue == null;
    return AlertDialog(
      title: Text(widget.existing == null ? '添加一组' : '编辑组记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _groupController,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [PositiveIntInputFormatter()],
                      decoration: const InputDecoration(labelText: '组数'),
                      validator: (value) {
                        final number = int.tryParse(value?.trim() ?? '');
                        if (number == null || number < 1) return '至少为 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [PositiveIntInputFormatter()],
                      decoration: const InputDecoration(labelText: '次数'),
                      validator: (value) {
                        final number = int.tryParse(value?.trim() ?? '');
                        if (number == null || number < 1) return '至少为 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [WeightInputFormatter()],
                decoration: const InputDecoration(
                  labelText: '重量数值（可留空）',
                  hintText: '例如：35、6、20.5',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final number = double.tryParse(text);
                  if (number == null || number < 0) return '请输入有效数字';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text('重量单位', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.piece, label: Text('片')),
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (value) {
                    setState(() => _unit = value.first);
                  },
                ),
              ),
              if (showRawWarning) ...[
                const SizedBox(height: 10),
                Text(
                  '原始重量：$existingRaw（未识别，未参与统计）。填写有效数字后会自动替换。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: '备注 / 感受（可选）',
                  hintText: '例如：最后一组力竭',
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
