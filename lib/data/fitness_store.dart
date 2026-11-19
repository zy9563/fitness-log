import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../core/app_exception.dart';
import '../core/date_x.dart';
import '../core/exercise_group.dart';
import '../services/excel_service.dart';
import 'models/backup_record.dart';
import 'models/exercise_preset.dart';
import 'models/gym.dart';
import 'models/training_entry.dart';
import 'models/training_set.dart';

/// 全局训练数据仓库。
///
/// 每次修改都立即写入 Isar；界面通过 provider 监听刷新。
class FitnessStore extends ChangeNotifier {
  FitnessStore(this._isar);

  final Isar _isar;

  List<Gym> _gyms = <Gym>[];
  List<ExercisePreset> _presets = <ExercisePreset>[];
  List<TrainingEntry> _entries = <TrainingEntry>[];
  List<TrainingSet> _sets = <TrainingSet>[];
  List<BackupRecord> _backups = <BackupRecord>[];

  bool _ready = false;

  bool get isReady => _ready;
  List<Gym> get gyms => _gyms;
  List<ExercisePreset> get presets => _presets;
  List<TrainingEntry> get entries => _entries;
  List<TrainingSet> get sets => _sets;
  List<BackupRecord> get backups => _backups;

  Future<void> initialize() async {
    await refreshAll(notify: false);
    _ready = true;
    notifyListeners();
  }

  Future<void> refreshAll({bool notify = true}) async {
    final loadedGyms = await _isar.gyms.where().findAll();
    final loadedPresets = await _isar.exercisePresets.where().findAll();
    final loadedEntries = await _isar.trainingEntrys.where().findAll();
    final loadedSets = await _isar.trainingSets.where().findAll();
    final loadedBackups = await _isar.backupRecords.where().findAll();

    loadedGyms.sort((a, b) => a.name.compareTo(b.name));
    loadedPresets.sort((a, b) {
      final gymCompare = a.gymId.compareTo(b.gymId);
      if (gymCompare != 0) return gymCompare;
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.name.compareTo(b.name);
    });
    loadedEntries.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      final similarDateOrder = a.sortOrder.compareTo(b.sortOrder);
      if (similarDateOrder != 0) return similarDateOrder;
      return a.id.compareTo(b.id);
    });
    loadedSets.sort((a, b) {
      final entryCompare = a.entryId.compareTo(b.entryId);
      if (entryCompare != 0) return entryCompare;
      return a.groupIndex.compareTo(b.groupIndex);
    });
    loadedBackups.sort((a, b) => b.exportedAt.compareTo(a.exportedAt));

    await _backfillPresetGroups(loadedPresets, loadedEntries);

    _gyms = loadedGyms;
    _presets = loadedPresets;
    _entries = loadedEntries;
    _sets = loadedSets;
    _backups = loadedBackups;
    if (notify) notifyListeners();
  }

  /// 旧版本没有分组字段（读出来为空），根据历史动作所属部位自动补齐。
  Future<void> _backfillPresetGroups(
    List<ExercisePreset> presets,
    List<TrainingEntry> entries,
  ) async {
    final pending = presets
        .where((preset) => normalizeExerciseGroup(preset.group) == null)
        .toList();
    if (pending.isEmpty) return;

    final bodyPartCounts = <String, Map<String, int>>{};
    for (final entry in entries) {
      final key = normalizeLookupName(entry.exerciseName);
      final bodyPart = entry.bodyPart.trim();
      if (key.isEmpty || bodyPart.isEmpty) continue;
      final counts = bodyPartCounts.putIfAbsent(key, () => <String, int>{});
      counts[bodyPart] = (counts[bodyPart] ?? 0) + 1;
    }

    await _isar.writeTxn(() async {
      for (final preset in pending) {
        final counts = bodyPartCounts[normalizeLookupName(preset.name)];
        var bestBodyPart = '';
        var bestCount = 0;
        if (counts != null) {
          for (final item in counts.entries) {
            if (item.value > bestCount) {
              bestBodyPart = item.key;
              bestCount = item.value;
            }
          }
        }
        preset.group = inferExerciseGroup(preset.name, bodyPart: bestBodyPart);
        await _isar.exercisePresets.put(preset);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 常用查询
  // ---------------------------------------------------------------------------

  Gym? gymById(int? id) {
    if (id == null) return null;
    for (final gym in _gyms) {
      if (gym.id == id) return gym;
    }
    return null;
  }

  ExercisePreset? presetById(int? id) {
    if (id == null || id == 0) return null;
    for (final preset in _presets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  TrainingEntry? entryById(int? id) {
    if (id == null) return null;
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  TrainingSet? setById(int? id) {
    if (id == null) return null;
    for (final set in _sets) {
      if (set.id == id) return set;
    }
    return null;
  }

  List<ExercisePreset> presetsForGym(int gymId) =>
      _presets.where((preset) => preset.gymId == gymId).toList();

  /// 查找动作条目对应的预设，用于展示预设备注。
  ExercisePreset? presetForEntry(TrainingEntry entry) {
    final key = normalizeLookupName(entry.exerciseName);
    for (final preset in _presets) {
      if (preset.gymId == entry.gymId &&
          normalizeLookupName(preset.name) == key) {
        return preset;
      }
    }
    return null;
  }

  /// 按固定分组顺序返回该健身房的全部预设，空组也会保留。
  Map<String, List<ExercisePreset>> groupedPresetsForGym(int gymId) {
    final result = <String, List<ExercisePreset>>{
      for (final group in kExerciseGroups) group: <ExercisePreset>[],
    };
    for (final preset in presetsForGym(gymId)) {
      final group = resolveExerciseGroup(preset.group, preset.name);
      result[group]!.add(preset);
    }
    return result;
  }

  List<TrainingEntry> entriesForDate(DateTime date, {int? gymId}) {
    final result =
        _entries
            .where(
              (entry) =>
                  isSameDate(entry.date, date) &&
                  (gymId == null || entry.gymId == gymId),
            )
            .toList()
          ..sort((a, b) {
            final gymCompare = (gymById(a.gymId)?.name ?? '').compareTo(
              gymById(b.gymId)?.name ?? '',
            );
            if (gymCompare != 0) return gymCompare;
            return a.sortOrder.compareTo(b.sortOrder);
          });
    return result;
  }

  List<TrainingEntry> entriesForDateGym(DateTime date, int gymId) =>
      entriesForDate(date, gymId: gymId);

  List<TrainingSet> setsForEntry(int entryId) {
    final result = _sets.where((set) => set.entryId == entryId).toList()
      ..sort((a, b) => a.groupIndex.compareTo(b.groupIndex));
    return result;
  }

  List<Gym> gymsWithEntriesOn(DateTime date) {
    final ids = <int>{};
    for (final entry in _entries) {
      if (isSameDate(entry.date, date)) ids.add(entry.gymId);
    }
    final result = _gyms.where((gym) => ids.contains(gym.id)).toList();
    return result;
  }

  int? latestGymIdForDate(DateTime date) {
    final dayEntries = entriesForDate(date);
    if (dayEntries.isEmpty) return null;
    dayEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return dayEntries.first.gymId;
  }

  /// 历史部位建议，按最近使用排序。
  List<String> bodyPartSuggestions() {
    final seen = <String>{};
    final result = <String>[];
    for (final entry in _entries) {
      final value = entry.bodyPart.trim();
      if (value.isEmpty) continue;
      if (seen.add(normalizeLookupName(value))) result.add(value);
    }
    return result;
  }

  /// 该动作最近一次使用的重量单位。
  int? lastWeightUnitIndexForExercise(String exerciseName) {
    final key = normalizeLookupName(exerciseName);
    if (key.isEmpty) return null;
    final matchingEntries =
        _entries
            .where((entry) => normalizeLookupName(entry.exerciseName) == key)
            .toList()
          ..sort((a, b) {
            final dateCompare = b.date.compareTo(a.date);
            if (dateCompare != 0) return dateCompare;
            return b.id.compareTo(a.id);
          });
    for (final entry in matchingEntries) {
      final entrySets = setsForEntry(entry.id);
      for (final set in entrySets.reversed) {
        if (set.weightUnitIndex != null) return set.weightUnitIndex;
      }
    }
    return null;
  }

  int presetCountForGym(int gymId) =>
      _presets.where((preset) => preset.gymId == gymId).length;

  int totalGroupCountForEntry(int entryId) =>
      setsForEntry(entryId).fold(0, (sum, set) => sum + set.groupCount);

  int totalRepsForEntry(int entryId) => setsForEntry(
    entryId,
  ).fold(0, (sum, set) => sum + set.groupCount * set.reps);

  // ---------------------------------------------------------------------------
  // 健身房
  // ---------------------------------------------------------------------------

  Future<Gym> createGym({required String name, String note = ''}) async {
    final cleanName = name.trim();
    _validateGymName(cleanName);
    final now = DateTime.now();
    final gym = Gym()
      ..name = cleanName
      ..note = note.trim()
      ..createdAt = now
      ..updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.gyms.put(gym);
    });
    await refreshAll();
    return gym;
  }

  Future<void> updateGym(
    Gym gym, {
    required String name,
    String note = '',
  }) async {
    final cleanName = name.trim();
    _validateGymName(cleanName, exceptId: gym.id);
    final fresh = await _isar.gyms.get(gym.id);
    if (fresh == null) throw AppException('健身房不存在或已被删除');
    await _isar.writeTxn(() async {
      fresh
        ..name = cleanName
        ..note = note.trim()
        ..updatedAt = DateTime.now();
      await _isar.gyms.put(fresh);
    });
    await refreshAll();
  }

  /// 删除健身房会级联删除其预设、动作和组记录。
  Future<void> deleteGym(int gymId) async {
    final allEntries = await _isar.trainingEntrys.where().findAll();
    final entryIds = allEntries
        .where((entry) => entry.gymId == gymId)
        .map((entry) => entry.id)
        .toSet();
    final allSets = await _isar.trainingSets.where().findAll();
    final setIds = allSets
        .where((set) => set.gymId == gymId || entryIds.contains(set.entryId))
        .map((set) => set.id)
        .toList();
    final allPresets = await _isar.exercisePresets.where().findAll();
    final presetIds = allPresets
        .where((preset) => preset.gymId == gymId)
        .map((preset) => preset.id)
        .toList();

    await _isar.writeTxn(() async {
      if (setIds.isNotEmpty) await _isar.trainingSets.deleteAll(setIds);
      if (entryIds.isNotEmpty) {
        await _isar.trainingEntrys.deleteAll(entryIds.toList());
      }
      if (presetIds.isNotEmpty) {
        await _isar.exercisePresets.deleteAll(presetIds);
      }
      await _isar.gyms.delete(gymId);
    });
    await refreshAll();
  }

  void _validateGymName(String name, {int? exceptId}) {
    if (name.isEmpty) throw AppException('健身房名称不能为空');
    final key = normalizeLookupName(name);
    if (_gyms.any(
      (gym) => gym.id != exceptId && normalizeLookupName(gym.name) == key,
    )) {
      throw AppException('已存在同名健身房');
    }
  }

  // ---------------------------------------------------------------------------
  // 动作预设
  // ---------------------------------------------------------------------------

  Future<ExercisePreset> createPreset({
    required int gymId,
    required String name,
    String group = '',
    String note = '',
  }) async {
    if (gymById(gymId) == null) throw AppException('健身房不存在');
    final cleanName = name.trim();
    _validatePresetName(gymId, cleanName);
    final existing = presetsForGym(gymId);
    final nextOrder = existing.isEmpty
        ? 0
        : existing
                  .map((preset) => preset.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    final preset = ExercisePreset()
      ..gymId = gymId
      ..name = cleanName
      ..group = resolveExerciseGroup(group, cleanName)
      ..note = note.trim()
      ..sortOrder = nextOrder
      ..createdAt = now
      ..updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.exercisePresets.put(preset);
    });
    await refreshAll();
    return preset;
  }

  Future<void> updatePreset(
    ExercisePreset preset, {
    required String name,
    String group = '',
    String note = '',
  }) async {
    final cleanName = name.trim();
    _validatePresetName(preset.gymId, cleanName, exceptId: preset.id);
    final fresh = await _isar.exercisePresets.get(preset.id);
    if (fresh == null) throw AppException('动作预设不存在或已被删除');
    await _isar.writeTxn(() async {
      fresh
        ..name = cleanName
        ..group = resolveExerciseGroup(group, cleanName)
        ..note = note.trim()
        ..updatedAt = DateTime.now();
      await _isar.exercisePresets.put(fresh);
    });
    await refreshAll();
  }

  Future<void> deletePreset(int presetId) async {
    await _isar.writeTxn(() async {
      await _isar.exercisePresets.delete(presetId);
    });
    await refreshAll();
  }

  Future<void> reorderPresets(List<ExercisePreset> ordered) async {
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      for (var i = 0; i < ordered.length; i++) {
        final preset = ordered[i]
          ..sortOrder = i
          ..updatedAt = now;
        await _isar.exercisePresets.put(preset);
      }
    });
    await refreshAll();
  }

  void _validatePresetName(int gymId, String name, {int? exceptId}) {
    if (name.isEmpty) throw AppException('动作名称不能为空');
    final key = normalizeLookupName(name);
    final duplicate = _presets.any(
      (preset) =>
          preset.gymId == gymId &&
          preset.id != exceptId &&
          normalizeLookupName(preset.name) == key,
    );
    if (duplicate) throw AppException('该健身房已存在同名动作');
  }

  // ---------------------------------------------------------------------------
  // 当天训练：动作与多行组
  // ---------------------------------------------------------------------------

  Future<TrainingEntry> createEntry({
    required int gymId,
    required DateTime date,
    required String bodyPart,
    required String exerciseName,
    String restText = '',
    String note = '',
    bool addToPreset = false,
    String presetGroup = '',
    String presetNote = '',
  }) async {
    if (gymById(gymId) == null) throw AppException('健身房不存在');
    final cleanName = exerciseName.trim();
    final cleanBodyPart = bodyPart.trim();
    if (cleanName.isEmpty) throw AppException('动作名称不能为空');
    if (cleanBodyPart.isEmpty) throw AppException('部位不能为空');

    final duplicate = entriesForDateGym(date, gymId).any(
      (entry) =>
          normalizeLookupName(entry.exerciseName) ==
              normalizeLookupName(cleanName) &&
          normalizeLookupName(entry.bodyPart) ==
              normalizeLookupName(cleanBodyPart),
    );
    if (duplicate) {
      throw AppException('今天这个部位下已经有“$cleanName”了，可以直接编辑它');
    }

    ExercisePreset? presetToCreate;
    if (addToPreset) {
      final nameKey = normalizeLookupName(cleanName);
      final exists = _presets.any(
        (preset) =>
            preset.gymId == gymId &&
            normalizeLookupName(preset.name) == nameKey,
      );
      if (!exists) {
        final now = DateTime.now();
        final gymPresets = presetsForGym(gymId);
        final order = gymPresets.isEmpty
            ? 0
            : gymPresets
                      .map((preset) => preset.sortOrder)
                      .reduce((a, b) => a > b ? a : b) +
                  1;
        presetToCreate = ExercisePreset()
          ..gymId = gymId
          ..name = cleanName
          ..group = resolveExerciseGroup(
            presetGroup,
            cleanName,
            bodyPart: cleanBodyPart,
          )
          ..note = presetNote.trim()
          ..sortOrder = order
          ..createdAt = now
          ..updatedAt = now;
      }
    }

    final dayEntries = entriesForDateGym(date, gymId);
    final nextOrder = dayEntries.isEmpty
        ? 0
        : dayEntries
                  .map((entry) => entry.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    final entry = TrainingEntry()
      ..gymId = gymId
      ..date = dateOnly(date)
      ..bodyPart = cleanBodyPart
      ..exerciseName = cleanName
      ..restText = restText.trim()
      ..note = note.trim()
      ..sortOrder = nextOrder
      ..createdAt = now
      ..updatedAt = now;

    await _isar.writeTxn(() async {
      if (presetToCreate != null) {
        await _isar.exercisePresets.put(presetToCreate);
      }
      await _isar.trainingEntrys.put(entry);
    });
    await refreshAll();
    return entry;
  }

  Future<void> updateEntry(
    TrainingEntry entry, {
    required String bodyPart,
    required String exerciseName,
    String restText = '',
    String note = '',
  }) async {
    final cleanName = exerciseName.trim();
    final cleanBodyPart = bodyPart.trim();
    if (cleanName.isEmpty) throw AppException('动作名称不能为空');
    if (cleanBodyPart.isEmpty) throw AppException('部位不能为空');
    final fresh = await _isar.trainingEntrys.get(entry.id);
    if (fresh == null) throw AppException('训练动作不存在或已被删除');
    final duplicate = entriesForDateGym(fresh.date, fresh.gymId).any(
      (item) =>
          item.id != entry.id &&
          normalizeLookupName(item.exerciseName) ==
              normalizeLookupName(cleanName) &&
          normalizeLookupName(item.bodyPart) ==
              normalizeLookupName(cleanBodyPart),
    );
    if (duplicate) {
      throw AppException('今天这个部位下已经有同名动作了');
    }
    await _isar.writeTxn(() async {
      fresh
        ..bodyPart = cleanBodyPart
        ..exerciseName = cleanName
        ..restText = restText.trim()
        ..note = note.trim()
        ..updatedAt = DateTime.now();
      await _isar.trainingEntrys.put(fresh);
    });
    await refreshAll();
  }

  /// 部位是“当天这次训练”的字段，界面上只填一次；
  /// 修改后同步到该日期、该健身房下的全部动作记录。
  Future<void> updateBodyPartForDateGym(
    DateTime date,
    int gymId,
    String bodyPart,
  ) async {
    final clean = bodyPart.trim();
    if (clean.isEmpty) throw AppException('训练部位不能为空');
    final allEntries = await _isar.trainingEntrys.where().findAll();
    final related = allEntries
        .where((entry) => entry.gymId == gymId && isSameDate(entry.date, date))
        .toList();
    if (related.isEmpty) return;
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      for (final entry in related) {
        entry
          ..bodyPart = clean
          ..updatedAt = now;
        await _isar.trainingEntrys.put(entry);
      }
    });
    await refreshAll();
  }

  Future<void> toggleEntryCompleted(TrainingEntry entry, bool completed) async {
    final fresh = await _isar.trainingEntrys.get(entry.id);
    if (fresh == null) throw AppException('训练动作不存在或已被删除');
    await _isar.writeTxn(() async {
      fresh
        ..completed = completed
        ..updatedAt = DateTime.now();
      await _isar.trainingEntrys.put(fresh);
    });
    await refreshAll();
  }

  Future<void> deleteEntry(int entryId) async {
    final allSets = await _isar.trainingSets.where().findAll();
    final setIds = allSets
        .where((set) => set.entryId == entryId)
        .map((set) => set.id)
        .toList();
    await _isar.writeTxn(() async {
      if (setIds.isNotEmpty) await _isar.trainingSets.deleteAll(setIds);
      await _isar.trainingEntrys.delete(entryId);
    });
    await refreshAll();
  }

  /// 按日期范围批量删除训练记录，开始和结束日期均包含在内。
  ///
  /// 健身房和动作预设不受影响。返回实际删除的动作、组记录行和组数。
  Future<HistoryDeleteResult> deleteEntriesInRange(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final start = dateOnly(rangeStart);
    final end = dateOnly(rangeEnd);
    if (start.isAfter(end)) {
      throw AppException('开始日期不能晚于结束日期');
    }
    final targets = _entries
        .where(
          (entry) => !entry.date.isBefore(start) && !entry.date.isAfter(end),
        )
        .toList();
    if (targets.isEmpty) {
      return const HistoryDeleteResult(
        entryCount: 0,
        setRowCount: 0,
        groupCount: 0,
      );
    }

    final entryIds = targets.map((entry) => entry.id).toSet();
    final targetSets = _sets
        .where((set) => entryIds.contains(set.entryId))
        .toList();
    final setIds = targetSets.map((set) => set.id).toList();
    final groupCount = targetSets.fold<int>(
      0,
      (sum, set) => sum + set.groupCount,
    );

    await _isar.writeTxn(() async {
      if (setIds.isNotEmpty) await _isar.trainingSets.deleteAll(setIds);
      await _isar.trainingEntrys.deleteAll(entryIds.toList());
    });
    await refreshAll();

    return HistoryDeleteResult(
      entryCount: targets.length,
      setRowCount: targetSets.length,
      groupCount: groupCount,
    );
  }

  Future<TrainingSet> addSet({
    required TrainingEntry entry,
    required int groupCount,
    double? weightValue,
    int? weightUnitIndex,
    required int reps,
    String note = '',
    String weightRaw = '',
  }) async {
    _validateSet(
      groupCount: groupCount,
      weightValue: weightValue,
      weightUnitIndex: weightUnitIndex,
      reps: reps,
    );
    final entrySets = setsForEntry(entry.id);
    final nextIndex = entrySets.isEmpty ? 1 : entrySets.last.groupIndex + 1;
    final now = DateTime.now();
    final set = TrainingSet()
      ..entryId = entry.id
      ..gymId = entry.gymId
      ..date = entry.date
      ..groupIndex = nextIndex
      ..groupCount = groupCount
      ..weightValue = weightValue
      ..weightUnitIndex = weightUnitIndex
      ..weightRaw = weightRaw.trim()
      ..reps = reps
      ..note = note.trim()
      ..createdAt = now
      ..updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.trainingSets.put(set);
    });
    await refreshAll();
    return set;
  }

  Future<void> updateSet(
    TrainingSet set, {
    required int groupCount,
    double? weightValue,
    int? weightUnitIndex,
    required int reps,
    String note = '',
    String weightRaw = '',
  }) async {
    _validateSet(
      groupCount: groupCount,
      weightValue: weightValue,
      weightUnitIndex: weightUnitIndex,
      reps: reps,
    );
    final fresh = await _isar.trainingSets.get(set.id);
    if (fresh == null) throw AppException('组记录不存在或已被删除');
    await _isar.writeTxn(() async {
      fresh
        ..groupCount = groupCount
        ..weightValue = weightValue
        ..weightUnitIndex = weightUnitIndex
        ..weightRaw = weightRaw.trim()
        ..reps = reps
        ..note = note.trim()
        ..updatedAt = DateTime.now();
      await _isar.trainingSets.put(fresh);
    });
    await refreshAll();
  }

  Future<void> deleteSet(TrainingSet set) async {
    await _isar.writeTxn(() async {
      await _isar.trainingSets.delete(set.id);
      final allSets = await _isar.trainingSets.where().findAll();
      final related =
          allSets.where((item) => item.entryId == set.entryId).toList()
            ..sort((a, b) {
              final order = a.groupIndex.compareTo(b.groupIndex);
              if (order != 0) return order;
              return a.id.compareTo(b.id);
            });
      for (var i = 0; i < related.length; i++) {
        related[i]
          ..groupIndex = i + 1
          ..updatedAt = DateTime.now();
        await _isar.trainingSets.put(related[i]);
      }
      if (related.isEmpty) {
        await _isar.trainingEntrys.delete(set.entryId);
      }
    });
    await refreshAll();
  }

  void _validateSet({
    required int groupCount,
    double? weightValue,
    int? weightUnitIndex,
    required int reps,
  }) {
    if (groupCount < 1) throw AppException('组数至少为 1');
    if (reps < 1) throw AppException('次数至少为 1');
    if (weightValue != null && weightValue < 0) {
      throw AppException('重量不能为负数');
    }
    if (weightUnitIndex != null &&
        (weightUnitIndex < 0 || weightUnitIndex > 2)) {
      throw AppException('重量单位只能是片、kg 或 lb');
    }
  }

  // ---------------------------------------------------------------------------
  // Excel 导入导出 / 备份记录
  // ---------------------------------------------------------------------------

  Future<ExportResult> exportBackup() async {
    final result = await FitnessExcelService.exportBackup(isar: _isar);
    await refreshAll();
    return result;
  }

  Future<ImportResult> importExcel({
    required int gymId,
    required List<int> bytes,
    required ImportMode mode,
  }) async {
    final result = await FitnessExcelService.importWorkbook(
      isar: _isar,
      gymId: gymId,
      bytes: bytes,
      mode: mode,
    );
    await refreshAll();
    return result;
  }

  Future<void> deleteBackupRecord(
    BackupRecord record, {
    bool deleteLocalFile = true,
  }) async {
    if (deleteLocalFile && record.filePath.isNotEmpty) {
      try {
        final file = File(record.filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // 文件可能已被用户删除或移动。
      }
    }
    await _isar.writeTxn(() async {
      await _isar.backupRecords.delete(record.id);
    });
    await refreshAll();
  }
}

class HistoryDeleteResult {
  const HistoryDeleteResult({
    required this.entryCount,
    required this.setRowCount,
    required this.groupCount,
  });

  final int entryCount;
  final int setRowCount;
  final int groupCount;
}
