import 'package:fitness_log/core/exercise_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('动作分组固定为六类', () {
    expect(kExerciseGroups, ['胸', '背', '肩', '手臂', '臀腿', '核心']);
  });

  test('归一化兼容部位别名', () {
    expect(normalizeExerciseGroup('胸'), '胸');
    expect(normalizeExerciseGroup('腿部'), '臀腿');
    expect(normalizeExerciseGroup('三头'), '手臂');
    expect(normalizeExerciseGroup('腹部'), '核心');
    expect(normalizeExerciseGroup('随便'), isNull);
  });

  test('复合部位取更靠前的主部位', () {
    expect(groupFromBodyPart('胸，三头'), '胸');
    expect(groupFromBodyPart('背，后束'), '背');
    expect(groupFromBodyPart('手臂，核心'), '手臂');
    expect(groupFromBodyPart('腿(低'), '臀腿');
    expect(groupFromBodyPart('被'), isNull);
  });

  test('动作名明确时优先按动作归类，模糊动作使用部位兜底', () {
    expect(inferExerciseGroup('双杠', bodyPart: '胸'), '手臂');
    expect(inferExerciseGroup('自定义动作', bodyPart: '背'), '背');
    expect(inferExerciseGroup('绳索夹胸', bodyPart: '手臂'), '胸');
  });

  test('没有部位时按动作名推断', () {
    expect(inferExerciseGroup('史密斯卧推'), '胸');
    expect(inferExerciseGroup('高位下拉'), '背');
    expect(inferExerciseGroup('侧平举'), '肩');
    expect(inferExerciseGroup('腿弯举'), '臀腿');
    expect(inferExerciseGroup('窄距卧推'), '手臂');
    expect(inferExerciseGroup('悬垂举腿'), '核心');
    expect(inferExerciseGroup('侧平举+罗马凳'), '肩');
    expect(inferExerciseGroup('上斜'), '胸');
  });

  test('非法分组回退到动作推断', () {
    expect(resolveExerciseGroup('', '深蹲'), '臀腿');
    expect(resolveExerciseGroup('腿', '深蹲'), '臀腿');
    expect(resolveExerciseGroup('未知', '二头弯举'), '手臂');
  });
}
