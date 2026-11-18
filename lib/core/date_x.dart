import 'dart:math' as math;

/// 去掉时分秒，统一使用本地时间的“日期”。
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 数据库/Excel 使用的日期键：yyyy-MM-dd。避免依赖 intl 的 locale 初始化。
String formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String formatDateChinese(DateTime value) =>
    '${value.year}年${value.month}月${value.day}日';

String weekdayZh(DateTime value) {
  const names = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return names[value.weekday - 1];
}

String formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${formatDate(value)} $hour:$minute';
}

String formatClock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// 显示重量：最多保留两位小数，去掉无意义的 0。
String formatWeight(num? value) {
  if (value == null) return '-';
  if (value == 0) return '0';
  final text = value.toDouble().toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
}

/// 用于去重/索引的日期+名称键。
String dateGymExerciseKey(DateTime date, String gymName, String exercise) =>
    '${formatDate(date)}|${normalizeLookupName(gymName)}|'
    '${normalizeLookupName(exercise)}';

String normalizeLookupName(String value) => value.trim().toLowerCase();

/// Excel 中可能出现的日期文本。
///
/// 主要支持 yyyy-MM-dd / yyyy/M/d / yyyy.M.d，也兼容 Excel 单元格被
/// 读成 DateTime 时由调用方直接传入的情况。
DateTime? tryParseDateText(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  // 先验证 yyyy-MM-dd，避免 DateTime.tryParse 把 2026-02-30 自动修正为 3 月 2 日。
  final match = RegExp(
    r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})(?:[T ].*)?$',
  ).firstMatch(text);
  if (match != null) {
    return _safeDate(
      int.tryParse(match.group(1)!),
      int.tryParse(match.group(2)!),
      int.tryParse(match.group(3)!),
    );
  }

  // 2026年11月17日 / 2026年1月2日
  final chinese = RegExp(r'^(\d{4})年(\d{1,2})月(\d{1,2})日?$').firstMatch(text);
  if (chinese != null) {
    return _safeDate(
      int.tryParse(chinese.group(1)!),
      int.tryParse(chinese.group(2)!),
      int.tryParse(chinese.group(3)!),
    );
  }

  // 11/17/2026（按美式 月/日/年处理）
  final american = RegExp(
    r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$',
  ).firstMatch(text);
  if (american != null) {
    return _safeDate(
      int.tryParse(american.group(3)!),
      int.tryParse(american.group(1)!),
      int.tryParse(american.group(2)!),
    );
  }

  final direct = DateTime.tryParse(text);
  return direct == null ? null : dateOnly(direct);
}

DateTime? _safeDate(int? year, int? month, int? day) {
  if (year == null || month == null || day == null) return null;
  final value = DateTime(year, month, day);
  if (value.year != year || value.month != month || value.day != day) {
    return null;
  }
  return value;
}

/// Excel 日期序列号（1900 日期系统）转日期。
DateTime? excelSerialToDate(num serial) {
  if (serial < 1 || serial > 100000) return null;
  // Excel 的 1900 日期系统把 1900-02-29 当作存在，故基准取 1899-12-30。
  return dateOnly(DateTime(1899, 12, 30).add(Duration(days: serial.floor())));
}

/// 生成最近 N 天的起始日期（含今天）。
DateTime daysAgo(int days) {
  final now = dateOnly(DateTime.now());
  return now.subtract(Duration(days: math.max(0, days - 1)));
}
