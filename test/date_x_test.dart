import 'package:fitness_log/core/date_x.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('日期工具', () {
    test('只保留年月日', () {
      final value = dateOnly(DateTime(2026, 11, 17, 23, 59, 59));
      expect(value, DateTime(2026, 11, 17));
    });

    test('格式化为 yyyy-MM-dd', () {
      expect(formatDate(DateTime(2026, 1, 2)), '2026-01-02');
      expect(formatDate(DateTime(2026, 11, 17)), '2026-11-17');
    });

    test('识别常见日期文本', () {
      expect(tryParseDateText('2026-11-17'), DateTime(2026, 11, 17));
      expect(tryParseDateText('2026/1/2'), DateTime(2026, 1, 2));
      expect(tryParseDateText('2026.11.17'), DateTime(2026, 11, 17));
      expect(tryParseDateText('不是日期'), isNull);
      expect(tryParseDateText('2026-02-30'), isNull);
    });

    test('Excel 序列号转换', () {
      expect(excelSerialToDate(46000), isNotNull);
      expect(excelSerialToDate(0), isNull);
    });

    test('重量格式去掉无意义的小数', () {
      expect(formatWeight(60), '60');
      expect(formatWeight(62.5), '62.5');
      expect(formatWeight(62.50), '62.5');
      expect(formatWeight(null), '-');
    });
  });
}
