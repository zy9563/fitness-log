import 'package:flutter/material.dart';

/// 六个动作分组的统一颜色与圆形标识。
class ExerciseGroupBadge extends StatelessWidget {
  const ExerciseGroupBadge({super.key, required this.group, this.radius = 18});

  final String group;
  final double radius;

  static const Map<String, Color> _colors = <String, Color>{
    '胸': Color(0xFFE05A6D),
    '背': Color(0xFF3F7FD8),
    '肩': Color(0xFFE39A32),
    '手臂': Color(0xFF3D9A78),
    '臀腿': Color(0xFF8A63C7),
    '核心': Color(0xFF3A9AA8),
  };

  static Color colorOf(String group) => _colors[group] ?? Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    final color = colorOf(group);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withAlpha(28),
      child: Text(
        group,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.62,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
