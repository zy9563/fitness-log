import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../data/fitness_store.dart';
import '../../data/theme_store.dart';
import '../../services/cache_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/edge_fade_list_view.dart';
import '../backup/export_page.dart';
import '../backup/import_page.dart';
import '../gyms/gym_list_page.dart';
import '../settings/theme_settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final themeStore = context.watch<ThemeStore>();
    final latestBackup = store.backups.isEmpty ? null : store.backups.first;
    final mode = themeStore.mode;

    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('我的')),
      body: EdgeFadeListView(
        padding: EdgeInsets.fromLTRB(16, topInset, 16, 120),
        topFadeHeight: topInset + 16,
        bottomFadeHeight: 130,
        children: [
          AppSectionCard(
            elevated: true,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '健身记录',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '当天练 · 当天记 · 纯离线',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('v1.6.3', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const AppInfoBanner(
            icon: Icons.warning_amber_rounded,
            text:
                '卸载 App 会清除本机全部数据。换手机、刷机或清理存储前，'
                '请先导出 Excel 备份，并把文件转存到手机之外。',
          ),
          const SizedBox(height: 12),
          SectionTitle('主题'),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主题模式',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text('默认浅色'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.system,
                      label: Text('跟随系统'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.custom,
                      label: Text('自定义'),
                      icon: Icon(Icons.palette_outlined),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (value) {
                    themeStore.setMode(value.first);
                  },
                ),
                const SizedBox(height: 10),
                if (mode == AppThemeMode.custom)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const ThemeSettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('自定义颜色 / 背景图片'),
                    ),
                  )
                else
                  Text(
                    mode == AppThemeMode.light
                        ? '默认浅色：背景 #F7FAFF，卡片白色，主色 #4285F4。'
                        : '跟随系统：系统切换暗色时，全套文字、卡片和背景自动适配。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          SectionTitle('数据'),
          AppSectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('健身房与动作预设'),
                  subtitle: Text(
                    '${store.gyms.length} 个健身房 · ${store.presets.length} 个预设',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const GymListPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('导入 Excel'),
                  subtitle: const Text('先选择健身房，再导入 9 列记录表'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ImportPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('导出备份'),
                  subtitle: const Text('全量多 sheet、下载目录、系统分享'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ExportPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('最近导出记录'),
                  subtitle: Text(
                    latestBackup == null
                        ? '暂无导出记录'
                        : '${latestBackup.fileName} · ${formatDateTime(latestBackup.exportedAt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ExportPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _DataMaintenanceCard(),
          SectionTitle('换机迁移'),
          AppSectionCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. 旧手机：我的 → 导出备份。'),
                SizedBox(height: 3),
                Text('2. 把 xlsx 通过分享、数据线或网盘传到新手机。'),
                SizedBox(height: 3),
                Text('3. 新手机安装 App → 我的 → 导入 Excel。'),
                SizedBox(height: 3),
                Text('4. 全量备份会恢复所有健身房；普通 9 列文件只导入所选健身房。'),
              ],
            ),
          ),
          SectionTitle('关于'),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健身记录',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '完全离线 · 无需账号 · 无网络请求 · 无付费功能',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '数据存储：Isar 本地数据库\n'
                  '导出格式：.xlsx（4 个工作表）\n'
                  '主题与训练记录全部保存在本机',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
    final errorColor = theme.colorScheme.error;

    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '数据维护',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '共 $totalEntries 个动作 · $totalGroups 组',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '按日期范围删除历史计划；健身房、动作预设和其他日期的记录会保留。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 11),
          OutlinedButton.icon(
            onPressed: _busy || totalEntries == 0
                ? null
                : _deleteHistoryInRange,
            style: OutlinedButton.styleFrom(
              foregroundColor: errorColor,
              side: BorderSide(
                color: totalEntries == 0
                    ? theme.colorScheme.outlineVariant
                    : errorColor.withAlpha(100),
              ),
            ),
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_sweep_outlined, size: 19),
            label: Text(_deleting ? '正在删除...' : '批量删除历史计划'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _clearCache,
            icon: _clearing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cleaning_services_outlined, size: 19),
            label: Text(_clearing ? '正在清理...' : '清理缓存'),
          ),
        ],
      ),
    );
  }
}
