import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

class CacheClearResult {
  const CacheClearResult({required this.fileCount, required this.bytes});

  final int fileCount;
  final int bytes;
}

/// 清理 App 的临时目录，并同步清空 Flutter 图片缓存。
///
/// 只处理系统缓存目录；Isar 数据、导出备份和背景图片都不在缓存目录中。
Future<CacheClearResult> clearAppCache() async {
  final cacheDirectory = await getTemporaryDirectory();
  final result = await clearDirectoryContents(cacheDirectory);
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  return result;
}

/// 清空目录内容但保留目录本身，便于测试和多次清理。
Future<CacheClearResult> clearDirectoryContents(Directory directory) async {
  if (!await directory.exists()) {
    return const CacheClearResult(fileCount: 0, bytes: 0);
  }

  var deletedFiles = 0;
  var deletedBytes = 0;
  final children = directory.listSync(followLinks: false);
  for (final entity in children) {
    final files = <File>[];
    if (entity is File) {
      files.add(entity);
    } else if (entity is Directory) {
      for (final child in entity.listSync(
        recursive: true,
        followLinks: false,
      )) {
        if (child is File) files.add(child);
      }
    }

    var localBytes = 0;
    for (final file in files) {
      try {
        localBytes += await file.length();
      } catch (_) {
        // 文件可能已被系统清理。
      }
    }
    try {
      await entity.delete(recursive: true);
      deletedFiles += files.length;
      deletedBytes += localBytes;
    } catch (_) {
      // 正在使用的临时文件可能无法删除，跳过即可。
    }
  }

  return CacheClearResult(fileCount: deletedFiles, bytes: deletedBytes);
}
