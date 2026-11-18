import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../services/excel_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';

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

  Future<void> _pickGym() async {
    final gyms = context.read<FitnessStore>().gyms;
    if (gyms.isEmpty || _importing) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: kCarbon,
      barrierColor: kInk.withAlpha(210),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kSafetyOrange, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '导入到哪个健身房',
                          style: Theme.of(
                            sheetContext,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('×'),
                      ),
                    ],
                  ),
                ),
                const LedgerRule(),
                for (final gym in gyms)
                  InkWell(
                    onTap: () => Navigator.pop(sheetContext, gym.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: kLineSoft)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              gym.name,
                              style: const TextStyle(
                                fontSize: 15,
                                color: kChalk,
                              ),
                            ),
                          ),
                          if (gym.id == _gymId)
                            const Text(
                              '当前',
                              style: TextStyle(
                                fontSize: 10,
                                color: kSafetyOrange,
                                letterSpacing: 0.8,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _gymId = picked);
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
      setState(() => _importing = false);
      await _showResult(result);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted && _importing) setState(() => _importing = false);
    }
  }

  Future<void> _showResult(ImportResult result) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return LedgerDialog(
          eyebrow: 'IMPORT REPORT',
          title: result.failed > 0 ? '导入完成 · 有失败行' : '导入完成',
          subtitle: '有效数据已即时写入本地 Isar 数据库',
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('知道了'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: kSafetyOrange, width: 2),
                    top: BorderSide(color: kLine),
                    bottom: BorderSide(color: kLine),
                  ),
                ),
                child: Text(
                  '成功 ${result.success} 行 · 跳过 ${result.skipped} 行 · '
                  '失败 ${result.failed} 行\n'
                  '新建动作 ${result.entriesCreated} 个 · '
                  '新增组 ${result.setsCreated} 行 · '
                  '新增预设 ${result.presetsCreated} 个',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: kChalk,
                  ),
                ),
              ),
              if (result.backupFormat) ...[
                const SizedBox(height: 12),
                Text(
                  '全量备份模式：恢复了全部健身房数据'
                  '${result.gymsCreated > 0 ? '，新建 ${result.gymsCreated} 个健身房' : ''}。',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: kSteel,
                  ),
                ),
              ],
              if (result.unresolvedRows.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '重量未识别行',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSafetyOrange,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.unresolvedRows.join('、')}\n'
                  '已导入，重量数值置空，原文已保留。',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: kSteel,
                  ),
                ),
              ],
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '失败行（最多显示 50 条）',
                  style: TextStyle(
                    fontSize: 10,
                    color: kDangerRed,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                for (final error in result.errors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '· $error',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: kDangerRed,
                      ),
                    ),
                  ),
              ],
            ],
          ),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Row(
              children: [
                LedgerBackButton(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 10),
                const Text(
                  'IN / 导入',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSteel,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const LedgerPageHeader(title: '导入 Excel', subtitle: '把旧记录带进这台设备'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: kSafetyOrange, width: 2),
                  top: BorderSide(color: kLineSoft),
                  bottom: BorderSide(color: kLineSoft),
                ),
              ),
              child: const Text(
                '普通记录表固定 9 列；App 导出的全量备份会自动恢复所有健身房。'
                '导入不会上传任何数据。',
                style: TextStyle(fontSize: 12, height: 1.6, color: kSteel),
              ),
            ),
            const SizedBox(height: 22),
            const _StepLabel(index: '01', label: '选择健身房'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: kLine),
                  bottom: BorderSide(color: kLine),
                  left: BorderSide(color: kLine),
                  right: BorderSide(color: kLine),
                ),
              ),
              child: gyms.isEmpty
                  ? Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '还没有健身房，请先创建。',
                            style: TextStyle(fontSize: 13, color: kSteel),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('返回创建'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedGym?.name ?? '尚未选择',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: selectedGym == null ? kSteel : kChalk,
                                ),
                              ),
                              if (selectedGym != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  '新动作会自动加入该场馆的预设',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: kSteel),
                                ),
                              ],
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _importing ? null : _pickGym,
                          child: Text(selectedGym == null ? '选择' : '更换'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 22),
            const _StepLabel(index: '02', label: '固定表头'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: kLine),
                  bottom: BorderSide(color: kLine),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    ExcelHeaders.record.join(' | '),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.8,
                      color: kChalk,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '部位、动作、日期支持向下填充；空行跳过。'
                    '日期支持多种常见格式。',
                    style: TextStyle(fontSize: 11, height: 1.6, color: kSteel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _StepLabel(index: '03', label: '重复处理'),
            const SizedBox(height: 4),
            for (final mode in ImportMode.values)
              InkWell(
                onTap: _importing ? null : () => setState(() => _mode = mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: kLineSoft)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LedgerCheck(
                        value: _mode == mode,
                        onChanged: _importing
                            ? null
                            : (_) => setState(() => _mode = mode),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: _mode == mode ? kChalk : kSteel,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mode.description,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.55,
                                color: kSteel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 22),
            if (_importing) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
              const Text(
                '正在校验并写入本地数据库，请勿关闭 App…',
                style: TextStyle(fontSize: 11, color: kSteel),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _importing || gyms.isEmpty ? null : _pickAndImport,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('选择 .xlsx 文件并导入'),
            ),
            const SizedBox(height: 14),
            const Text(
              '导入前建议先导出当前数据作为保险。覆盖模式会修改已有记录，无法撤销。'
              '重量解析失败不会崩溃，数值留空、原文保存在“重量原文”，并会列出行号。',
              style: TextStyle(fontSize: 11, height: 1.6, color: kSteel),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.index, required this.label});

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          index,
          style: const TextStyle(
            fontSize: 10,
            color: kSafetyOrange,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: kChalk,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(height: 1, color: kLineSoft)),
      ],
    );
  }
}
