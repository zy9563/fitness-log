import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../data/fitness_store.dart';
import '../../data/theme_store.dart';
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
                Text('v1.6.2', style: Theme.of(context).textTheme.labelSmall),
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
