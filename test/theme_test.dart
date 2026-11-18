import 'package:fitness_log/core/theme.dart';
import 'package:fitness_log/widgets/app_widgets.dart';
import 'package:fitness_log/widgets/edge_fade_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v2 只提供暗色铁册主题', () {
    final theme = buildLedgerTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, kInk);
    expect(theme.cardColor, kCarbon);
    expect(theme.colorScheme.primary, kSafetyOrange);
    expect(theme.textTheme.bodyMedium?.color, kChalk);
    expect(theme.textTheme.displaySmall?.fontFamily, kDisplayFont);
  });

  testWidgets('区块使用钢线，不使用圆角、阴影或模糊', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLedgerTheme(),
        home: const Scaffold(
          body: EdgeFadeListView(
            padding: EdgeInsets.zero,
            children: [
              AppSectionCard(child: Text('ledger section')),
              SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ledger section'), findsOneWidget);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(AppSectionCard),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, kCarbon);
    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border, isNotNull);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
