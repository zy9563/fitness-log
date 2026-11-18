import 'package:isar_community/isar.dart';

part 'exercise_preset.g.dart';

/// 某个健身房下的动作预设。
///
/// 预设保存动作名称、所属分组和备注；组数、重量、次数都在录入训练时填写。
@collection
class ExercisePreset {
  Id id = Isar.autoIncrement;

  @Index()
  int gymId = 0;

  String name = '';

  /// 六个固定分组之一：胸 / 背 / 肩 / 手臂 / 臀腿 / 核心。
  ///
  /// 旧数据升级时可能暂时为空，[FitnessStore] 会自动补齐。
  String group = '';

  String note = '';

  /// 健身房内排序，越小越靠前。
  int sortOrder = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
