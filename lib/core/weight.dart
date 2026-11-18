import 'package:flutter/material.dart';

import 'date_x.dart';

/// 重量单位只允许三种，不允许自由输入。
enum WeightUnit {
  piece,
  kg,
  lb;

  String get label {
    switch (this) {
      case WeightUnit.piece:
        return '片';
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lb:
        return 'lb';
    }
  }

  static WeightUnit? fromIndex(int? index) {
    if (index == null) return null;
    if (index < 0 || index >= WeightUnit.values.length) return null;
    return WeightUnit.values[index];
  }

  static WeightUnit? fromText(String value) {
    switch (value.trim().toLowerCase()) {
      case '片':
      case 'p':
      case 'piece':
        return WeightUnit.piece;
      case 'kg':
      case '公斤':
      case '千克':
        return WeightUnit.kg;
      case 'lb':
      case 'lbs':
      case '磅':
        return WeightUnit.lb;
      default:
        return null;
    }
  }
}

String formatWeightValue(double? value, WeightUnit? unit, {String raw = ''}) {
  if (value == null) {
    if (raw.trim().isNotEmpty) return raw.trim();
    return '-';
  }
  final unitLabel = unit?.label ?? '';
  return '${formatWeight(value)}${unitLabel.isEmpty ? '' : ' $unitLabel'}';
}

String weightUnitLabel(int? index) => WeightUnit.fromIndex(index)?.label ?? '';

/// 用于把重量数值和单位以固定格式显示到导入导出文件。
String weightCellValue(double? value) {
  if (value == null) return '';
  return formatWeight(value);
}

Color contrastColor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : const Color(0xFF171A1F);
}

Color secondaryTextColor(Color background) {
  final base = contrastColor(background);
  return base.withAlpha(185);
}
