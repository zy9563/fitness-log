import 'package:flutter/material.dart';

/// 部位自由输入 + 历史联想。
///
/// 不做强制枚举，历史值只作为快捷标签；用户可输入任意组合文本。
class BodyPartField extends StatefulWidget {
  const BodyPartField({
    super.key,
    required this.controller,
    required this.suggestions,
    this.validator,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final String? Function(String?)? validator;

  @override
  State<BodyPartField> createState() => _BodyPartFieldState();
}

class _BodyPartFieldState extends State<BodyPartField> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.controller.text.trim();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final next = widget.controller.text.trim();
    if (next != _query) setState(() => _query = next);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = widget.suggestions
        .where((item) => item.trim().isNotEmpty)
        .take(16)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: '部位',
            hintText: '例如：胸，三头',
            counterText: '',
            suffixIcon: Icon(Icons.expand_more),
          ),
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.trim().isEmpty) return '请填写部位';
                return null;
              },
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '历史部位',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final item in suggestions)
                ActionChip(
                  label: Text(item),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    widget.controller.text = item;
                    widget.controller.selection = TextSelection.collapsed(
                      offset: item.length,
                    );
                    setState(() => _query = item);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}
