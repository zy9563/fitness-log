import 'package:fitness_log/core/theme.dart';
import 'package:fitness_log/data/models/theme_settings.dart';
import 'package:fitness_log/widgets/app_widgets.dart';
import 'package:fitness_log/widgets/edge_fade_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('图片背景优先：页面文字固定为白色，不受浅色卡片影响', () {
    final settings = ThemeSettings()
      ..useBackgroundImage = true
      ..backgroundImagePath = '/tmp/background.png'
      ..cardColorValue = 0xFFFFFFFF;
    final theme = buildCustomTheme(settings);
    final bodyColor = theme.textTheme.bodyMedium?.color;
    expect(bodyColor, Colors.white);
    expect(theme.scaffoldBackgroundColor, Colors.transparent);
  });

  testWidgets('页面边缘蒙层与卡片共存，且不使用液态玻璃', (tester) async {
    final settings = ThemeSettings()
      ..useBackgroundImage = true
      ..backgroundImagePath = '/tmp/background.png';
    final theme = buildCustomTheme(settings);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: EdgeFadeListView(
            padding: EdgeInsets.zero,
            topFadeHeight: 120,
            bottomFadeHeight: 100,
            children: const [
              AppSectionCard(child: Text('fade card')),
              SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('fade card'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('靠近页面顶部的卡片背景会降低不透明度', (tester) async {
    final theme = buildDefaultLightTheme();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: EdgeFadeListView(
            padding: EdgeInsets.zero,
            children: const [
              AppSectionCard(child: Text('edge card')),
              SizedBox(height: 900),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(AppSectionCard),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color!.a, lessThan(1.0));
  });

  testWidgets('远离边缘的卡片恢复不透明背景', (tester) async {
    final theme = buildDefaultLightTheme();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: EdgeFadeListView(
            padding: const EdgeInsets.only(top: 300),
            children: const [
              AppSectionCard(child: Text('middle card')),
              SizedBox(height: 900),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(AppSectionCard),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color!.a, 1.0);
  });
}
