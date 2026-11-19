import 'package:flutter/services.dart';

/// 应用完整性检查。
///
/// 打赏入口只在签名与官方构建一致时显示；检查失败不影响其他功能。
class AppSecurity {
  const AppSecurity._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.fitness_log/signature',
  );

  /// 当前 debug/官方安装包的签名证书 SHA-256。
  static const String officialSignatureSha256 =
      '47fc0c5e112cc7f7e01e0122ca29c342230d7d77c497502bec90b1903089fb68';

  static bool isOfficialBuild = false;

  static Future<void> verifySignature() async {
    try {
      final value = await _channel.invokeMethod<String>('sha256');
      isOfficialBuild =
          value?.toLowerCase() == officialSignatureSha256.toLowerCase();
    } catch (_) {
      isOfficialBuild = false;
    }
  }
}
