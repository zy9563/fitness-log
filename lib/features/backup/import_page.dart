import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../services/excel_service.dart';
import '../../widgets/app_widgets.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  ImportMode _mode = ImportMode.skipDuplicate;
  int? _gymId;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    final gyms = context.read<FitnessStore>().gyms;
    if (gyms.length == 1) _gymId = gyms.first.id;
  }

  Future<void> _pickAndImport() async {
    if (_importing) return;
    final gymId = _gymId;
    if (gymId == null) {
      showInfoSnack(context, '请先选择健身房');
      return;
    }

    FilePickerResult? picked;
    try {
      picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: true,
      );
    } catch (error) {
      if (mounted) showErrorSnack(context, '无法打开文件选择器：$error');
      return;
    }
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.single;
    List<int>? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      try {
        bytes = await File(file.path!).readAsBytes();
      } catch (error) {
        if (mounted) showErrorSnack(context, '无法读取文件：$error');
        return;
      }
    }
    if (bytes == null || bytes.isEmpty) {
      if (mounted) showErrorSnack(context, '文件内容为空');
      return;
    }
    if (!mounted) return;

    final confirmed = await confirmAction(
      context,
      title: '开始导入？',
      message:
          '文件：${file.name}\n处理方式：${_mode.label}\n\n'
          '如果文件是健身记录导出的全量备份，会恢复所有健身房；'
          '普通 9 列文件只会导入当前选择的健身房。',
      confirmText: '导入',
    );
    if (!confirmed || !mounted) return;

    setState(() => _importing = true);
    try {
      final result = await context.read<FitnessStore>().importExcel(
        gymId: gymId,
        bytes: bytes,
        mode: _mode,
      );
      if (!mounted) return;
      await _showResult(result);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showResult(ImportResult result) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(result.failed > 0 ? '导入完成（有失败行）' : '导入完成'),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '成功 ${result.success} 行 · 跳过 ${result.skipped} 行 · '
                      '失败 ${result.failed} 行\n'
                      '新建动作 ${result.entriesCreated} 个 · '
                      '新增组 ${result.setsCreated} 行 · '
                      '新增预设 ${result.presetsCreated} 个',
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                  ),
                  if (result.backupFormat) ...[
                    const SizedBox(height: 8),
                    Text(
                      '全量备份模式：恢复了全部健身房数据'
                      '${result.gymsCreated > 0 ? '，新建 ${result.gymsCreated} 个健身房' : ''}。',
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                  ],
                  if (result.unresolvedRows.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      '重量未识别行（已导入，重量数值置空，原文已保留）',
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.unresolvedRows.join('、'),
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                  ],
                  if (result.errors.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      '失败行（最多显示 50 条）',
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    for (final error in result.errors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '• $error',
                          style: Theme.of(dialogContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    '有效数据已即时写入本地 Isar 数据库。',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final gyms = store.gyms;
    Gym? selectedGym;
    for (final gym in gyms) {
      if (gym.id == _gymId) selectedGym = gym;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('导入 Excel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
        children: [
          const AppInfoBanner(
            icon: Icons.upload_file,
            text:
                '第一步选择健身房，第二步选择 .xlsx 文件。'
                '普通记录表表头固定为 9 列；App 导出的全量备份会自动恢复所有健身房。',
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. 选择健身房',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (gyms.isEmpty)
                  Column(
                    children: [
                      const Text('还没有健身房，请先创建。'),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('返回“我的”创建健身房'),
                      ),
                    ],
                  )
                else
                  DropdownButtonFormField<int>(
                    key: ValueKey<int>(_gymId ?? 0),
                    initialValue: _gymId,
                    decoration: const InputDecoration(labelText: '导入到哪个健身房'),
                    items: [
                      for (final gym in gyms)
                        DropdownMenuItem(value: gym.id, child: Text(gym.name)),
                    ],
                    onChanged: _importing
                        ? null
                        : (value) => setState(() => _gymId = value),
                  ),
                if (selectedGym != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '普通文件的新动作会自动加入“${selectedGym.name}”的动作预设。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2. 固定表头',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  ExcelHeaders.record.join(' | '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '支持向下填充：部位、动作、日期可在首行填写，后续空行自动沿用上一行。'
                  '空行跳过；表头允许“单”等截断写法。日期支持多种常见格式。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SectionTitle('3. 重复处理'),
          AppSectionCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final mode in ImportMode.values)
                  ListTile(
                    leading: Icon(
                      _mode == mode
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _mode == mode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(mode.label),
                    subtitle: Text(mode.description),
                    onTap: _importing
                        ? null
                        : () => setState(() => _mode = mode),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_importing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text('正在校验并写入本地数据库，请勿关闭 App…'),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _importing || gyms.isEmpty ? null : _pickAndImport,
              icon: const Icon(Icons.file_open_outlined),
              label: const Text('选择 xlsx 文件并导入'),
            ),
          ),
          const SizedBox(height: 12),
          const AppInfoBanner(
            icon: Icons.warning_amber_rounded,
            text:
                '导入前建议先导出当前数据作为保险。覆盖模式会修改已有记录，无法撤销。'
                '重量解析失败不会报错崩溃，数值留空、原文保存在“重量原文”，并会列出行号。',
          ),
        ],
      ),
    );
  }
}
