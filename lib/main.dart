import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_security.dart';
import 'core/theme.dart';
import 'data/database.dart';
import 'data/fitness_store.dart';
import 'data/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSecurity.verifySignature();

  try {
    await initializeDateFormatting('zh_CN');
    final isar = await AppDatabase.open();
    final store = FitnessStore(isar);
    final themeStore = ThemeStore(isar);
    await store.initialize();
    await themeStore.initialize();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FitnessStore>.value(value: store),
          ChangeNotifierProvider<ThemeStore>.value(value: themeStore),
        ],
        child: const FitnessApp(),
      ),
    );
  } catch (error) {
    runApp(StartupErrorApp(message: error.toString()));
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健身记录',
      debugShowCheckedModeBanner: false,
      theme: buildLedgerTheme(),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOOT / FAILED',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.4,
                    color: kSafetyOrange,
                  ),
                ),
                const SizedBox(height: 14),
                Container(width: 44, height: 2, color: kSafetyOrange),
                const SizedBox(height: 18),
                Text(
                  '本地数据库打开失败',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  '请确认手机存储空间充足，然后重新打开 App。'
                  '如果问题持续，请不要卸载 App，先把手机连接到电脑保留数据。',
                ),
                const SizedBox(height: 18),
                SelectableText(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
