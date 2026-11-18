import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme.dart';
import 'data/database.dart';
import 'data/fitness_store.dart';
import 'data/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: buildDefaultLightTheme(),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 54,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '本地数据库打开失败',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  '请确认手机存储空间充足，然后重新打开 App。'
                  '如果问题持续，请不要卸载 App，先把手机连接到电脑保留数据。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  message,
                  textAlign: TextAlign.center,
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
