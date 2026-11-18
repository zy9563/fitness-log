import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../widgets/app_widgets.dart';
import 'gym_detail_page.dart';
import 'gym_dialogs.dart';

class GymListPage extends StatelessWidget {
  const GymListPage({super.key});

  Future<void> _createGym(BuildContext context) async {
    final result = await showDialog<GymFormResult>(
      context: context,
      builder: (_) => const GymFormDialog(),
    );
    if (result == null || !context.mounted) return;
    try {
      await context.read<FitnessStore>().createGym(
        name: result.name,
        note: result.note,
      );
      if (context.mounted) showInfoSnack(context, '健身房已创建');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final gyms = store.gyms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('健身房与动作预设'),
        actions: [
          IconButton(
            onPressed: () => _createGym(context),
            icon: const Icon(Icons.add),
            tooltip: '新建健身房',
          ),
        ],
      ),
      body: gyms.isEmpty
          ? EmptyState(
              icon: Icons.storefront_outlined,
              title: '还没有健身房',
              message:
                  '先新建一家常去的健身房，再为它添加动作预设。\n'
                  '不同健身房的器械清单互相独立。',
              action: FilledButton.icon(
                onPressed: () => _createGym(context),
                icon: const Icon(Icons.add),
                label: const Text('新建健身房'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                const AppInfoBanner(
                  icon: Icons.info_outline,
                  text:
                      '删除健身房会同时删除其下的计划和训练记录。'
                      '删除前建议先在“导出备份”中保存 Excel。',
                ),
                const SizedBox(height: 12),
                for (final gym in gyms)
                  _GymCard(
                    gym: gym,
                    presetCount: store.presetCountForGym(gym.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => GymDetailPage(gymId: gym.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
      floatingActionButton: gyms.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createGym(context),
              icon: const Icon(Icons.add),
              label: const Text('新建健身房'),
            ),
    );
  }
}

class _GymCard extends StatelessWidget {
  const _GymCard({
    required this.gym,
    required this.presetCount,
    required this.onTap,
  });

  final Gym gym;
  final int presetCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSectionCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.storefront,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          gym.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${gym.note.trim().isEmpty ? '暂无备注' : gym.note.trim()} · '
          '$presetCount 个动作',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        onTap: onTap,
      ),
    );
  }
}
