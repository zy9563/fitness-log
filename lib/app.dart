import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/theme_store.dart';
import 'features/home/home_shell.dart';

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = context.watch<ThemeStore>();
    final settings = themeStore.settings;
    final mode = themeStore.mode;

    ThemeData theme;
    ThemeData? darkTheme;
    ThemeMode materialMode;
    switch (mode) {
      case AppThemeMode.light:
        theme = buildDefaultLightTheme();
        materialMode = ThemeMode.light;
        break;
      case AppThemeMode.system:
        theme = buildDefaultLightTheme();
        darkTheme = buildDefaultDarkTheme();
        materialMode = ThemeMode.system;
        break;
      case AppThemeMode.custom:
        theme = buildCustomTheme(settings);
        materialMode = ThemeMode.light;
        break;
    }

    return MaterialApp(
      title: '健身记录',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: materialMode,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (mode == AppThemeMode.custom) {
          return AppBackground(settings: settings, child: content);
        }
        return content;
      },
      home: const HomeShell(),
    );
  }
}
