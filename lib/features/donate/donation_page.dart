import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/ledger.dart';

/// 赞赏码页。
///
/// 使用开发者提供的原始图片，不把图片内容拆成可替换的远程资源。
class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                LedgerBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 10),
                Text(
                  'SUPPORT / 赞赏',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const LedgerPageHeader(title: '打赏投喂', subtitle: '如果它帮你坚持记录'),
            const SizedBox(height: 18),
            const LedgerRule(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: kSafetyOrange, width: 2),
                  left: BorderSide(color: kLine),
                  right: BorderSide(color: kLine),
                ),
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      'assets/donation_code.jpg',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Text(
                          '赞赏码暂不可用',
                          style: TextStyle(color: kInk),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 1, color: const Color(0xFFE5E1D8)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          'IRON LEDGER',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kInk,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'SUPPORT / 01',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF797469),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '微信扫码 · 金额随意',
              style: theme.textTheme.titleSmall?.copyWith(
                color: kChalk,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '赞赏码由开发者本人提供，仅用于支持独立开发；'
              '不会解锁额外功能，也不会改变你的本地数据。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: kSteel,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
