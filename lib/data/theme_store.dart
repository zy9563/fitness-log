import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/app_exception.dart';
import 'models/theme_settings.dart';

enum AppThemeMode {
  light,
  system,
  custom;

  static AppThemeMode fromIndex(int index) {
    if (index < 0 || index >= values.length) return AppThemeMode.light;
    return values[index];
  }
}

/// 主题配置仓库。固定使用 ThemeSettings(id=1)。
class ThemeStore extends ChangeNotifier {
  ThemeStore(this._isar);

  final Isar _isar;
  ThemeSettings _settings = ThemeSettings();
  bool _ready = false;

  ThemeSettings get settings => _settings;
  bool get isReady => _ready;

  AppThemeMode get mode => AppThemeMode.fromIndex(_settings.themeModeIndex);

  Future<void> initialize() async {
    final existing = await _isar.themeSettings.get(1);
    if (existing == null) {
      _settings = ThemeSettings();
      await _isar.writeTxn(() async {
        await _isar.themeSettings.put(_settings);
      });
    } else {
      _settings = existing;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode value) async {
    _settings.themeModeIndex = value.index;
    await _save();
  }

  Future<void> setCardColor(int argb) async {
    _settings.cardColorValue = argb;
    await _save();
  }

  Future<void> setBackgroundColor(int argb) async {
    _settings.backgroundColorValue = argb;
    await _save();
  }

  Future<void> setUseBackgroundImage(bool value) async {
    _settings.useBackgroundImage = value;
    await _save();
  }

  Future<void> setImageOpacity(double value) async {
    _settings.backgroundImageOpacity = value.clamp(0.05, 1.0).toDouble();
    await _save();
  }

  Future<void> setImageBlur(double value) async {
    _settings.backgroundImageBlur = value.clamp(0.0, 20.0).toDouble();
    await _save();
  }

  /// 只接受本地图片路径，复制进 App 私有目录，避免原图被删除后失效。
  Future<void> setBackgroundImage(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) throw AppException('本地图片读取失败');
    final extension = p.extension(sourcePath).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp', '.bmp'].contains(extension)) {
      throw AppException('请选择常见的本地图片格式');
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'theme'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final targetName =
        'background_${DateTime.now().millisecondsSinceEpoch}$extension';
    final target = File(p.join(dir.path, targetName));
    await source.copy(target.path);

    final oldPath = _settings.backgroundImagePath;
    _settings
      ..backgroundImagePath = target.path
      ..useBackgroundImage = true;
    await _save();
    if (oldPath.isNotEmpty && oldPath != target.path) {
      try {
        final old = File(oldPath);
        if (await old.exists()) await old.delete();
      } catch (_) {
        // 旧图删除失败不影响新主题。
      }
    }
  }

  Future<void> removeBackgroundImage() async {
    final oldPath = _settings.backgroundImagePath;
    _settings
      ..useBackgroundImage = false
      ..backgroundImagePath = '';
    await _save();
    if (oldPath.isNotEmpty) {
      try {
        final old = File(oldPath);
        if (await old.exists()) await old.delete();
      } catch (_) {
        // 忽略。
      }
    }
  }

  Future<void> resetCustomColors() async {
    _settings
      ..cardColorValue = 0xFFFFFFFF
      ..backgroundColorValue = 0xFFF7FAFF;
    await _save();
  }

  Future<void> _save() async {
    _settings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.themeSettings.put(_settings);
    });
    notifyListeners();
  }
}
