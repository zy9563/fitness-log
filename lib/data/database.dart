import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/backup_record.dart';
import 'models/exercise_preset.dart';
import 'models/gym.dart';
import 'models/theme_settings.dart';
import 'models/training_entry.dart';
import 'models/training_set.dart';

/// Isar 数据库入口。所有健身数据与主题配置都保存在本机。
class AppDatabase {
  AppDatabase._();

  static Future<Isar> open() async {
    final directory = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        GymSchema,
        ExercisePresetSchema,
        TrainingEntrySchema,
        TrainingSetSchema,
        BackupRecordSchema,
        ThemeSettingsSchema,
      ],
      directory: directory.path,
      name: 'fitness_log',
      inspector: false,
    );
  }
}
