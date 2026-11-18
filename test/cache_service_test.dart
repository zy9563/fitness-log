import 'dart:io';

import 'package:fitness_log/services/cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('清理缓存目录只删除内容，保留目录并统计文件大小', () async {
    final directory = await Directory.systemTemp.createTemp('fitness_cache_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    await File('${directory.path}/root.tmp').writeAsString('0123456789');
    final nested = await Directory('${directory.path}/images').create();
    await File('${nested.path}/one.tmp').writeAsString('a' * 20);
    await File('${nested.path}/two.tmp').writeAsString('b' * 30);
    await Directory('${directory.path}/empty').create();

    final first = await clearDirectoryContents(directory);
    expect(first.fileCount, 3);
    expect(first.bytes, 60);
    expect(await directory.exists(), isTrue);
    expect(directory.listSync(), isEmpty);

    final second = await clearDirectoryContents(directory);
    expect(second.fileCount, 0);
    expect(second.bytes, 0);
  });

  test('目录不存在时返回零', () async {
    final directory = await Directory.systemTemp.createTemp('fitness_cache_');
    await directory.delete(recursive: true);
    final result = await clearDirectoryContents(directory);
    expect(result.fileCount, 0);
    expect(result.bytes, 0);
  });
}
