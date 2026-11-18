import 'package:isar_community/isar.dart';

part 'training_set.g.dart';

/// 动作下的一行组记录。
///
/// 一行可以代表多组（[groupCount]），例如“4 组 × 60 kg × 8 次”。
/// 重量单位只允许 片 / kg / lb；无法解析的原始重量保存在 [weightRaw]。
@collection
class TrainingSet {
  Id id = Isar.autoIncrement;

  @Index()
  int entryId = 0;

  @Index()
  int gymId = 0;

  @Index()
  DateTime date = DateTime.now();

  /// 动作内从 1 开始的组别序号，也是 Excel 导入去重键的一部分。
  int groupIndex = 1;

  /// 这一行代表的组数。
  int groupCount = 1;

  /// 重量数值；解析失败或未填写时为 null。
  double? weightValue;

  /// 0=片，1=kg，2=lb；null 表示单位无法识别。
  int? weightUnitIndex;

  /// 重量原文，用于保存无法识别的复合文本，不参与统计。
  String weightRaw = '';

  int reps = 1;

  String note = '';

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
