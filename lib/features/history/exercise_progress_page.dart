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
import '../../widgets/ledger.dart';

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

  Future<void> _pickGym(FitnessStore store) async {
    final picked = await _showChoice<int>(
      title: '选择健身房',
      options: [
        const _Choice<int>(value: 0, label: '全部健身房'),
        for (final gym in store.gyms)
          _Choice<int>(value: gym.id, label: gym.name),
      ],
      selected: _gymId ?? 0,
    );
    if (picked == null) return;
    setState(() {
      _gymId = picked == 0 ? null : picked;
      _exerciseName = null;
      _unit = null;
    });
  }

  Future<void> _pickExercise(List<String> names) async {
    final picked = await _showChoice<String>(
      title: '选择动作',
      options: [
        for (final name in names) _Choice<String>(value: name, label: name),
      ],
      selected: _exerciseName,
    );
    if (picked == null) return;
    setState(() {
      _exerciseName = picked;
      _unit = null;
    });
  }

  Future<T?> _showChoice<T>({
    required String title,
    required List<_Choice<T>> options,
    T? selected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: kCarbon,
      barrierColor: kInk.withAlpha(210),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kSafetyOrange, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(
                            sheetContext,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('×'),
                      ),
                    ],
                  ),
                ),
                const LedgerRule(),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        InkWell(
                          onTap: () =>
                              Navigator.pop(sheetContext, option.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: kLineSoft),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: kChalk,
                                    ),
                                  ),
                                ),
                                if (option.value == selected)
                                  const Text(
                                    '当前',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: kSafetyOrange,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final names = _exerciseNames(store);
    final rows = _rows(store);
    final units = _availableUnits(rows);
    final unit = _effectiveUnit(units);
    final maxSpots = _dailyMaxSpots(rows, unit);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Row(
              children: [
                LedgerBackButton(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 10),
                const Text(
                  'PROGRESS / 动作变化',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSteel,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LedgerPageHeader(
              title: '动作变化',
              subtitle: _exerciseName == null
                  ? '选择动作，查看最大重量'
                  : '$_exerciseName · ${rows.length} 行组记录',
            ),
            const SizedBox(height: 14),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: kLine),
                  bottom: BorderSide(color: kLine),
                ),
              ),
              child: Column(
                children: [
                  _SelectRow(
                    label: '健身房',
                    value: _gymId == null
                        ? '全部健身房'
                        : store.gymById(_gymId!)?.name ?? '未知健身房',
                    onTap: () => _pickGym(store),
                  ),
                  _SelectRow(
                    label: '动作',
                    value: _exerciseName ?? '未选择',
                    enabled: names.isNotEmpty,
                    onTap: () => _pickExercise(names),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '折线图展示所选动作的“当日最大重量”。不同重量单位不合并；'
              '无法识别的重量不参与统计。',
              style: TextStyle(fontSize: 11, height: 1.6, color: kSteel),
            ),
            const SizedBox(height: 22),
            if (_exerciseName == null)
              const EmptyState(
                icon: Icons.show_chart,
                title: '先选择一个动作',
                message: '选择动作后，上方会显示最大重量折线图，下方按日期合并组记录。',
              )
            else ...[
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: kSafetyOrange, width: 1.5),
                    bottom: BorderSide(color: kLine),
                    left: BorderSide(color: kLine),
                    right: BorderSide(color: kLine),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '当日最大重量',
                            style: TextStyle(
                              fontSize: 15,
                              color: kChalk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unit != null)
                          Text(
                            unit.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: kSafetyOrange,
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RangeTabs(
                      value: _range,
                      onChanged: (value) => setState(() => _range = value),
                    ),
                    if (units.length > 1) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final item in units)
                            InkWell(
                              onTap: () => setState(() => _unit = item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: unit == item
                                      ? kSafetyOrange
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: unit == item ? kSafetyOrange : kLine,
                                  ),
                                ),
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: unit == item ? kInk : kSteel,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 190,
                      child: maxSpots.spots.isEmpty
                          ? const Center(
                              child: Text(
                                '所选时间范围内没有可统计的重量',
                                style: TextStyle(fontSize: 12, color: kSteel),
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
                                  getDrawingHorizontalLine: (value) =>
                                      const FlLine(
                                        color: kLineSoft,
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
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: kSteel,
                                        ),
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
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                          ),
                                          child: Text(
                                            _range == _ChartRange.year
                                                ? '${day.month}月'
                                                : '${day.month}/${day.day}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: kSteel,
                                            ),
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
                                          const TextStyle(
                                            color: kChalk,
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
                                    barWidth: 2,
                                    color: kSafetyOrange,
                                    dotData: FlDotData(
                                      show: maxSpots.spots.length <= 31,
                                      getDotPainter:
                                          (spot, percent, bar, index) =>
                                              FlDotCirclePainter(
                                                radius: 3,
                                                color: kSafetyOrange,
                                                strokeWidth: 2,
                                                strokeColor: kCarbon,
                                              ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          kSafetyOrange.withAlpha(46),
                                          kSafetyOrange.withAlpha(0),
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
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    '历史记录',
                    style: TextStyle(
                      fontSize: 10,
                      color: kSafetyOrange,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Divider(height: 1, color: kLineSoft)),
                  const SizedBox(width: 12),
                  Text(
                    '${_groupByDate(rows).length} 天',
                    style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
                  ),
                ],
              ),
              if (rows.isEmpty)
                const EmptyState(
                  icon: Icons.history,
                  title: '还没有该动作的记录',
                  message: '可以换一个健身房或动作看看。',
                )
              else
                for (final group in _groupByDate(rows))
                  _ProgressDateSection(group: group),
            ],
          ],
        ),
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

class _Choice<T> {
  const _Choice({required this.value, required this.label});

  final T value;
  final String label;
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: kSteel,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? kChalk : kSteel,
                ),
              ),
            ),
            const Text('›', style: TextStyle(fontSize: 20, color: kSteel)),
          ],
        ),
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  const _RangeTabs({required this.value, required this.onChanged});

  final _ChartRange value;
  final ValueChanged<_ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final range in _ChartRange.values)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(range),
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == range ? kSafetyOrange : kLineSoft,
                      width: value == range ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  switch (range) {
                    _ChartRange.week => '周',
                    _ChartRange.month => '月',
                    _ChartRange.year => '年',
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: value == range ? kChalk : kSteel,
                    fontWeight: value == range
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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

class _ProgressDateSection extends StatelessWidget {
  const _ProgressDateSection({required this.group});

  final _DayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kLine),
          bottom: BorderSide(color: kLineSoft),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatDate(group.date).substring(5),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  color: kChalk,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                weekdayZh(group.date),
                style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  group.gymName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            group.bodyPart,
            style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
          ),
          const SizedBox(height: 6),
          for (final row in group.rows)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${row.set.groupCount} 组 × '
                      '${formatWeightValue(row.set.weightValue, WeightUnit.fromIndex(row.set.weightUnitIndex), raw: row.set.weightRaw)} × ${row.set.reps} 次',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color:
                            row.set.weightValue == null &&
                                row.set.weightRaw.isNotEmpty
                            ? kDangerRed
                            : kChalk,
                      ),
                    ),
                  ),
                  if (row.set.note.trim().isNotEmpty)
                    Flexible(
                      child: Text(
                        row.set.note.trim(),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: kSteel,
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
