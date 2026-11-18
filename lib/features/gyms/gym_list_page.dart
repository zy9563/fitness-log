import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/ledger.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            Row(
              children: [
                const LedgerBackButton(),
                const Spacer(),
                TextButton(
                  onPressed: () => _createGym(context),
                  child: const Text('+ 新建'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LedgerPageHeader(
              title: '健身房',
              subtitle: '场馆与动作预设 · ${gyms.length} 家',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: kSafetyOrange, width: 2),
                  top: BorderSide(color: kLineSoft),
                  bottom: BorderSide(color: kLineSoft),
                ),
              ),
              child: Text(
                '删除健身房会同时删除其下的计划和训练记录。删除前先导出 Excel 备份。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kSteel,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (gyms.isEmpty)
              EmptyState(
                title: '还没有健身房',
                message:
                    '先新建一家常去的健身房，再为它添加动作预设。\n'
                    '不同健身房的器械清单互相独立。',
                action: TextButton(
                  onPressed: () => _createGym(context),
                  child: const Text('新建健身房'),
                ),
              )
            else ...[
              const LedgerRule(),
              for (var i = 0; i < gyms.length; i++)
                _GymRow(
                  index: (i + 1).toString().padLeft(2, '0'),
                  gym: gyms[i],
                  presetCount: store.presetCountForGym(gyms[i].id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => GymDetailPage(gymId: gyms[i].id),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GymRow extends StatelessWidget {
  const _GymRow({
    required this.index,
    required this.gym,
    required this.presetCount,
    required this.onTap,
  });

  final String index;
  final Gym gym;
  final int presetCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
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
                    gym.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      color: kChalk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gym.note.trim().isEmpty ? '暂无备注' : gym.note.trim()} · '
                    '$presetCount 个动作',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 10),
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
