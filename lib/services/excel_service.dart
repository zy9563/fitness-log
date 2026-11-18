import 'dart:io';
import 'dart:math' as math;

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/app_exception.dart';
import '../core/date_x.dart';
import '../core/exercise_group.dart';
import '../core/weight.dart';
import '../data/models/backup_record.dart';
import '../data/models/exercise_preset.dart';
import '../data/models/gym.dart';
import '../data/models/training_entry.dart';
import '../data/models/training_set.dart';

class ExcelHeaders {
  ExcelHeaders._();

  static const List<String> record = <String>[
    '部位',
    '动作',
    '组数',
    '重量',
    '单位',
    '次数',
    '备注',
    '组间歇',
    '日期',
  ];

  static const List<String> gym = <String>['健身房名称', '备注'];
  static const List<String> preset = <String>['健身房名称', '动作名称', '分组', '备注'];

  /// 旧版全量备份的动作预设表，没有“分组”列。
  static const List<String> legacyPreset = <String>['健身房名称', '动作名称', '备注'];

  static const String gymSheet = '健身房表';
  static const String presetSheet = '动作预设表';
  static const String recordSheet = '训练记录表';
  static const String explanationSheet = '说明页';

  static const String mapHeaderRow = '记录行号';
  static const String mapHeaderGym = '健身房名称';
}

enum ImportMode { skipDuplicate, overwrite }

extension ImportModeText on ImportMode {
  String get label => this == ImportMode.skipDuplicate ? '跳过重复（默认）' : '覆盖重复';

  String get description => this == ImportMode.skipDuplicate
      ? '同日期 + 同健身房 + 同部位 + 同动作 + 同组别序号已存在时，保留原记录。'
      : '同日期 + 同健身房 + 同部位 + 同动作 + 同组别序号已存在时，用文件内容覆盖。';
}

class ExportResult {
  const ExportResult({
    required this.filePath,
    required this.downloadPath,
    required this.fileName,
    required this.fileSize,
    required this.gymCount,
    required this.presetCount,
    required this.entryCount,
    required this.setCount,
    required this.exportedAt,
    this.downloadWarning = '',
  });

  final String filePath;
  final String downloadPath;
  final String fileName;
  final int fileSize;
  final int gymCount;
  final int presetCount;
  final int entryCount;
  final int setCount;
  final DateTime exportedAt;
  final String downloadWarning;
}

class ImportResult {
  const ImportResult({
    required this.backupFormat,
    required this.success,
    required this.skipped,
    required this.failed,
    required this.entriesCreated,
    required this.setsCreated,
    required this.presetsCreated,
    required this.gymsCreated,
    required this.unresolvedRows,
    required this.errors,
    required this.warnings,
  });

  final bool backupFormat;
  final int success;
  final int skipped;
  final int failed;
  final int entriesCreated;
  final int setsCreated;
  final int presetsCreated;
  final int gymsCreated;
  final List<int> unresolvedRows;
  final List<String> errors;
  final List<String> warnings;
}

class WorkbookPreview {
  const WorkbookPreview({
    required this.backupFormat,
    required this.gymRows,
    required this.presetRows,
    required this.groupCount,
    required this.setCount,
    required this.unresolvedRows,
    required this.failed,
  });

  final bool backupFormat;
  final int gymRows;
  final int presetRows;
  final int groupCount;
  final int setCount;
  final List<int> unresolvedRows;
  final int failed;
}

class BackupWorkbook {
  const BackupWorkbook({
    required this.bytes,
    required this.gymCount,
    required this.presetCount,
    required this.entryCount,
    required this.setCount,
  });

  final List<int> bytes;
  final int gymCount;
  final int presetCount;
  final int entryCount;
  final int setCount;
}

class FitnessExcelService {
  FitnessExcelService._();

  static const MethodChannel _fileChannel = MethodChannel(
    'com.example.fitness_log/files',
  );

  // ---------------------------------------------------------------------------
  // 导出
  // ---------------------------------------------------------------------------

  static Future<ExportResult> exportBackup({required Isar isar}) async {
    final gyms = await isar.gyms.where().findAll();
    final presets = await isar.exercisePresets.where().findAll();
    final entries = await isar.trainingEntrys.where().findAll();
    final sets = await isar.trainingSets.where().findAll();
    final workbook = buildBackupWorkbook(
      gyms: gyms,
      presets: presets,
      entries: entries,
      sets: sets,
    );
    final bytes = workbook.bytes;
    final now = DateTime.now();
    final stamp =
        '${formatDate(now).replaceAll('-', '')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final fileName = '健身记录_备份_$stamp.xlsx';

    final docs = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docs.path, 'backups'));
    if (!await backupDir.exists()) await backupDir.create(recursive: true);
    final appFile = File(p.join(backupDir.path, fileName));
    await appFile.writeAsBytes(bytes, flush: true);
    final size = await appFile.length();

    var downloadPath = '';
    var warning = '';
    try {
      final result = await _fileChannel.invokeMethod<String>(
        'saveToDownloads',
        <String, dynamic>{
          'bytes': Uint8List.fromList(bytes),
          'fileName': fileName,
        },
      );
      downloadPath = result ?? '';
    } on PlatformException catch (error) {
      if (error.code == 'PERMISSION_DENIED') {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          try {
            downloadPath =
                await _fileChannel.invokeMethod<String>(
                  'saveToDownloads',
                  <String, dynamic>{
                    'bytes': Uint8List.fromList(bytes),
                    'fileName': fileName,
                  },
                ) ??
                '';
          } on PlatformException catch (retryError) {
            warning = '写入下载目录失败：${retryError.message ?? retryError.code}';
          }
        } else {
          warning = '没有存储权限，已保存到 App 目录；可点“分享”转存。';
        }
      } else {
        warning = '写入下载目录失败：${error.message ?? error.code}';
      }
    } catch (error) {
      warning = '写入下载目录失败：$error';
    }

    await isar.writeTxn(() async {
      final record = BackupRecord()
        ..fileName = fileName
        ..filePath = appFile.path
        ..downloadPath = downloadPath
        ..exportedAt = now
        ..gymCount = workbook.gymCount
        ..presetCount = workbook.presetCount
        ..entryCount = workbook.entryCount
        ..setCount = workbook.setCount
        ..fileSize = size;
      await isar.backupRecords.put(record);
    });

    return ExportResult(
      filePath: appFile.path,
      downloadPath: downloadPath,
      fileName: fileName,
      fileSize: size,
      gymCount: workbook.gymCount,
      presetCount: workbook.presetCount,
      entryCount: workbook.entryCount,
      setCount: workbook.setCount,
      exportedAt: now,
      downloadWarning: warning,
    );
  }

  /// 纯函数构建工作簿，便于测试。
  static BackupWorkbook buildBackupWorkbook({
    required List<Gym> gyms,
    required List<ExercisePreset> presets,
    required List<TrainingEntry> entries,
    required List<TrainingSet> sets,
  }) {
    final sortedGyms = List<Gym>.from(gyms)
      ..sort((a, b) => a.name.compareTo(b.name));
    final gymById = <int, Gym>{for (final gym in sortedGyms) gym.id: gym};
    final sortedPresets = List<ExercisePreset>.from(presets)
      ..sort((a, b) {
        final gymCompare = a.gymId.compareTo(b.gymId);
        if (gymCompare != 0) return gymCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final sortedEntries = List<TrainingEntry>.from(entries)
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        final gymCompare = a.gymId.compareTo(b.gymId);
        if (gymCompare != 0) return gymCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final setsByEntry = <int, List<TrainingSet>>{};
    for (final set in sets) {
      setsByEntry.putIfAbsent(set.entryId, () => <TrainingSet>[]).add(set);
    }
    for (final value in setsByEntry.values) {
      value.sort((a, b) => a.groupIndex.compareTo(b.groupIndex));
    }

    final excel = Excel.createExcel();
    final gymSheet = excel[ExcelHeaders.gymSheet];
    _appendHeaderRow(gymSheet, ExcelHeaders.gym);
    for (final gym in sortedGyms) {
      _appendRow(gymSheet, [TextCellValue(gym.name), TextCellValue(gym.note)]);
    }

    final presetSheet = excel[ExcelHeaders.presetSheet];
    _appendHeaderRow(presetSheet, ExcelHeaders.preset);
    for (final preset in sortedPresets) {
      final gym = gymById[preset.gymId];
      if (gym == null) continue;
      _appendRow(presetSheet, [
        TextCellValue(gym.name),
        TextCellValue(preset.name),
        TextCellValue(resolveExerciseGroup(preset.group, preset.name)),
        TextCellValue(preset.note),
      ]);
    }

    final recordSheet = excel[ExcelHeaders.recordSheet];
    _appendHeaderRow(recordSheet, ExcelHeaders.record);
    final mapRows = <List<String>>[];
    var entryCount = 0;
    var setCount = 0;
    var recordRowNumber = 2;
    for (final entry in sortedEntries) {
      final gym = gymById[entry.gymId];
      final entrySets = setsByEntry[entry.id] ?? const <TrainingSet>[];
      if (gym == null || entrySets.isEmpty) continue;
      entryCount++;
      for (final set in entrySets) {
        setCount++;
        final unit = WeightUnit.fromIndex(set.weightUnitIndex);
        final unresolved = set.weightValue == null && set.weightRaw.isNotEmpty;
        _appendRow(recordSheet, [
          TextCellValue(entry.bodyPart),
          TextCellValue(entry.exerciseName),
          IntCellValue(set.groupCount),
          TextCellValue(
            unresolved
                ? set.weightRaw
                : (set.weightValue == null
                      ? ''
                      : formatWeight(set.weightValue)),
          ),
          TextCellValue(
            (set.weightValue == null && set.weightRaw.isEmpty)
                ? ''
                : (unit?.label ?? ''),
          ),
          IntCellValue(set.reps),
          TextCellValue(encodeNote(entry.note, set.note)),
          TextCellValue(entry.restText),
          TextCellValue(formatDate(entry.date)),
        ]);
        mapRows.add(['${recordRowNumber++}', gym.name]);
      }
    }

    final explainSheet = excel[ExcelHeaders.explanationSheet];
    final explainRows = <List<String>>[
      ['健身记录 Excel 全量备份说明'],
      ['1. 训练记录表 9 列表头与导入模板完全一致，可直接再次导入恢复。'],
      ['2. 记录表每一行代表一个动作下的一行组；同日期、同健身房、同部位、同动作、同组别序号为去重键。'],
      ['3. 重量单位只能为 片 / kg / lb；无法识别的重量保留在“重量”原文中，不参与统计。'],
      ['4. 备注列使用【动作】/【组】标记分别保存动作备注与组备注，导入时会自动拆开。'],
      ['5. 本页底部的记录归属表用于多健身房全量恢复，请勿删除。'],
      ['6. 动作预设表按“胸 / 背 / 肩 / 手臂 / 臀腿 / 核心”分组，旧版无分组列的备份也可导入。'],
      [''],
      [ExcelHeaders.mapHeaderRow, ExcelHeaders.mapHeaderGym],
      ...mapRows,
    ];
    for (final row in explainRows) {
      _appendRow(
        explainSheet,
        row.map<CellValue?>((value) => TextCellValue(value)).toList(),
      );
    }

    _styleSheet(gymSheet, ExcelHeaders.gym.length);
    _styleSheet(presetSheet, ExcelHeaders.preset.length);
    _styleSheet(recordSheet, ExcelHeaders.record.length);
    explainSheet.setColumnWidth(0, 32);
    explainSheet.setColumnWidth(1, 32);

    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
    final bytes = excel.encode();
    if (bytes == null || bytes.isEmpty) {
      throw AppException('生成 Excel 文件失败，请重试');
    }
    return BackupWorkbook(
      bytes: bytes,
      gymCount: sortedGyms.length,
      presetCount: sortedPresets.length,
      entryCount: entryCount,
      setCount: setCount,
    );
  }

  static String encodeNote(String entryNote, String setNote) {
    final parts = <String>[];
    if (entryNote.trim().isNotEmpty) parts.add('【动作】${entryNote.trim()}');
    if (setNote.trim().isNotEmpty) parts.add('【组】${setNote.trim()}');
    return parts.join('\n');
  }

  // ---------------------------------------------------------------------------
  // 导入
  // ---------------------------------------------------------------------------

  /// 只解析、不写库，用于校验与测试。
  static WorkbookPreview previewWorkbook(List<int> bytes) {
    final parsed = _parseWorkbook(bytes: bytes);
    return WorkbookPreview(
      backupFormat: parsed.backupFormat,
      gymRows: parsed.gymRows.length,
      presetRows: parsed.presetRows.length,
      groupCount: parsed.groups.length,
      setCount: parsed.groups.fold<int>(
        0,
        (sum, group) => sum + group.sets.length,
      ),
      unresolvedRows: List<int>.unmodifiable(parsed.unresolvedRows),
      failed: parsed.failed,
    );
  }

  static Future<ImportResult> importWorkbook({
    required Isar isar,
    required int gymId,
    required List<int> bytes,
    required ImportMode mode,
  }) async {
    final parsed = _parseWorkbook(bytes: bytes);
    final accumulator = _ImportAccumulator(parsed);
    final now = DateTime.now();

    await isar.writeTxn(() async {
      final allGyms = await isar.gyms.where().findAll();
      final allPresets = await isar.exercisePresets.where().findAll();
      final allEntries = await isar.trainingEntrys.where().findAll();
      final allSets = await isar.trainingSets.where().findAll();
      final gymByName = <String, Gym>{
        for (final gym in allGyms) normalizeLookupName(gym.name): gym,
      };
      final presetByKey = <String, ExercisePreset>{
        for (final preset in allPresets)
          _presetKey(preset.gymId, preset.name): preset,
      };
      final gymNameById = <int, String>{
        for (final gym in allGyms) gym.id: gym.name,
      };
      final entryByKey = <String, TrainingEntry>{};
      for (final entry in allEntries) {
        final gymName = gymNameById[entry.gymId];
        if (gymName == null) continue;
        entryByKey[_entryKey(
              entry.date,
              gymName,
              entry.bodyPart,
              entry.exerciseName,
            )] =
            entry;
      }
      final setsByEntry = <int, List<TrainingSet>>{};
      for (final set in allSets) {
        setsByEntry.putIfAbsent(set.entryId, () => <TrainingSet>[]).add(set);
      }
      for (final value in setsByEntry.values) {
        value.sort((a, b) => a.groupIndex.compareTo(b.groupIndex));
      }
      final entryCountByDateGym = <String, int>{};
      for (final entry in allEntries) {
        final key = '${formatDate(entry.date)}|${entry.gymId}';
        final current = entryCountByDateGym[key] ?? 0;
        if (entry.sortOrder + 1 > current) {
          entryCountByDateGym[key] = entry.sortOrder + 1;
        }
      }

      Future<Gym> ensureGym(String name, {String note = ''}) async {
        final key = normalizeLookupName(name);
        final existing = gymByName[key];
        if (existing != null) {
          if (mode == ImportMode.overwrite && note.trim().isNotEmpty) {
            existing
              ..note = note.trim()
              ..updatedAt = now;
            await isar.gyms.put(existing);
          }
          return existing;
        }
        final gym = Gym()
          ..name = name.trim()
          ..note = note.trim()
          ..createdAt = now
          ..updatedAt = now;
        await isar.gyms.put(gym);
        gymByName[key] = gym;
        accumulator.gymsCreated++;
        return gym;
      }

      Future<ExercisePreset> ensurePreset(
        Gym gym,
        String actionName, {
        String group = '',
        String note = '',
      }) async {
        final key = _presetKey(gym.id, actionName);
        final existing = presetByKey[key];
        final resolvedGroup =
            normalizeExerciseGroup(group) ??
            (group.trim().isEmpty
                ? null
                : resolveExerciseGroup(group, actionName));
        if (existing != null) {
          var changed = false;
          if ((mode == ImportMode.overwrite || existing.group.trim().isEmpty) &&
              note.trim().isNotEmpty) {
            existing.note = note.trim();
            changed = true;
          }
          final currentGroup = normalizeExerciseGroup(existing.group);
          if (currentGroup == null) {
            existing.group = resolvedGroup ?? inferExerciseGroup(actionName);
            changed = true;
          } else if (mode == ImportMode.overwrite &&
              resolvedGroup != null &&
              currentGroup != resolvedGroup) {
            existing.group = resolvedGroup;
            changed = true;
          }
          if (changed) {
            existing.updatedAt = now;
            await isar.exercisePresets.put(existing);
          }
          return existing;
        }
        final gymPresets = presetByKey.values
            .where((preset) => preset.gymId == gym.id)
            .toList();
        final order = gymPresets.isEmpty
            ? 0
            : gymPresets
                      .map((preset) => preset.sortOrder)
                      .reduce((a, b) => a > b ? a : b) +
                  1;
        final preset = ExercisePreset()
          ..gymId = gym.id
          ..name = actionName.trim()
          ..group = resolvedGroup ?? inferExerciseGroup(actionName)
          ..note = note.trim()
          ..sortOrder = order
          ..createdAt = now
          ..updatedAt = now;
        await isar.exercisePresets.put(preset);
        presetByKey[key] = preset;
        accumulator.presetsCreated++;
        return preset;
      }

      // 全量备份先恢复健身房和动作预设。
      if (parsed.backupFormat) {
        for (final row in parsed.gymRows) {
          await ensureGym(row.name, note: row.note);
        }
        for (final row in parsed.presetRows) {
          final gym = await ensureGym(row.gymName);
          await ensurePreset(gym, row.name, group: row.group, note: row.note);
        }
      }

      for (final group in parsed.groups) {
        Gym? gym;
        if (parsed.backupFormat) {
          gym = await ensureGym(group.gymName);
        } else {
          for (final item in allGyms) {
            if (item.id == gymId) {
              gym = item;
              break;
            }
          }
          if (gym == null) {
            throw AppException('所选健身房不存在，请重新选择');
          }
        }
        await ensurePreset(gym, group.exerciseName);
        final entryKey = _entryKey(
          group.date,
          gym.name,
          group.bodyPart,
          group.exerciseName,
        );
        var entry = entryByKey[entryKey];
        if (entry == null) {
          final orderKey = '${formatDate(group.date)}|${gym.id}';
          final order = entryCountByDateGym[orderKey] ?? 0;
          entry = TrainingEntry()
            ..gymId = gym.id
            ..date = group.date
            ..bodyPart = group.bodyPart
            ..exerciseName = group.exerciseName
            ..restText = group.restText
            ..note = group.entryNote
            ..completed = true
            ..sortOrder = order
            ..createdAt = now
            ..updatedAt = now;
          await isar.trainingEntrys.put(entry);
          entryByKey[entryKey] = entry;
          entryCountByDateGym[orderKey] = order + 1;
          accumulator.entriesCreated++;
        } else {
          if (mode == ImportMode.overwrite) {
            if (group.restText.trim().isNotEmpty) {
              entry.restText = group.restText;
            }
            if (group.entryNote.trim().isNotEmpty) {
              entry.note = group.entryNote;
            }
          }
          entry
            ..completed = true
            ..updatedAt = now;
          await isar.trainingEntrys.put(entry);
        }

        final existingSets = setsByEntry[entry.id] ?? <TrainingSet>[];
        final existingByIndex = <int, TrainingSet>{
          for (final set in existingSets) set.groupIndex: set,
        };

        for (final row in group.sets) {
          final existing = existingByIndex[row.groupIndex];
          if (existing != null && mode == ImportMode.skipDuplicate) {
            accumulator.skipped++;
            continue;
          }
          if (existing != null) {
            existing
              ..groupCount = row.groupCount
              ..weightValue = row.weightValue
              ..weightUnitIndex = row.weightUnitIndex
              ..weightRaw = row.weightRaw
              ..reps = row.reps
              ..note = row.setNote
              ..updatedAt = now;
            await isar.trainingSets.put(existing);
          } else {
            final set = TrainingSet()
              ..entryId = entry.id
              ..gymId = gym.id
              ..date = group.date
              ..groupIndex = row.groupIndex
              ..groupCount = row.groupCount
              ..weightValue = row.weightValue
              ..weightUnitIndex = row.weightUnitIndex
              ..weightRaw = row.weightRaw
              ..reps = row.reps
              ..note = row.setNote
              ..createdAt = now
              ..updatedAt = now;
            await isar.trainingSets.put(set);
            existingByIndex[row.groupIndex] = set;
            accumulator.setsCreated++;
          }
          accumulator.success++;
        }
      }
    });

    return accumulator.toResult();
  }

  static _ParsedWorkbook _parseWorkbook({required List<int> bytes}) {
    Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (error) {
      throw ImportFormatException('无法读取 Excel 文件，请确认文件是有效的 .xlsx：$error');
    }
    final sheets = <String, Sheet>{
      for (final entry in excel.tables.entries) entry.key.trim(): entry.value,
    };
    final backupFormat =
        sheets.containsKey(ExcelHeaders.gymSheet) &&
        sheets.containsKey(ExcelHeaders.presetSheet) &&
        sheets.containsKey(ExcelHeaders.recordSheet);
    final recordSheet = backupFormat
        ? sheets[ExcelHeaders.recordSheet]!
        : _findSheetWithRecordHeader(sheets.values);
    if (recordSheet == null) {
      throw ImportFormatException(
        '未找到训练记录表。需要固定表头：${ExcelHeaders.record.join(' | ')}',
      );
    }
    final header = _requireHeader(recordSheet);
    final gymRows = <_GymRow>[];
    final presetRows = <_PresetRow>[];
    if (backupFormat) {
      final gymSheet = sheets[ExcelHeaders.gymSheet]!;
      final gymHeader = _findHeader(
        gymSheet,
        ExcelHeaders.gym,
        (actual, expected, index) => actual == expected,
      );
      if (gymHeader == null) {
        throw ImportFormatException('健身房表表头不符，需要：健身房名称 | 备注');
      }
      _parseGymRows(gymSheet, gymHeader, gymRows);
      final presetSheet = sheets[ExcelHeaders.presetSheet]!;
      final presetHeader = _findPresetHeader(presetSheet);
      if (presetHeader == null) {
        throw ImportFormatException(
          '动作预设表表头不符，需要：健身房名称 | 动作名称 | 分组 | 备注\n'
          '旧版“健身房名称 | 动作名称 | 备注”也兼容导入。',
        );
      }
      _parsePresetRows(presetSheet, presetHeader, presetRows);
    }

    final gymMap = _parseRecordGymMap(sheets[ExcelHeaders.explanationSheet]);
    final result = _ParsedWorkbook(backupFormat: backupFormat);
    result.gymRows.addAll(gymRows);
    result.presetRows.addAll(presetRows);
    String? lastBodyPart;
    String? lastExercise;
    DateTime? lastDate;
    final groups = <String, _ImportedGroup>{};

    for (var index = header.row + 1; index < recordSheet.rows.length; index++) {
      final row = recordSheet.rows[index];
      if (_isBlankRow(row)) continue;
      final sourceRow = index + 1;
      final rawBodyPart = _cellText(_cell(row, 0)).trim();
      final rawExercise = _cellText(_cell(row, 1)).trim();
      final rawDate = _cellText(_cell(row, 8)).trim();
      if (rawBodyPart.isNotEmpty) lastBodyPart = rawBodyPart;
      if (rawExercise.isNotEmpty) lastExercise = rawExercise;
      final parsedDate = _parseDate(_cell(row, 8));
      if (rawDate.isNotEmpty && parsedDate == null) {
        result.failed++;
        result.addError('第 $sourceRow 行：日期“$rawDate”无法识别。');
        continue;
      }
      if (parsedDate != null) lastDate = parsedDate;

      final bodyPart = rawBodyPart.isEmpty ? (lastBodyPart ?? '') : rawBodyPart;
      final exercise = rawExercise.isEmpty ? (lastExercise ?? '') : rawExercise;
      final date = parsedDate ?? lastDate;
      if (bodyPart.isEmpty || exercise.isEmpty || date == null) {
        result.failed++;
        result.addError('第 $sourceRow 行：部位、动作、日期无法补齐。');
        continue;
      }

      final groupText = _cellText(_cell(row, 2)).trim();
      final repsText = _cellText(_cell(row, 5)).trim();
      final groupCount = _parseInt(groupText);
      final reps = _parseInt(repsText);
      if (groupCount == null || groupCount < 1 || reps == null || reps < 1) {
        result.failed++;
        result.addError('第 $sourceRow 行：组数和次数必须是大于 0 的整数。');
        continue;
      }

      final weightParse = _parseWeight(
        weightText: _cellText(_cell(row, 3)).trim(),
        unitText: _cellText(_cell(row, 4)).trim(),
      );
      final noteText = _cellText(_cell(row, 6));
      final notes = _splitNote(noteText);
      final restText = _cellText(_cell(row, 7)).trim();
      final gymName = backupFormat ? (gymMap[sourceRow] ?? '') : '';
      if (backupFormat && gymName.isEmpty) {
        result.failed++;
        result.addError('第 $sourceRow 行：说明页缺少该行的健身房归属。');
        continue;
      }
      final effectiveGym = backupFormat ? gymName : '';
      final key =
          '${formatDate(date)}|${normalizeLookupName(effectiveGym)}|'
          '${normalizeLookupName(bodyPart)}|${normalizeLookupName(exercise)}';
      final group = groups.putIfAbsent(
        key,
        () => _ImportedGroup(
          date: date,
          gymName: effectiveGym,
          bodyPart: bodyPart,
          exerciseName: exercise,
          entryNote: notes.entryNote,
          restText: restText,
        ),
      );
      if (group.entryNote.isEmpty && notes.entryNote.isNotEmpty) {
        group.entryNote = notes.entryNote;
      }
      if (group.restText.isEmpty && restText.isNotEmpty) {
        group.restText = restText;
      }
      group.sets.add(
        _ImportedSet(
          sourceRow: sourceRow,
          groupIndex: group.sets.length + 1,
          groupCount: groupCount,
          weightValue: weightParse.value,
          weightUnitIndex: weightParse.unit?.index,
          weightRaw: weightParse.raw,
          reps: reps,
          setNote: notes.setNote,
          unresolved: weightParse.unresolved,
        ),
      );
      if (weightParse.unresolved) {
        result.unresolvedRows.add(sourceRow);
      }
    }
    result.groups = groups.values.toList();
    return result;
  }

  static _NoteParts _splitNote(String text) {
    final value = text.trim();
    if (!value.contains('【动作】') && !value.contains('【组】')) {
      return _NoteParts(entryNote: '', setNote: value);
    }
    final entryMatch = RegExp(r'【动作】([\s\S]*?)(?=\n【组】|$)').firstMatch(value);
    final setMatch = RegExp(r'【组】([\s\S]*)').firstMatch(value);
    return _NoteParts(
      entryNote: entryMatch?.group(1)?.trim() ?? '',
      setNote: setMatch?.group(1)?.trim() ?? '',
    );
  }

  static _WeightParse _parseWeight({
    required String weightText,
    required String unitText,
  }) {
    final raw = weightText.trim();
    final explicitUnit = WeightUnit.fromText(unitText);
    if (raw.isEmpty) {
      if (unitText.trim().isEmpty) {
        return const _WeightParse(value: null, unit: null, raw: '');
      }
      return _WeightParse(
        value: null,
        unit: explicitUnit,
        raw: raw,
        unresolved: true,
      );
    }

    final composite = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(片|kg|公斤|千克|lb|lbs|磅)$',
      caseSensitive: false,
    ).firstMatch(raw);
    if (composite != null) {
      final value = double.parse(composite.group(1)!);
      final textUnit = WeightUnit.fromText(composite.group(2)!);
      if (explicitUnit != null &&
          textUnit != null &&
          explicitUnit != textUnit) {
        return _WeightParse(
          value: null,
          unit: explicitUnit,
          raw: raw,
          unresolved: true,
        );
      }
      return _WeightParse(
        value: value,
        unit: explicitUnit ?? textUnit,
        raw: '',
      );
    }

    final numericOnly = double.tryParse(raw);
    if (numericOnly != null && explicitUnit != null) {
      return _WeightParse(value: numericOnly, unit: explicitUnit, raw: '');
    }

    return _WeightParse(
      value: null,
      unit: explicitUnit,
      raw: raw,
      unresolved: true,
    );
  }

  static String _entryKey(
    DateTime date,
    String gymName,
    String bodyPart,
    String exerciseName,
  ) =>
      '${formatDate(date)}|${normalizeLookupName(gymName)}|'
      '${normalizeLookupName(bodyPart)}|${normalizeLookupName(exerciseName)}';

  static String _presetKey(int gymId, String name) =>
      '$gymId|${normalizeLookupName(name)}';

  // ---------------------------------------------------------------------------
  // Excel 解析工具
  // ---------------------------------------------------------------------------

  static _HeaderLocation _requireHeader(Sheet sheet) {
    final header = _findHeader(
      sheet,
      ExcelHeaders.record,
      _recordHeaderMatcher,
    );
    if (header == null) {
      final actual = sheet.rows.isEmpty
          ? <String>[]
          : sheet.rows.first
                .map((cell) => _cellText(cell).trim())
                .where((value) => value.isNotEmpty)
                .toList();
      throw ImportFormatException(
        '训练记录表表头不符。\n需要：${ExcelHeaders.record.join(' | ')}\n'
        '实际：${actual.isEmpty ? '（空表）' : actual.join(' | ')}',
      );
    }
    return header;
  }

  static _HeaderLocation? _findHeader(
    Sheet sheet,
    List<String> expected,
    bool Function(String actual, String expected, int index) matcher,
  ) {
    final limit = math.min(sheet.rows.length, 20);
    for (var row = 0; row < limit; row++) {
      final values = sheet.rows[row];
      if (values.length < expected.length) continue;
      var matched = true;
      for (var col = 0; col < expected.length; col++) {
        final actual = _normalizeHeader(_cellText(values[col]));
        if (!matcher(actual, expected[col], col)) {
          matched = false;
          break;
        }
      }
      if (matched) return _HeaderLocation(sheet: sheet, row: row);
    }
    return null;
  }

  static _HeaderLocation? _findPresetHeader(Sheet sheet) {
    final modern = _findHeader(
      sheet,
      ExcelHeaders.preset,
      (actual, expected, index) => actual == expected,
    );
    if (modern != null) return modern;
    return _findHeader(
      sheet,
      ExcelHeaders.legacyPreset,
      (actual, expected, index) => actual == expected,
    );
  }

  static bool _recordHeaderMatcher(String actual, String expected, int index) {
    if (actual == expected) return true;
    switch (index) {
      case 0:
        return actual == '部位' || actual.contains('部位');
      case 1:
        return actual == '动作' || actual == '动作名称' || actual.contains('动作');
      case 2:
        return actual == '组数' || actual == '组';
      case 3:
        return actual == '重量' || actual == '重量数值';
      case 4:
        // 兼容“单”“单位”“重量单位”等截断/扩展表头。
        return actual == '单位' || actual == '单' || actual.contains('单位');
      case 5:
        return actual == '次数' || actual == '次';
      case 6:
        return actual == '备注' || actual == '备注/感受';
      case 7:
        return actual == '组间歇' ||
            actual == '组间休息' ||
            actual == '间歇' ||
            actual.contains('组间');
      case 8:
        return actual == '日期' || actual.contains('日期');
      default:
        return false;
    }
  }

  static Sheet? _findSheetWithRecordHeader(Iterable<Sheet> sheets) {
    for (final sheet in sheets) {
      if (_findHeader(sheet, ExcelHeaders.record, _recordHeaderMatcher) !=
          null) {
        return sheet;
      }
    }
    return null;
  }

  static void _parseGymRows(
    Sheet sheet,
    _HeaderLocation header,
    List<_GymRow> result,
  ) {
    for (var i = header.row + 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (_isBlankRow(row)) continue;
      final name = _cellText(_cell(row, 0)).trim();
      if (name.isEmpty) continue;
      result.add(_GymRow(name: name, note: _cellText(_cell(row, 1)).trim()));
    }
  }

  static void _parsePresetRows(
    Sheet sheet,
    _HeaderLocation header,
    List<_PresetRow> result,
  ) {
    final headerValues = sheet.rows[header.row]
        .map((cell) => _normalizeHeader(_cellText(cell)))
        .toList();
    final groupIndex = headerValues.indexOf('分组');
    final noteIndex = headerValues.indexOf('备注');
    for (var i = header.row + 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (_isBlankRow(row)) continue;
      final gymName = _cellText(_cell(row, 0)).trim();
      final name = _cellText(_cell(row, 1)).trim();
      if (gymName.isEmpty || name.isEmpty) continue;
      result.add(
        _PresetRow(
          gymName: gymName,
          name: name,
          group: groupIndex < 0 ? '' : _cellText(_cell(row, groupIndex)).trim(),
          note: noteIndex < 0 ? '' : _cellText(_cell(row, noteIndex)).trim(),
        ),
      );
    }
  }

  static Map<int, String> _parseRecordGymMap(Sheet? sheet) {
    final result = <int, String>{};
    if (sheet == null) return result;
    for (var i = 0; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (_cellText(_cell(row, 0)).trim() != ExcelHeaders.mapHeaderRow) {
        continue;
      }
      for (var j = i + 1; j < sheet.rows.length; j++) {
        final mapRow = sheet.rows[j];
        final rowNumber = int.tryParse(_cellText(_cell(mapRow, 0)).trim());
        final gymName = _cellText(_cell(mapRow, 1)).trim();
        if (rowNumber == null || gymName.isEmpty) break;
        result[rowNumber] = gymName;
      }
      break;
    }
    return result;
  }

  static void _appendHeaderRow(Sheet sheet, List<String> values) {
    sheet.appendRow(
      values.map<CellValue?>((value) => TextCellValue(value)).toList(),
    );
  }

  static void _appendRow(Sheet sheet, List<CellValue?> values) {
    sheet.appendRow(values);
  }

  static void _styleSheet(Sheet sheet, int columns) {
    final style = CellStyle(bold: true);
    for (var col = 0; col < columns; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.cellStyle = style;
      sheet.setColumnWidth(col, 16);
    }
  }

  static Data? _cell(List<Data?> row, int index) =>
      index < row.length ? row[index] : null;

  static bool _isBlankRow(List<Data?> row) =>
      row.every((cell) => _cellText(cell).trim().isEmpty);

  static String _cellText(Data? cell) => _cellValueText(cell?.value);

  static String _cellValueText(CellValue? value) {
    if (value == null) return '';
    if (value is TextCellValue) return _textSpanText(value.value);
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) return formatWeight(value.value);
    if (value is BoolCellValue) return value.value ? '是' : '否';
    if (value is DateCellValue) return formatDate(value.asDateTimeLocal());
    if (value is DateTimeCellValue) {
      return formatDate(value.asDateTimeLocal());
    }
    if (value is FormulaCellValue) return value.formula;
    return value.toString();
  }

  static String _textSpanText(TextSpan span) {
    final buffer = StringBuffer();
    if (span.text != null) buffer.write(span.text);
    if (span.children != null) {
      for (final child in span.children!) {
        buffer.write(_textSpanText(child));
      }
    }
    return buffer.toString();
  }

  static String _normalizeHeader(String value) =>
      value.replaceAll('\ufeff', '').replaceAll(RegExp(r'\s+'), '').trim();

  static int? _parseInt(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final cleaned = text
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');
    final value = double.tryParse(cleaned);
    return value?.round();
  }

  static DateTime? _parseDate(Data? cell) {
    final value = cell?.value;
    if (value is DateCellValue) return dateOnly(value.asDateTimeLocal());
    if (value is DateTimeCellValue) return dateOnly(value.asDateTimeLocal());
    final text = _cellText(cell).trim();
    final parsed = tryParseDateText(text);
    if (parsed != null) return parsed;
    if (value is IntCellValue) return excelSerialToDate(value.value);
    if (value is DoubleCellValue) return excelSerialToDate(value.value);
    final serial = double.tryParse(text);
    return serial == null ? null : excelSerialToDate(serial);
  }
}

// -----------------------------------------------------------------------------
// 内部载体
// -----------------------------------------------------------------------------

class _HeaderLocation {
  const _HeaderLocation({required this.sheet, required this.row});

  final Sheet sheet;
  final int row;
}

class _GymRow {
  const _GymRow({required this.name, required this.note});

  final String name;
  final String note;
}

class _PresetRow {
  const _PresetRow({
    required this.gymName,
    required this.name,
    required this.group,
    required this.note,
  });

  final String gymName;
  final String name;
  final String group;
  final String note;
}

class _ImportedSet {
  _ImportedSet({
    required this.sourceRow,
    required this.groupIndex,
    required this.groupCount,
    required this.weightValue,
    required this.weightUnitIndex,
    required this.weightRaw,
    required this.reps,
    required this.setNote,
    required this.unresolved,
  });

  final int sourceRow;
  final int groupIndex;
  final int groupCount;
  final double? weightValue;
  final int? weightUnitIndex;
  final String weightRaw;
  final int reps;
  final String setNote;
  final bool unresolved;
}

class _ImportedGroup {
  _ImportedGroup({
    required this.date,
    required this.gymName,
    required this.bodyPart,
    required this.exerciseName,
    required this.entryNote,
    required this.restText,
  });

  final DateTime date;
  final String gymName;
  final String bodyPart;
  final String exerciseName;
  String entryNote;
  String restText;
  final List<_ImportedSet> sets = <_ImportedSet>[];
}

class _ParsedWorkbook {
  _ParsedWorkbook({required this.backupFormat});

  final bool backupFormat;
  final List<_GymRow> gymRows = <_GymRow>[];
  final List<_PresetRow> presetRows = <_PresetRow>[];
  List<_ImportedGroup> groups = <_ImportedGroup>[];
  final List<int> unresolvedRows = <int>[];
  final List<String> errors = <String>[];
  final List<String> warnings = <String>[];
  int failed = 0;

  void addError(String message) {
    if (errors.length < 50) errors.add(message);
  }
}

class _ImportAccumulator {
  _ImportAccumulator(this.parsed);

  final _ParsedWorkbook parsed;
  int success = 0;
  int skipped = 0;
  int entriesCreated = 0;
  int setsCreated = 0;
  int presetsCreated = 0;
  int gymsCreated = 0;

  ImportResult toResult() {
    return ImportResult(
      backupFormat: parsed.backupFormat,
      success: success,
      skipped: skipped,
      failed: parsed.failed,
      entriesCreated: entriesCreated,
      setsCreated: setsCreated,
      presetsCreated: presetsCreated,
      gymsCreated: gymsCreated,
      unresolvedRows: List<int>.unmodifiable(parsed.unresolvedRows),
      errors: List<String>.unmodifiable(parsed.errors),
      warnings: List<String>.unmodifiable(parsed.warnings),
    );
  }
}

class _NoteParts {
  const _NoteParts({required this.entryNote, required this.setNote});

  final String entryNote;
  final String setNote;
}

class _WeightParse {
  const _WeightParse({
    required this.value,
    required this.unit,
    required this.raw,
    this.unresolved = false,
  });

  final double? value;
  final WeightUnit? unit;
  final String raw;
  final bool unresolved;
}
