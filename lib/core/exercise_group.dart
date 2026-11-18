/// 动作预设置的六个固定分组，顺序即界面展示顺序。
const List<String> kExerciseGroups = <String>['胸', '背', '肩', '手臂', '臀腿', '核心'];

/// 把历史数据、Excel 中的自由文本归一到六个固定分组。
String? normalizeExerciseGroup(String raw) {
  final value = raw.trim().replaceAll(RegExp(r'\s+'), '');
  if (value.isEmpty) return null;
  for (final group in kExerciseGroups) {
    if (value == group) return group;
  }
  if (value.contains('胸')) return '胸';
  if (value.contains('背')) return '背';
  if (value.contains('肩') ||
      value.contains('三角') ||
      value.contains('后束') ||
      value.contains('中束')) {
    return '肩';
  }
  if (value.contains('手臂') ||
      value.contains('胳膊') ||
      value.contains('二头') ||
      value.contains('三头') ||
      value.contains('肱')) {
    return '手臂';
  }
  if (value.contains('臀') ||
      value.contains('腿') ||
      value.contains('股') ||
      value.contains('腘绳')) {
    return '臀腿';
  }
  if (value.contains('核心') || value.contains('腹') || value.contains('腰')) {
    return '核心';
  }
  return null;
}

/// 从当天的自由部位文本推断主分组。
///
/// 例如“胸，三头”取更靠前的“胸”；“背，后束”取“背”；
/// 无法识别时返回 null。
String? groupFromBodyPart(String bodyPart) {
  final value = bodyPart.trim();
  if (value.isEmpty) return null;

  const aliases = <String, List<String>>{
    '胸': ['胸'],
    '背': ['背'],
    '肩': ['肩', '三角', '后束', '中束'],
    '手臂': ['手臂', '胳膊', '二头', '三头', '肱'],
    '臀腿': ['臀', '腿', '股', '腘绳'],
    '核心': ['核心', '腹', '腰'],
  };

  String? bestGroup;
  var bestIndex = value.length + 1;
  for (final entry in aliases.entries) {
    for (final alias in entry.value) {
      final index = value.indexOf(alias);
      if (index >= 0 && index < bestIndex) {
        bestIndex = index;
        bestGroup = entry.key;
      }
    }
  }
  return bestGroup;
}

/// 少量容易歧义的历史动作名，优先按动作本身归类。
const Map<String, String> _exactActionGroups = <String, String>{
  '上斜': '胸',
  '上斜哑铃': '胸',
  '上斜哑铃卧推': '胸',
  '上斜杠铃卧推': '胸',
  '二头弯举': '手臂',
  '侧平举+罗马凳': '肩',
  '侧平举，颈后臂屈伸': '肩',
  '飞鸟中束+俯身臂屈伸': '肩',
  '对握': '背',
  '窄距对握': '背',
  '双杠': '手臂',
  '辅助双杠': '手臂',
  '臂屈伸': '手臂',
  '辅助臂屈伸': '手臂',
  '窄推': '手臂',
  '窄距卧推': '手臂',
  '俯卧撑': '胸',
  '提裤式后拉': '背',
  '牧师凳': '手臂',
  '腿曲伸': '臀腿',
  '卷腹机': '核心',
  '悬垂举腿': '核心',
};

/// 给动作预设一个稳定分组。
///
/// 优先使用当天部位；没有部位时，优先查歧义动作表，再按动作关键词推断。
/// 仍然无法判断时归入“胸”，保证所有预设都落在六个固定分组内。
String inferExerciseGroup(String name, {String bodyPart = ''}) {
  final cleanName = name.trim();
  final exact = _exactActionGroups[cleanName];
  if (exact != null) return exact;

  final value = cleanName.toLowerCase();
  bool containsAny(List<String> keywords) =>
      keywords.any((keyword) => value.contains(keyword));

  if (containsAny(const ['卷腹', '举腿', '平板支撑', '俄罗斯转体', '健腹'])) {
    return '核心';
  }
  if (containsAny(const [
    '深蹲',
    '硬拉',
    '倒蹬',
    '腿',
    '提踵',
    '弓箭步',
    '箭步',
    '保加利亚',
    '臀桥',
    '髋',
  ])) {
    return '臀腿';
  }
  if (containsAny(const ['弯举', '臂屈伸', '窄推', '窄距卧推', '双杠', '三头', '二头', '牧师凳'])) {
    return '手臂';
  }
  if (containsAny(const ['侧平举', '推肩', '实力推', '前平举', '后束', '耸肩'])) {
    return '肩';
  }
  if (containsAny(const ['引体', '下拉', '划船', '后拉', '对握', '高位', '面拉', '直臂'])) {
    return '背';
  }
  if (containsAny(const ['卧推', '推胸', '飞鸟', '夹胸', '俯卧撑', '平板'])) {
    return '胸';
  }

  // 动作名看不出肌群时，再使用当天填写的部位作为兜底。
  final fromBodyPart = groupFromBodyPart(bodyPart);
  if (fromBodyPart != null) return fromBodyPart;
  return '胸';
}

/// 合法分组直接使用；否则根据动作名/部位推断。
String resolveExerciseGroup(
  String rawGroup,
  String name, {
  String bodyPart = '',
}) {
  return normalizeExerciseGroup(rawGroup) ??
      inferExerciseGroup(name, bodyPart: bodyPart);
}
