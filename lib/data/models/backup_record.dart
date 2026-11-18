import 'package:isar_community/isar.dart';

part 'backup_record.g.dart';

/// 最近导出记录。
@collection
class BackupRecord {
  Id id = Isar.autoIncrement;

  String fileName = '';

  /// 分享用的 App 目录副本路径。
  String filePath = '';

  /// 下载目录中的展示位置（content:// 或绝对路径）。
  String downloadPath = '';

  @Index()
  DateTime exportedAt = DateTime.now();

  int gymCount = 0;
  int presetCount = 0;
  int entryCount = 0;
  int setCount = 0;
  int fileSize = 0;
}
