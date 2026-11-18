/// 业务层可预期的错误。界面直接展示 [message]，不需要打印堆栈。
class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 导入 Excel 时表头、文件结构等不可恢复的错误。
class ImportFormatException extends AppException {
  ImportFormatException(super.message);
}
