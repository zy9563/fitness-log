import 'package:fitness_log/core/weight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('重量单位只识别片/kg/lb 及常见别名', () {
    expect(WeightUnit.fromText('片'), WeightUnit.piece);
    expect(WeightUnit.fromText('kg'), WeightUnit.kg);
    expect(WeightUnit.fromText('公斤'), WeightUnit.kg);
    expect(WeightUnit.fromText('lb'), WeightUnit.lb);
    expect(WeightUnit.fromText('磅'), WeightUnit.lb);
    expect(WeightUnit.fromText('斤'), isNull);
    expect(WeightUnit.fromText('oz'), isNull);
  });

  test('未识别重量显示原文', () {
    expect(formatWeightValue(null, null, raw: '35公斤?'), '35公斤?');
    expect(formatWeightValue(62.5, WeightUnit.kg), '62.5 kg');
    expect(formatWeightValue(6, WeightUnit.piece), '6 片');
  });
}
