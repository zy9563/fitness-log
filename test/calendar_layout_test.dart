import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  testWidgets('TableCalendar 可以放在 ListView 中且具有高度', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TableCalendar<String>(
                firstDay: DateTime(2020),
                lastDay: DateTime(2100),
                focusedDay: DateTime(2026, 11, 17),
                eventLoader: (_) => const <String>[],
                onDaySelected: (_, __) {},
              ),
              const SizedBox(height: 20),
              const Text('day details'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(TableCalendar<String>)).height,
      greaterThan(200),
    );
  });
}
