import 'package:isar_community/isar.dart';

part 'training_entry.g.dart';

/// 某一天、某个健身房下的一个动作记录。
///
/// 一次训练可以有多个动作；每个动作下有多行“组”。
@collection
class TrainingEntry {
  Id id = Isar.autoIncrement;

  @Index()
  int gymId = 0;

  @Index()
  DateTime date = DateTime.now();

  /// 用户自由填写的部位，例如“胸，三头”“背，二头”“腿”。
  String bodyPart = '';

  @Index()
  String exerciseName = '';

  /// 组间休息，自由文本，例如“90秒”“2分钟”。
  String restText = '';

  /// 动作备注/感受。
  String note = '';

  /// 动作完成标记。
  bool completed = false;

  int sortOrder = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
