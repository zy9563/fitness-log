import 'package:fitness_log/core/theme.dart';
import 'package:fitness_log/core/weight.dart';
import 'package:fitness_log/features/training/workout_complete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('训练容量按单位分别累计', () {
    expect(formatWorkoutVolume(const {}), '—');
    expect(formatWorkoutVolume(const {WeightUnit.kg: 1234.5}), '1234.5 kg');
    expect(
      formatWorkoutVolume(const {
        WeightUnit.kg: 1200,
        WeightUnit.piece: 36,
        WeightUnit.lb: 20,
      }),
      '36 片 / 1200 kg / 20 lb',
    );
  });

  testWidgets('训练完成弹窗展示容量、组数和两个按钮', (tester) async {
    WorkoutCompleteAction? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    result = await showWorkoutCompleteDialog(
                      context: context,
                      volumes: const {WeightUnit.kg: 1280},
                      totalGroups: 18,
                    );
                  },
                  child: const Text('打开'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('训练完成'), findsOneWidget);
    expect(find.text('本次容量'), findsOneWidget);
    expect(find.text('1280 kg'), findsOneWidget);
    expect(find.text('完成组数'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('每一次完成，都算数。'), findsOneWidget);

    final stay = find.widgetWithText(TextButton, '留在本页');
    final back = find.widgetWithText(FilledButton, '回到日历');
    expect(stay, findsOneWidget);
    expect(back, findsOneWidget);

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.backgroundColor, kCarbon);
    expect(dialog.elevation, 0);
    final shape = dialog.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.zero);

    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(result, WorkoutCompleteAction.backToCalendar);
  });
}
