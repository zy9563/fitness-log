import 'package:flutter/services.dart';

/// 非负整数输入（组数、次数）。
class PositiveIntInputFormatter extends TextInputFormatter {
  const PositiveIntInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty || RegExp(r'^\d{0,4}$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// 非负重量输入，最多两位小数。
class WeightInputFormatter extends TextInputFormatter {
  const WeightInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty || RegExp(r'^\d{0,6}(\.\d{0,2})?$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}
