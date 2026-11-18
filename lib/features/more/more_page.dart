import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../services/cache_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';
import '../backup/export_page.dart';
import '../backup/import_page.dart';
import '../gyms/gym_list_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final latestBackup = store.backups.isEmpty ? null : store.backups.first;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
          children: [
            LedgerPageHeader(
              title: '我的',
              subtitle: '本机档案 · 数据不出设备',
              trailing: Text(
                'v2.0.0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kSteel,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _IdentityBlock(gymCount: store.gyms.length),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: kSafetyOrange, width: 2),
                  top: BorderSide(color: kLineSoft),
                  bottom: BorderSide(color: kLineSoft),
                ),
              ),
              child: Text(
                '卸载 App 会清除本机全部数据。换手机、刷机或清理存储前，'
                '先导出 Excel 备份，并把文件转存到手机之外。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kSteel,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('数据', subtitle: '训练、导入与备份'),
            const SizedBox(height: 6),
            const LedgerRule(),
            _LedgerActionRow(
              index: '01',
              title: '健身房与动作预设',
              subtitle:
                  '${store.gyms.length} 个健身房 · ${store.presets.length} 个预设',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const GymListPage()),
                );
              },
            ),
            _LedgerActionRow(
              index: '02',
              title: '导入 Excel',
              subtitle: '9 列记录表或全量备份',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const ImportPage()),
                );
              },
            ),
            _LedgerActionRow(
              index: '03',
              title: '导出备份',
              subtitle: '4 个工作表 · 写入下载目录',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const ExportPage()),
                );
              },
            ),
            _LedgerActionRow(
              index: '04',
              title: '最近导出记录',
              subtitle: latestBackup == null
                  ? '暂无导出记录'
                  : '${latestBackup.fileName}\n${formatDateTime(latestBackup.exportedAt)}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const ExportPage()),
                );
              },
            ),
            const SizedBox(height: 18),
            const _DataMaintenanceCard(),
            const SizedBox(height: 24),
            const SectionTitle('换机迁移', subtitle: '四步搬走全部记录'),
            const SizedBox(height: 6),
            const LedgerRule(),
            const _NumberedNote(number: '01', text: '旧手机：我的 → 导出备份。'),
            const _NumberedNote(number: '02', text: '把 xlsx 通过分享、数据线或网盘传到新手机。'),
            const _NumberedNote(
              number: '03',
              text: '新手机安装 App → 我的 → 导入 Excel。',
            ),
            const _NumberedNote(
              number: '04',
              text: '全量备份会恢复所有健身房；普通 9 列文件只导入所选健身房。',
            ),
            const SizedBox(height: 24),
            const SectionTitle('关于', subtitle: 'IRON LEDGER / 铁册'),
            const SizedBox(height: 6),
            const LedgerRule(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '健身记录',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '完全离线 · 无需账号 · 无网络请求 · 无付费功能',
                    style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '数据存储：Isar 本地数据库\n'
                    '导出格式：.xlsx（4 个工作表）\n'
                    '版本：2.0.0 · build 11',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kSteel,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.gymCount});

  final int gymCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(
          top: BorderSide(color: kSafetyOrange, width: 1.5),
          bottom: BorderSide(color: kLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'IRON LEDGER',
                style: TextStyle(
                  fontSize: 10,
                  color: kSafetyOrange,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'OFFLINE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kSteel,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '健身记录',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 34,
              color: kChalk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '当天练 · 当天记 · $gymCount 家场馆 · 全部留在本机',
            style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
          ),
        ],
      ),
    );
  }
}

class _LedgerActionRow extends StatelessWidget {
  const _LedgerActionRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(
                index,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kSafetyOrange,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      color: kChalk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kSteel,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 20,
                  color: kSteel,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberedNote extends StatelessWidget {
  const _NumberedNote({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLineSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                color: kSafetyOrange,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: kSteel, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataMaintenanceCard extends StatefulWidget {
  const _DataMaintenanceCard();

  @override
  State<_DataMaintenanceCard> createState() => _DataMaintenanceCardState();
}

class _DataMaintenanceCardState extends State<_DataMaintenanceCard> {
  bool _deleting = false;
  bool _clearing = false;

  bool get _busy => _deleting || _clearing;

  DateTimeRange _initialDeleteRange(
    FitnessStore store,
    DateTime firstDate,
    DateTime today,
  ) {
    final oldDates =
        store.entries
            .map((entry) => dateOnly(entry.date))
            .where((date) => date.isBefore(today))
            .toList()
          ..sort();
    final fallbackEnd = today.isAfter(firstDate)
        ? today.subtract(const Duration(days: 1))
        : today;
    final end = oldDates.isEmpty ? fallbackEnd : oldDates.last;
    var start = end.subtract(const Duration(days: 29));
    if (start.isBefore(firstDate)) start = firstDate;
    return DateTimeRange(start: start, end: end);
  }

  Future<void> _deleteHistoryInRange() async {
    final store = context.read<FitnessStore>();
    final today = dateOnly(DateTime.now());
    final firstDate = DateTime(2000, 1, 1);
    if (store.entries.isEmpty) {
      showInfoSnack(context, '还没有训练记录可以删除');
      return;
    }

    final selected = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: today,
      initialDateRange: _initialDeleteRange(store, firstDate, today),
      helpText: '选择要删除的日期范围（含首尾）',
      saveText: '下一步',
      cancelText: '取消',
      fieldStartHintText: '开始日期',
      fieldEndHintText: '结束日期',
    );
    if (selected == null || !mounted) return;

    final start = dateOnly(selected.start);
    final end = dateOnly(selected.end);
    bool inRange(DateTime value) {
      final day = dateOnly(value);
      return !day.isBefore(start) && !day.isAfter(end);
    }

    final targets = store.entries
        .where((entry) => inRange(entry.date))
        .toList();
    if (targets.isEmpty) {
      showInfoSnack(
        context,
        '${formatDate(start)} 至 ${formatDate(end)} 没有训练记录',
      );
      return;
    }
    final entryIds = targets.map((entry) => entry.id).toSet();
    final groups = store.sets
        .where((set) => entryIds.contains(set.entryId))
        .fold<int>(0, (sum, set) => sum + set.groupCount);
    final includesToday = !end.isBefore(today) && !start.isAfter(today);

    final confirmed = await confirmAction(
      context,
      title: '删除所选范围内的计划？',
      message:
          '将永久删除 ${formatDate(start)} 至 ${formatDate(end)} 的 '
          '${targets.length} 个动作、$groups 组训练记录。'
          '${includesToday ? '\n\n注意：所选范围包含今天。' : ''}\n\n'
          '健身房、动作预设和其他日期的记录会保留。'
          '此操作不可撤销，建议先导出备份。',
      confirmText: '永久删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    try {
      final result = await store.deleteEntriesInRange(start, end);
      if (!mounted) return;
      showInfoSnack(
        context,
        '已删除 ${result.entryCount} 个动作、${result.groupCount} 组记录',
      );
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await confirmAction(
      context,
      title: '清理缓存？',
      message:
          '将清理 App 的临时文件和图片缓存。\n\n'
          '不会删除训练记录、Excel 备份、健身房预设或背景图片。',
      confirmText: '清理',
    );
    if (!confirmed || !mounted) return;

    setState(() => _clearing = true);
    try {
      final result = await clearAppCache();
      if (!mounted) return;
      if (result.fileCount == 0) {
        showInfoSnack(context, '缓存已经很干净');
      } else if (result.bytes == 0) {
        showInfoSnack(context, '已清理 ${result.fileCount} 个缓存文件');
      } else {
        showInfoSnack(context, '已清理 ${formatFileSize(result.bytes)} 缓存');
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<FitnessStore>();
    final totalEntries = store.entries.length;
    final totalGroups = store.sets.fold<int>(
      0,
      (sum, set) => sum + set.groupCount,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(
          top: BorderSide(color: kSafetyOrange, width: 1.5),
          bottom: BorderSide(color: kLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '数据维护',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
                ),
              ),
              Text(
                '共 $totalEntries 个动作 · $totalGroups 组',
                style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '按日期范围删除历史计划；健身房、动作预设和其他日期的记录会保留。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: kSteel,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy || totalEntries == 0
                ? null
                : _deleteHistoryInRange,
            style: OutlinedButton.styleFrom(
              foregroundColor: kDangerRed,
              disabledForegroundColor: kSteel.withAlpha(120),
              side: BorderSide(
                color: totalEntries == 0 ? kLine : kDangerRed.withAlpha(120),
              ),
              minimumSize: const Size.fromHeight(42),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              _deleting ? '正在删除...' : '批量删除历史计划',
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _clearCache,
            style: OutlinedButton.styleFrom(
              foregroundColor: kChalk,
              disabledForegroundColor: kSteel.withAlpha(120),
              side: const BorderSide(color: kLine),
              minimumSize: const Size.fromHeight(42),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              _clearing ? '正在清理...' : '清理缓存',
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
