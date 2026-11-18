import 'package:excel/excel.dart';
import 'package:fitness_log/data/models/exercise_preset.dart';
import 'package:fitness_log/data/models/gym.dart';
import 'package:fitness_log/data/models/training_entry.dart';
import 'package:fitness_log/data/models/training_set.dart';
import 'package:fitness_log/services/excel_service.dart';
import 'package:flutter_test/flutter_test.dart';

String cellText(Data? data) {
  final value = data?.value;
  if (value == null) return '';
  if (value is TextCellValue) return value.value.text ?? '';
  if (value is IntCellValue) return value.value.toString();
  if (value is DoubleCellValue) return value.value.toString();
  if (value is BoolCellValue) return value.value ? '是' : '否';
  if (value is DateCellValue) return value.asDateTimeLocal().toString();
  return value.toString();
}

void main() {
  test('全量备份 4 个 sheet，记录表 9 列与导入表头一致', () {
    final gym = Gym()
      ..id = 1
      ..name = '公司店'
      ..note = '近';
    final preset = ExercisePreset()
      ..id = 1
      ..gymId = 1
      ..name = '史密斯卧推'
      ..group = '胸'
      ..note = '2 号机';
    final entry = TrainingEntry()
      ..id = 1
      ..gymId = 1
      ..date = DateTime(2026, 11, 17)
      ..bodyPart = '胸，三头'
      ..exerciseName = '史密斯卧推'
      ..restText = '90秒'
      ..note = '肩胛收紧'
      ..completed = true;
    final set = TrainingSet()
      ..id = 1
      ..entryId = 1
      ..gymId = 1
      ..date = DateTime(2026, 11, 17)
      ..groupIndex = 2
      ..groupCount = 4
      ..weightValue = 62.5
      ..weightUnitIndex = 1
      ..reps = 10
      ..note = '最后一组力竭';

    final workbook = FitnessExcelService.buildBackupWorkbook(
      gyms: [gym],
      presets: [preset],
      entries: [entry],
      sets: [set],
    );

    expect(workbook.setCount, 1);
    expect(workbook.entryCount, 1);
    final excel = Excel.decodeBytes(workbook.bytes);
    expect(excel.tables.keys, contains(ExcelHeaders.gymSheet));
    expect(excel.tables.keys, contains(ExcelHeaders.presetSheet));
    expect(excel.tables.keys, contains(ExcelHeaders.recordSheet));
    expect(excel.tables.keys, contains(ExcelHeaders.explanationSheet));

    final presetRows = excel.tables[ExcelHeaders.presetSheet]!.rows;
    expect(presetRows.first.map(cellText).toList(), ExcelHeaders.preset);
    expect(presetRows[1].map(cellText).toList(), ['公司店', '史密斯卧推', '胸', '2 号机']);

    final rows = excel.tables[ExcelHeaders.recordSheet]!.rows;
    final header = rows.first.map(cellText).toList();
    expect(header, ExcelHeaders.record);
    final row = rows[1].map(cellText).toList();
    expect(row[0], '胸，三头');
    expect(row[1], '史密斯卧推');
    expect(row[2], '4');
    expect(row[3], '62.5');
    expect(row[4], 'kg');
    expect(row[5], '10');
    expect(row[6], contains('【动作】肩胛收紧'));
    expect(row[6], contains('【组】最后一组力竭'));
    expect(row[7], '90秒');
    expect(row[8], '2026-11-17');

    final preview = FitnessExcelService.previewWorkbook(workbook.bytes);
    expect(preview.backupFormat, isTrue);
    expect(preview.gymRows, 1);
    expect(preview.presetRows, 1);
    expect(preview.groupCount, 1);
    expect(preview.setCount, 1);
    expect(preview.unresolvedRows, isEmpty);
  });

  test('说明页包含记录行号与健身房映射', () {
    final gym = Gym()
      ..id = 1
      ..name = 'A店';
    final entry = TrainingEntry()
      ..id = 1
      ..gymId = 1
      ..date = DateTime(2026, 1, 1)
      ..bodyPart = '腿'
      ..exerciseName = '深蹲';
    final set = TrainingSet()
      ..id = 1
      ..entryId = 1
      ..gymId = 1
      ..date = DateTime(2026, 1, 1)
      ..groupCount = 1
      ..reps = 5;
    final workbook = FitnessExcelService.buildBackupWorkbook(
      gyms: [gym],
      presets: const [],
      entries: [entry],
      sets: [set],
    );
    final excel = Excel.decodeBytes(workbook.bytes);
    final explanation = excel.tables[ExcelHeaders.explanationSheet]!;
    final values = explanation.rows.expand((row) => row.map(cellText)).toList();
    expect(values, contains(ExcelHeaders.mapHeaderRow));
    expect(values, contains('A店'));
  });

  test('备注标记可区分动作备注与组备注', () {
    final text = FitnessExcelService.encodeNote('动作感受', '组感受');
    expect(text, '【动作】动作感受\n【组】组感受');
    expect(ExcelHeaders.record.length, 9);
  });

  test('普通 9 列文件支持向下填充和未识别重量', () {
    final excel = Excel.createExcel();
    final sheet = excel['训练记录'];
    sheet.appendRow(
      ExcelHeaders.record.map<CellValue?>((v) => TextCellValue(v)).toList(),
    );
    sheet.appendRow(<CellValue?>[
      TextCellValue('胸，三头'),
      TextCellValue('卧推'),
      IntCellValue(4),
      TextCellValue('35公斤?'),
      TextCellValue(''),
      IntCellValue(8),
      TextCellValue(''),
      TextCellValue('90秒'),
      TextCellValue('2026/11/17'),
    ]);
    sheet.appendRow(<CellValue?>[
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(3),
      TextCellValue('35'),
      TextCellValue('kg'),
      IntCellValue(10),
      TextCellValue('状态不错'),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
    final bytes = excel.encode()!;

    final preview = FitnessExcelService.previewWorkbook(bytes);
    expect(preview.backupFormat, isFalse);
    expect(preview.groupCount, 1);
    expect(preview.setCount, 2);
    expect(preview.unresolvedRows, contains(2));
    expect(preview.failed, 0);
  });

  test('表头错误会被拒绝', () {
    final excel = Excel.createExcel();
    final sheet = excel['训练记录'];
    sheet.appendRow(<CellValue?>[TextCellValue('日期'), TextCellValue('动作')]);
    final bytes = excel.encode()!;
    expect(
      () => FitnessExcelService.previewWorkbook(bytes),
      throwsA(isA<Exception>()),
    );
  });
}
