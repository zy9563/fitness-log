import 'package:fitness_log/core/date_x.dart';
import 'package:fitness_log/data/models/training_entry.dart';
import 'package:fitness_log/features/history/workout_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('按日期和部位原文分组，日期由近及远', () {
    final entries = [
      TrainingEntry()
        ..id = 1
        ..gymId = 2
        ..date = DateTime(2026, 11, 18, 9)
        ..bodyPart = '胸'
        ..exerciseName = '卧推'
        ..sortOrder = 0,
      TrainingEntry()
        ..id = 2
        ..gymId = 2
        ..date = DateTime(2026, 11, 19, 8)
        ..bodyPart = '胸，三头'
        ..exerciseName = '上斜'
        ..sortOrder = 0,
      TrainingEntry()
        ..id = 3
        ..gymId = 1
        ..date = DateTime(2026, 11, 18, 21)
        ..bodyPart = '胸'
        ..exerciseName = '俯卧撑'
        ..sortOrder = 2,
      TrainingEntry()
        ..id = 4
        ..gymId = 1
        ..date = DateTime(2026, 11, 18, 7)
        ..bodyPart = '胸'
        ..exerciseName = '飞鸟'
        ..sortOrder = 1,
    ];

    final groups = groupWorkoutEntries(entries);

    expect(groups, hasLength(2));
    expect(groups.first.date, dateOnly(DateTime(2026, 11, 19)));
    expect(groups.first.bodyPart, '胸，三头');
    expect(groups.last.date, dateOnly(DateTime(2026, 11, 18)));
    expect(groups.last.entries.map((entry) => entry.id), [4, 3, 1]);
    expect(groups.last.bodyPart, '胸');
  });

  test('同一天同部位不同健身房也归入同一组', () {
    final entries = [
      TrainingEntry()
        ..id = 1
        ..gymId = 1
        ..date = DateTime(2026, 11, 18)
        ..bodyPart = '背'
        ..exerciseName = '下拉',
      TrainingEntry()
        ..id = 2
        ..gymId = 2
        ..date = DateTime(2026, 11, 18)
        ..bodyPart = '背'
        ..exerciseName = '划船',
    ];

    final groups = groupWorkoutEntries(entries);

    expect(groups, hasLength(1));
    expect(groups.single.entries, hasLength(2));
  });
}
