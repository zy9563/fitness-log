import 'package:isar_community/isar.dart';

part 'gym.g.dart';

/// 健身房。每个健身房拥有独立的器械预设清单。
@collection
class Gym {
  Id id = Isar.autoIncrement;

  /// 展示名称，业务层保证去除首尾空格后不重复。
  String name = '';

  /// 备注，例如“离家近”“公司附近”。
  String note = '';

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
