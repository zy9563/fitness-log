import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/backup_record.dart';
import '../../services/excel_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final result = await context.read<FitnessStore>().exportBackup();
      if (!mounted) return;
      await _showResult(result);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareFile(String path) async {
    try {
      await Share.shareXFiles([XFile(path)], text: '健身记录训练数据备份');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _showResult(ExportResult result) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return LedgerDialog(
          eyebrow: 'EXPORT REPORT',
          title: '导出成功',
          subtitle: '全量备份已写入本机',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('关闭'),
            ),
            FilledButton(
              onPressed: () => _shareFile(result.filePath),
              child: const Text('系统分享'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportLine(label: '文件', value: result.fileName),
              _ReportLine(label: '大小', value: formatFileSize(result.fileSize)),
              _ReportLine(
                label: '内容',
                value:
                    '健身房 ${result.gymCount} · 预设 ${result.presetCount} · '
                    '动作 ${result.entryCount} · 组 ${result.setCount}',
              ),
              const SizedBox(height: 12),
              const Text(
                '下载目录',
                style: TextStyle(
                  fontSize: 10,
                  color: kSafetyOrange,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                result.downloadPath.isEmpty
                    ? '未写入下载目录，已保存到 App 目录'
                    : result.downloadPath,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: kSteel,
                ),
              ),
              if (result.downloadWarning.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  result.downloadWarning,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: kDangerRed,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'App 内副本（分享用）',
                style: TextStyle(
                  fontSize: 10,
                  color: kSteel,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                result.filePath,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: kSteel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copy(String value) async {
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) showInfoSnack(context, '路径已复制');
  }

  Future<void> _deleteRecord(BackupRecord record) async {
    final confirmed = await confirmAction(
      context,
      title: '删除导出记录？',
      message: '会同时尝试删除 App 内的备份副本，下载目录中的文件需要你自行处理。',
      confirmText: '删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<FitnessStore>().deleteBackupRecord(record);
      if (mounted) showInfoSnack(context, '记录已删除');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final backups = store.backups;

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
                  'OUT / 导出',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSteel,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const LedgerPageHeader(
              title: '导出备份',
              subtitle: '全量数据 · 一个文件 · 留在本机',
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: kSafetyOrange, width: 1.5),
                  bottom: BorderSide(color: kLine),
                  left: BorderSide(color: kLine),
                  right: BorderSide(color: kLine),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '全量备份',
                    style: TextStyle(
                      fontSize: 26,
                      color: kChalk,
                      fontFamily: kDisplayFont,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '4 个工作表 / 健身房、预设、训练、说明',
                    style: TextStyle(fontSize: 11, color: kSteel),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _CountBlock(label: '健身房', value: store.gyms.length),
                      _CountBlock(label: '动作预设', value: store.presets.length),
                      _CountBlock(label: '动作', value: store.entries.length),
                      _CountBlock(label: '组', value: store.sets.length),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _exporting ? null : _export,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(_exporting ? '正在生成…' : '导出备份 Excel'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '文件会保存一份到手机下载目录，同时保留 App 内副本用于系统分享。'
              '说明页底部包含多健身房的记录归属映射，请勿删除。',
              style: TextStyle(fontSize: 11, height: 1.6, color: kSteel),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Text(
                  '最近导出',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSafetyOrange,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Divider(height: 1, color: kLineSoft)),
                const SizedBox(width: 12),
                Text(
                  '删除 App 后不保留',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: kSteel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (backups.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: kLineSoft),
                    bottom: BorderSide(color: kLineSoft),
                  ),
                ),
                child: const Text(
                  '还没有导出记录。',
                  style: TextStyle(fontSize: 13, color: kSteel),
                ),
              )
            else
              for (final record in backups)
                _BackupRow(
                  record: record,
                  onShare: () => _shareFile(record.filePath),
                  onCopy: () => _copy(
                    record.downloadPath.isEmpty
                        ? record.filePath
                        : record.downloadPath,
                  ),
                  onDelete: () => _deleteRecord(record),
                ),
          ],
        ),
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  const _ReportLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: kSteel,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, height: 1.5, color: kChalk),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.record,
    required this.onShare,
    required this.onCopy,
    required this.onDelete,
  });

  final BackupRecord record;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onShare,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'XLSX',
                style: TextStyle(
                  fontSize: 9,
                  color: kSafetyOrange,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: kChalk),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDateTime(record.exportedAt)} · '
                    '${formatFileSize(record.fileSize)} · '
                    '${record.entryCount} 动作 / ${record.setCount} 组',
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: kSteel,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.downloadPath.isEmpty
                        ? '下载目录：未写入'
                        : record.downloadPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: kSteel.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: '更多',
              icon: const Text(
                '···',
                style: TextStyle(
                  fontSize: 18,
                  color: kSteel,
                  letterSpacing: 0.5,
                ),
              ),
              onSelected: (value) {
                if (value == 'share') onShare();
                if (value == 'copy') onCopy();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'share', child: Text('系统分享')),
                PopupMenuItem(value: 'copy', child: Text('复制路径')),
                PopupMenuItem(value: 'delete', child: Text('删除记录')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBlock extends StatelessWidget {
  const _CountBlock({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 26,
              color: kChalk,
              fontFamily: kDisplayFont,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: kSteel,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
