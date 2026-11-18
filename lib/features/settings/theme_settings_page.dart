import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../data/theme_store.dart';
import '../../widgets/app_widgets.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  Future<void> _pickColor(
    BuildContext context, {
    required Color current,
    required String title,
    required ValueChanged<Color> onPicked,
  }) async {
    var selected = current;
    final result = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: current,
              enableAlpha: false,
              hexInputBar: true,
              labelTypes: const [],
              onColorChanged: (color) => selected = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('使用此颜色'),
            ),
          ],
        );
      },
    );
    if (result != null) onPicked(result);
  }

  Future<void> _pickImage(BuildContext context, ThemeStore store) async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: false,
      );
      final path = picked?.files.single.path;
      if (path == null || path.isEmpty) return;
      await store.setBackgroundImage(path);
      if (context.mounted) showInfoSnack(context, '背景图片已应用');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ThemeStore>();
    final settings = store.settings;
    final cardColor = Color(settings.cardColorValue);
    final bgColor = Color(settings.backgroundColorValue);

    return Scaffold(
      appBar: AppBar(title: const Text('自定义主题')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '卡片背景',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _ColorLine(
                  label: '卡片背景颜色',
                  color: cardColor,
                  onTap: () => _pickColor(
                    context,
                    current: cardColor,
                    title: '选择卡片背景色',
                    onPicked: (color) => store.setCardColor(color.toARGB32()),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '卡片背景会随页面滚动位置自动调整不透明度；'
                  '靠近顶部或底部导航时变透明，离开边缘恢复不透明。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全局背景',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('纯色背景'),
                        icon: Icon(Icons.format_color_fill),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('本地图片'),
                        icon: Icon(Icons.photo_outlined),
                      ),
                    ],
                    selected: {settings.useBackgroundImage},
                    onSelectionChanged: (value) async {
                      final useImage = value.first;
                      if (useImage) {
                        if (settings.backgroundImagePath.isEmpty) {
                          await _pickImage(context, store);
                        } else {
                          await store.setUseBackgroundImage(true);
                        }
                      } else {
                        await store.setUseBackgroundImage(false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (!settings.useBackgroundImage)
                  _ColorLine(
                    label: '纯色背景颜色',
                    color: bgColor,
                    onTap: () => _pickColor(
                      context,
                      current: bgColor,
                      title: '选择全局背景色',
                      onPicked: (color) =>
                          store.setBackgroundColor(color.toARGB32()),
                    ),
                  )
                else ...[
                  Text(
                    '图片背景优先级最高，纯色背景色不会参与图片遮罩。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (settings.backgroundImagePath.isNotEmpty) ...[
                    Text(
                      settings.backgroundImagePath,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(context, store),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('更换图片'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => store.removeBackgroundImage(),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('移除'),
                        ),
                      ],
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(context, store),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('选择本地图片'),
                    ),
                  if (settings.backgroundImagePath.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '图片不透明度：${(settings.backgroundImageOpacity * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: settings.backgroundImageOpacity,
                      min: 0.05,
                      max: 1,
                      divisions: 19,
                      onChanged: (value) => store.setImageOpacity(value),
                    ),
                    Text(
                      '模糊度：${settings.backgroundImageBlur.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: settings.backgroundImageBlur,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      onChanged: (value) => store.setImageBlur(value),
                    ),
                  ],
                ],
              ],
            ),
          ),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预览',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('这是页面文字，应该始终清晰可读。'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '这是卡片文字，会根据卡片颜色自动适配。',
                    style: TextStyle(
                      color:
                          ThemeData.estimateBrightnessForColor(cardColor) ==
                              Brightness.dark
                          ? Colors.white
                          : const Color(0xFF171A1F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await store.resetCustomColors();
              if (context.mounted) showInfoSnack(context, '已恢复默认自定义颜色');
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('恢复默认自定义颜色'),
          ),
        ],
      ),
    );
  }
}

class _ColorLine extends StatelessWidget {
  const _ColorLine({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            const Icon(Icons.colorize, size: 17),
          ],
        ),
      ),
    );
  }
}
