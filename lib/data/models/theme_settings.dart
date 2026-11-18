import 'package:isar_community/isar.dart';

part 'theme_settings.g.dart';

/// 全局主题设置，固定只有 id=1 一条。
@collection
class ThemeSettings {
  Id id = 1;

  /// 0=默认浅色，1=跟随系统，2=自定义。
  int themeModeIndex = 0;

  /// 卡片背景色 ARGB。
  int cardColorValue = 0xFFFFFFFF;

  /// 全局背景纯色 ARGB。
  int backgroundColorValue = 0xFFF7FAFF;

  bool useBackgroundImage = false;

  /// 复制到 App 目录后的本地图片路径。
  String backgroundImagePath = '';

  /// 背景图片不透明度，0.05 ~ 1.0。
  double backgroundImageOpacity = 0.35;

  /// 背景图片模糊度，0 ~ 20。
  double backgroundImageBlur = 0;

  DateTime updatedAt = DateTime.now();
}
