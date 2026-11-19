import '../../core/date_x.dart';
import '../../data/models/training_entry.dart';

/// 同一天、同一部位原文的动作记录。
///
/// 这里不做部位归并：`胸` 和 `胸，三头` 是两个不同的组。
class WorkoutGroup {
  const WorkoutGroup({
    required this.date,
    required this.bodyPart,
    required this.entries,
  });

  final DateTime date;
  final String bodyPart;
  final List<TrainingEntry> entries;
}

/// 按日期 + 部位原文分组，日期由近及远。
List<WorkoutGroup> groupWorkoutEntries(Iterable<TrainingEntry> entries) {
  final buckets = <String, List<TrainingEntry>>{};
  for (final entry in entries) {
    final day = dateOnly(entry.date);
    final part = entry.bodyPart.trim();
    final key = '${day.year}-${day.month}-${day.day}\u0000$part';
    buckets.putIfAbsent(key, () => <TrainingEntry>[]).add(entry);
  }

  final groups = <WorkoutGroup>[];
  for (final list in buckets.values) {
    list.sort((a, b) {
      final gymCompare = a.gymId.compareTo(b.gymId);
      if (gymCompare != 0) return gymCompare;
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.id.compareTo(b.id);
    });
    final first = list.first;
    groups.add(
      WorkoutGroup(
        date: dateOnly(first.date),
        bodyPart: first.bodyPart.trim(),
        entries: List.unmodifiable(list),
      ),
    );
  }

  groups.sort((a, b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) return dateCompare;
    return a.bodyPart.compareTo(b.bodyPart);
  });
  return groups;
}
