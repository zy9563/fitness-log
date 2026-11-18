import 'package:fitness_log/core/exercise_group.dart';
import 'package:fitness_log/data/models/exercise_preset.dart';
import 'package:fitness_log/features/training/widgets/exercise_preset_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ExercisePreset preset(int id, String name, String group) {
  return ExercisePreset()
    ..id = id
    ..gymId = 1
    ..name = name
    ..group = group;
}

void main() {
  testWidgets('添加动作选择器按分组折叠，支持勾选多个动作', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final chest = [preset(1, '上斜', '胸'), preset(2, '卧推', '胸')];
    final back = [preset(3, '高位下拉', '背')];
    final grouped =
        <String, List<ExercisePreset>>{
            for (final group in kExerciseGroups) group: <ExercisePreset>[],
          }
          ..['胸'] = chest
          ..['背'] = back;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExercisePresetPickerSheet(
            groupedPresets: grouped,
            existingNames: const <String>{},
            bodyPart: '胸',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择动作'), findsOneWidget);
    expect(find.text('上斜'), findsNothing);
    expect(find.text('高位下拉'), findsNothing);

    await tester.tap(
      find.byKey(const PageStorageKey<String>('preset-picker-group-胸')),
    );
    await tester.pumpAndSettle();
    expect(find.text('上斜'), findsOneWidget);
    expect(find.text('卧推'), findsOneWidget);

    await tester.tap(find.text('上斜'));
    await tester.pump();
    await tester.tap(find.text('卧推'));
    await tester.pump();

    expect(find.text('已选择 2 个动作'), findsOneWidget);
    expect(find.text('添加 2 个'), findsOneWidget);
  });

  testWidgets('多选结果按点击顺序返回', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final grouped = <String, List<ExercisePreset>>{
      for (final group in kExerciseGroups) group: <ExercisePreset>[],
    }..['胸'] = [preset(1, '上斜', '胸'), preset(2, '卧推', '胸')];

    PresetPickerResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    result = await showExercisePresetPicker(
                      context: context,
                      groupedPresets: grouped,
                      existingNames: const <String>{},
                      bodyPart: '胸',
                    );
                  },
                  child: const Text('打开选择器'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('打开选择器'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const PageStorageKey<String>('preset-picker-group-胸')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('卧推'));
    await tester.pump();
    await tester.tap(find.text('上斜'));
    await tester.pump();
    await tester.tap(find.text('添加 2 个'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.presets.map((preset) => preset.name).toList(), ['卧推', '上斜']);
  });

  testWidgets('今天已添加的动作会置灰且不可重复勾选', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final grouped = <String, List<ExercisePreset>>{
      for (final group in kExerciseGroups) group: <ExercisePreset>[],
    }..['胸'] = [preset(1, '卧推', '胸')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExercisePresetPickerSheet(
            groupedPresets: grouped,
            existingNames: const <String>{'卧推'},
            bodyPart: '胸',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const PageStorageKey<String>('preset-picker-group-胸')),
    );
    await tester.pumpAndSettle();

    final tile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, '卧推'),
    );
    expect(tile.onChanged, isNull);
    expect(find.text('今天已添加，无需重复勾选'), findsOneWidget);
    expect(find.text('勾选动作后可批量加入今天'), findsOneWidget);
  });
}
