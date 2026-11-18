import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/gym.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/app_widgets.dart';

enum _ChartRange { week, month, year }

class ExerciseProgressPage extends StatefulWidget {
  const ExerciseProgressPage({
    super.key,
    this.initialGymId,
    this.initialExercise = '',
  });

  final int? initialGymId;
  final String initialExercise;

  @override
  State<ExerciseProgressPage> createState() => _ExerciseProgressPageState();
}

class _ExerciseProgressPageState extends State<ExerciseProgressPage> {
  int? _gymId;
  String? _exerciseName;
  WeightUnit? _unit;
  _ChartRange _range = _ChartRange.week;

  @override
  void initState() {
    super.initState();
    _gymId = widget.initialGymId;
    _exerciseName = widget.initialExercise.trim().isEmpty
        ? null
        : widget.initialExercise;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exerciseName == null) {
      final names = _exerciseNames(context.read<FitnessStore>());
      if (names.length == 1) _exerciseName = names.first;
    }
  }

  List<String> _exerciseNames(FitnessStore store) {
    final names = <String>{};
    for (final entry in store.entries) {
      if (_gymId != null && entry.gymId != _gymId) continue;
      names.add(entry.exerciseName);
    }
    return names.toList()..sort();
  }

  List<_ProgressRow> _rows(FitnessStore store) {
    final name = _exerciseName;
    if (name == null || name.trim().isEmpty) return const [];
    final key = normalizeLookupName(name);
    final result = <_ProgressRow>[];
    for (final entry in store.entries) {
      if (normalizeLookupName(entry.exerciseName) != key) continue;
      if (_gymId != null && entry.gymId != _gymId) continue;
      final gym = store.gymById(entry.gymId);
      if (gym == null) continue;
      for (final set in store.setsForEntry(entry.id)) {
        result.add(_ProgressRow(entry: entry, set: set, gym: gym));
      }
    }
    // 日期越新越靠上；同一天内按组别顺序。
    result.sort((a, b) {
      final dateCompare = b.entry.date.compareTo(a.entry.date);
      if (dateCompare != 0) return dateCompare;
      return a.set.groupIndex.compareTo(b.set.groupIndex);
    });
    return result;
  }

  List<WeightUnit> _availableUnits(List<_ProgressRow> rows) {
    final units = <WeightUnit>{};
    for (final row in rows) {
      final unit = WeightUnit.fromIndex(row.set.weightUnitIndex);
      if (unit != null && row.set.weightValue != null) units.add(unit);
    }
    final result = units.toList();
    result.sort((a, b) => a.index.compareTo(b.index));
    return result;
  }

  WeightUnit? _effectiveUnit(List<WeightUnit> units) {
    if (units.isEmpty) return null;
    if (_unit != null && units.contains(_unit)) return _unit;
    if (units.contains(WeightUnit.kg)) return WeightUnit.kg;
    return units.first;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final names = _exerciseNames(store);
    final rows = _rows(store);
    final units = _availableUnits(rows);
    final unit = _effectiveUnit(units);
    final maxSpots = _dailyMaxSpots(rows, unit);

    return Scaffold(
      appBar: AppBar(title: const Text('动作变化')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
        children: [
          const AppInfoBanner(
            icon: Icons.show_chart,
            text:
                '折线图展示所选动作的“当日最大重量”。'
                '不同重量单位不合并；无法识别的重量不参与统计。',
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  key: ValueKey<int>(_gymId ?? 0),
                  initialValue: _gymId ?? 0,
                  decoration: const InputDecoration(labelText: '健身房'),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('全部健身房')),
                    for (final gym in store.gyms)
                      DropdownMenuItem(
                        value: gym.id,
                        child: Text(gym.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gymId = value == 0 ? null : value;
                      _exerciseName = null;
                      _unit = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(_exerciseName ?? ''),
                  initialValue: names.contains(_exerciseName)
                      ? _exerciseName
                      : null,
                  decoration: const InputDecoration(labelText: '动作'),
                  items: [
                    for (final name in names)
                      DropdownMenuItem(value: name, child: Text(name)),
                  ],
                  onChanged: (value) => setState(() {
                    _exerciseName = value;
                    _unit = null;
                  }),
                ),
              ],
            ),
          ),
          SectionTitle(
            _exerciseName == null ? '选择动作' : '$_exerciseName 的变化',
            subtitle: _exerciseName == null
                ? '选择动作后显示最大重量折线图'
                : '共 ${rows.length} 行组记录',
          ),
          if (_exerciseName == null)
            const AppSectionCard(
              child: EmptyState(
                icon: Icons.touch_app_outlined,
                title: '先选择一个动作',
                message: '选择动作后，上方会显示当日最大重量折线图，下方按日期合并组记录。',
              ),
            )
          else ...[
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '当日最大重量',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (unit != null)
                        Text(
                          unit.label,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_ChartRange>(
                    segments: const [
                      ButtonSegment(value: _ChartRange.week, label: Text('周')),
                      ButtonSegment(value: _ChartRange.month, label: Text('月')),
                      ButtonSegment(value: _ChartRange.year, label: Text('年')),
                    ],
                    selected: {_range},
                    onSelectionChanged: (value) {
                      setState(() => _range = value.first);
                    },
                  ),
                  if (units.length > 1) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final item in units)
                          ChoiceChip(
                            label: Text(item.label),
                            selected: unit == item,
                            onSelected: (_) => setState(() => _unit = item),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: maxSpots.spots.isEmpty
                        ? Center(
                            child: Text(
                              '所选时间范围内没有可统计的重量',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: maxSpots.days.toDouble() - 1,
                              minY: 0,
                              maxY: maxSpots.maxY * 1.18,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: _gridInterval(
                                  maxSpots.maxY,
                                ),
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withAlpha(70),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 34,
                                    getTitlesWidget: (value, meta) => Text(
                                      formatWeight(value),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: _bottomInterval(maxSpots.days),
                                    getTitlesWidget: (value, meta) {
                                      final day = maxSpots.start.add(
                                        Duration(days: value.toInt()),
                                      );
                                      if (day.isAfter(maxSpots.today)) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          _range == _ChartRange.year
                                              ? '${day.month}月'
                                              : '${day.month}/${day.day}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(fontSize: 9),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (spots) {
                                    return spots.map((spot) {
                                      final day = maxSpots.start.add(
                                        Duration(days: spot.x.toInt()),
                                      );
                                      return LineTooltipItem(
                                        '${formatDate(day)}\n'
                                        '${formatWeight(spot.y)} ${unit?.label ?? ''}',
                                        TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: maxSpots.spots,
                                  isCurved: true,
                                  curveSmoothness: 0.2,
                                  barWidth: 3,
                                  color: kPrimaryBlue,
                                  dotData: FlDotData(
                                    show: maxSpots.spots.length <= 31,
                                    getDotPainter:
                                        (spot, percent, bar, index) =>
                                            FlDotCirclePainter(
                                              radius: 3.2,
                                              color: kPrimaryBlue,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        kPrimaryBlue.withAlpha(80),
                                        kPrimaryBlue.withAlpha(4),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (rows.isEmpty)
              const AppSectionCard(
                child: EmptyState(
                  icon: Icons.history,
                  title: '还没有该动作的记录',
                  message: '可以换一个健身房或动作看看。',
                ),
              )
            else
              for (final group in _groupByDate(rows))
                _ProgressDateCard(group: group),
          ],
        ],
      ),
    );
  }

  _DailyMax _dailyMaxSpots(List<_ProgressRow> rows, WeightUnit? unit) {
    final today = dateOnly(DateTime.now());
    final days = switch (_range) {
      _ChartRange.week => 7,
      _ChartRange.month => 30,
      _ChartRange.year => 365,
    };
    final start = today.subtract(Duration(days: days - 1));
    final byDay = <String, double>{};
    if (unit != null) {
      for (final row in rows) {
        if (WeightUnit.fromIndex(row.set.weightUnitIndex) != unit) continue;
        final value = row.set.weightValue;
        if (value == null) continue;
        final day = dateOnly(row.entry.date);
        if (day.isBefore(start) || day.isAfter(today)) continue;
        final key = formatDate(day);
        final current = byDay[key] ?? 0;
        if (value > current) byDay[key] = value;
      }
    }
    final entries = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final spots = <FlSpot>[];
    var maxY = 1.0;
    for (final entry in entries) {
      final day = DateTime.parse(entry.key);
      spots.add(FlSpot(day.difference(start).inDays.toDouble(), entry.value));
      if (entry.value > maxY) maxY = entry.value;
    }
    return _DailyMax(
      start: start,
      today: today,
      days: days,
      spots: spots,
      maxY: maxY,
    );
  }

  double _gridInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 200) return 25;
    return 50;
  }

  double _bottomInterval(int days) {
    if (days <= 7) return 1;
    if (days <= 31) return 5;
    return 60;
  }

  List<_DayGroup> _groupByDate(List<_ProgressRow> rows) {
    final map = <String, _DayGroup>{};
    for (final row in rows) {
      final key = formatDate(row.entry.date);
      map
          .putIfAbsent(
            key,
            () => _DayGroup(
              date: row.entry.date,
              gymName: row.gym.name,
              bodyPart: row.entry.bodyPart,
              rows: <_ProgressRow>[],
            ),
          )
          .rows
          .add(row);
    }
    final groups = map.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }
}

class _ProgressRow {
  const _ProgressRow({
    required this.entry,
    required this.set,
    required this.gym,
  });

  final TrainingEntry entry;
  final TrainingSet set;
  final Gym gym;
}

class _DayGroup {
  _DayGroup({
    required this.date,
    required this.gymName,
    required this.bodyPart,
    required this.rows,
  });

  final DateTime date;
  final String gymName;
  final String bodyPart;
  final List<_ProgressRow> rows;
}

class _DailyMax {
  const _DailyMax({
    required this.start,
    required this.today,
    required this.days,
    required this.spots,
    required this.maxY,
  });

  final DateTime start;
  final DateTime today;
  final int days;
  final List<FlSpot> spots;
  final double maxY;
}

class _ProgressDateCard extends StatelessWidget {
  const _ProgressDateCard({required this.group});

  final _DayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatDate(group.date),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                weekdayZh(group.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                group.gymName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            group.bodyPart,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 14),
          for (final row in group.rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${row.set.groupCount} 组 × '
                      '${formatWeightValue(row.set.weightValue, WeightUnit.fromIndex(row.set.weightUnitIndex), raw: row.set.weightRaw)} × ${row.set.reps} 次',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            row.set.weightValue == null &&
                                row.set.weightRaw.isNotEmpty
                            ? theme.colorScheme.error
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (row.set.note.trim().isNotEmpty)
                    Flexible(
                      child: Text(
                        row.set.note.trim(),
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
