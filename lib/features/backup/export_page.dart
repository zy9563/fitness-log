import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/date_x.dart';
import '../../data/fitness_store.dart';
import '../../data/models/backup_record.dart';
import '../../services/excel_service.dart';
import '../../widgets/app_widgets.dart';

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
        return AlertDialog(
          title: const Text('导出成功'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('文件：${result.fileName}'),
                const SizedBox(height: 4),
                Text('大小：${formatFileSize(result.fileSize)}'),
                const SizedBox(height: 4),
                Text(
                  '健身房 ${result.gymCount} · 动作预设 ${result.presetCount} · '
                  '动作 ${result.entryCount} · 组 ${result.setCount}',
                ),
                const SizedBox(height: 10),
                const Text('下载目录：'),
                SelectableText(
                  result.downloadPath.isEmpty
                      ? '未写入下载目录，已保存到 App 目录'
                      : result.downloadPath,
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                if (result.downloadWarning.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    result.downloadWarning,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'App 内副本（分享用）：\n${result.filePath}',
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('关闭'),
            ),
            FilledButton.icon(
              onPressed: () => _shareFile(result.filePath),
              icon: const Icon(Icons.ios_share),
              label: const Text('系统分享'),
            ),
          ],
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
      appBar: AppBar(title: const Text('导出备份')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
        children: [
          AppSectionCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(28),
                      child: Icon(
                        Icons.backup_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '全量备份 · 4 个工作表',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '健身房表、动作预设表、训练记录表、说明页',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _CountBlock(label: '健身房', value: store.gyms.length),
                    _CountBlock(label: '动作预设', value: store.presets.length),
                    _CountBlock(label: '动作', value: store.entries.length),
                    _CountBlock(label: '组', value: store.sets.length),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined),
                    label: Text(_exporting ? '正在生成…' : '导出备份 Excel'),
                  ),
                ),
              ],
            ),
          ),
          const AppInfoBanner(
            icon: Icons.info_outline,
            text:
                '文件会保存一份到手机下载目录，同时保留 App 内副本用于系统分享。'
                '说明页底部包含多健身房的记录归属映射，请勿删除。',
          ),
          SectionTitle('最近导出', subtitle: '删除 App 不会保留这些文件'),
          if (backups.isEmpty)
            const AppSectionCard(child: Text('还没有导出记录。'))
          else
            for (final record in backups)
              AppSectionCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    record.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${formatDateTime(record.exportedAt)} · '
                    '${formatFileSize(record.fileSize)} · '
                    '${record.entryCount} 动作 / ${record.setCount} 组\n'
                    '${record.downloadPath.isEmpty ? '下载目录：未写入' : record.downloadPath}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'share') _shareFile(record.filePath);
                      if (value == 'copy') {
                        _copy(
                          record.downloadPath.isEmpty
                              ? record.filePath
                              : record.downloadPath,
                        );
                      }
                      if (value == 'delete') _deleteRecord(record);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'share', child: Text('系统分享')),
                      PopupMenuItem(value: 'copy', child: Text('复制路径')),
                      PopupMenuItem(value: 'delete', child: Text('删除记录')),
                    ],
                  ),
                  onTap: () => _shareFile(record.filePath),
                ),
              ),
        ],
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
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
