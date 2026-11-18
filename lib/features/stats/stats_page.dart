import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../core/weight.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/ledger.dart';

enum _StatsRange { week, month, year }

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  _StatsRange _range = _StatsRange.week;
  int _pageOffset = 0;
  DateTime? _selectedDay;
  DateTime? _selectedMonth;
  Timer? _holdTimer;
  int _holdDirection = 0;
  int _holdCount = 0;

  @override
  void dispose() {
    _stopHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final today = dateOnly(DateTime.now());
    final period = _period(today);
    final setsInPeriod = store.sets.where((set) {
      final day = dateOnly(set.date);
      return !day.isBefore(period.start) && !day.isAfter(period.end);
    }).toList();
    final entriesInPeriod = store.entries.where((entry) {
      final day = dateOnly(entry.date);
      return !day.isBefore(period.start) && !day.isAfter(period.end);
    }).toList();
    final trainingDates = <String>{};
    for (final set in setsInPeriod) {
      trainingDates.add(formatDate(set.date));
    }
    final totalGroups = setsInPeriod.fold<int>(
      0,
      (sum, set) => sum + set.groupCount,
    );
    final totalReps = setsInPeriod.fold<int>(
      0,
      (sum, set) => sum + set.groupCount * set.reps,
    );
    final buckets = _buckets(period, setsInPeriod);
    final canGoNext = _pageOffset < 0;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kInk,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Text(
              '统计',
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 40),
            ),
            const SizedBox(height: 4),
            Text(
              '只统计已经写下的重量与组。片 / kg / lb 分开累计。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: kSteel,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 20),
            _RangeTabs(
              value: _range,
              onChanged: (value) {
                _stopHold();
                setState(() {
                  _range = value;
                  _pageOffset = 0;
                  _selectedDay = null;
                  _selectedMonth = null;
                });
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _MetricStat(value: '${trainingDates.length}', label: '训练天数'),
                const _MetricDivider(),
                _MetricStat(value: '$totalGroups', label: '总组数'),
                const _MetricDivider(),
                _MetricStat(value: '$totalReps', label: '总次数'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: const BoxDecoration(
                color: kCarbon,
                border: Border(
                  top: BorderSide(color: kSafetyOrange, width: 1.5),
                  bottom: BorderSide(color: kLine),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LedgerArrow(
                        left: true,
                        onTap: () => _changePeriod(-1),
                        onLongPressStart: () => _startHold(-1),
                        onLongPressEnd: _stopHold,
                        onLongPressCancel: _stopHold,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '训练天数',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _periodLabel(period),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: kSteel,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LedgerArrow(
                        left: false,
                        enabled: canGoNext,
                        onTap: () => _changePeriod(1),
                        onLongPressStart: () => _startHold(1),
                        onLongPressEnd: _stopHold,
                        onLongPressCancel: _stopHold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: _handleSwipe,
                    child: SizedBox(
                      height: 195,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final plotWidth = (constraints.maxWidth - 24).clamp(
                            1.0,
                            4000.0,
                          );
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) {
                              final dx = (details.localPosition.dx - 24).clamp(
                                0.0,
                                plotWidth,
                              );
                              final index =
                                  (dx / plotWidth * buckets.items.length)
                                      .floor()
                                      .clamp(0, buckets.items.length - 1);
                              _onBarTap(index, period, buckets);
                            },
                            child: BarChart(
                              BarChartData(
                                minY: 0,
                                maxY: buckets.maxValue < 1
                                    ? 1
                                    : buckets.maxValue.toDouble(),
                                alignment: BarChartAlignment.spaceAround,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchCallback: (event, response) {
                                    if (event is FlTapUpEvent &&
                                        response?.spot != null) {
                                      _onBarTap(
                                        response!.spot!.touchedBarGroupIndex,
                                        period,
                                        buckets,
                                      );
                                    }
                                  },
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          final bucket = buckets.items[group.x];
                                          return BarTooltipItem(
                                            '${bucket.tooltip}\n'
                                            '${rod.toY.toInt()} 天',
                                            TextStyle(
                                              color: kChalk,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: buckets.maxValue > 7
                                      ? 5
                                      : 1,
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
                                      reservedSize: 24,
                                      interval: buckets.maxValue > 7 ? 5 : 1,
                                      getTitlesWidget: (value, meta) => Text(
                                        value.toInt().toString(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(color: kSteel),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= buckets.items.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final item = buckets.items[index];
                                        if (!item.showLabel) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                          ),
                                          child: Text(
                                            item.label,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
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
                                barGroups: [
                                  for (var i = 0; i < buckets.items.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: buckets.items[i].value
                                              .toDouble(),
                                          width: buckets.items.length > 20
                                              ? 6
                                              : 18,
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                          color:
                                              _isSelectedBucket(
                                                buckets.items[i],
                                              )
                                              ? kChalk
                                              : (buckets.items[i].value > 0
                                                    ? kSafetyOrange
                                                    : kLine),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '左右滑动翻页  ·  长按箭头连续翻页',
                    style: theme.textTheme.labelSmall?.copyWith(color: kSteel),
                  ),
                ],
              ),
            ),
            if (_range == _StatsRange.year && _selectedMonth != null)
              _YearDayPicker(
                month: _selectedMonth!,
                selectedDay: _selectedDay,
                trainingDays: _trainingDaysInMonth(
                  _selectedMonth!,
                  setsInPeriod,
                ),
                onSelected: (day) => setState(() => _selectedDay = day),
              ),
            if (_selectedDay == null)
              _ChartHint(
                text: _range == _StatsRange.year
                    ? '点击上方月份，再选择具体日期。'
                    : '点击柱状图里的日期，查看当天容量。',
              )
            else
              _DailyVolume(
                day: _selectedDay!,
                entries: entriesInPeriod,
                store: store,
              ),
            const SizedBox(height: 20),
            const LedgerRule(),
            const SizedBox(height: 12),
            Text(
              '累计容量 = 重量 × 组数 × 次数。不同动作分开显示，'
              '未填写或未识别重量的组不计入。',
              style: theme.textTheme.labelSmall?.copyWith(
                color: kSteel,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startHold(int direction) {
    if (direction > 0 && _pageOffset >= 0) return;
    _stopHold();
    _holdDirection = direction;
    _holdCount = 0;
    _changePeriod(direction);
    _scheduleHoldTick();
  }

  void _scheduleHoldTick() {
    final delay = (300 - _holdCount * 35).clamp(70, 300);
    _holdTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (_holdDirection > 0 && _pageOffset >= 0) {
        _stopHold();
        return;
      }
      _holdCount++;
      _changePeriod(_holdDirection);
      _scheduleHoldTick();
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdDirection = 0;
    _holdCount = 0;
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200) {
      if (_pageOffset < 0) _changePeriod(1);
    } else if (velocity > 200) {
      _changePeriod(-1);
    }
  }

  void _changePeriod(int delta) {
    final next = _pageOffset + delta;
    if (next > 0) return;
    setState(() {
      _pageOffset = next;
      _selectedDay = null;
      _selectedMonth = null;
    });
  }

  _Period _period(DateTime today) {
    switch (_range) {
      case _StatsRange.week:
        final monday = dateOnly(
          today.subtract(Duration(days: today.weekday - 1)),
        );
        final start = monday.add(Duration(days: _pageOffset * 7));
        return _Period(start: start, end: start.add(const Duration(days: 6)));
      case _StatsRange.month:
        final start = DateTime(today.year, today.month + _pageOffset, 1);
        final end = DateTime(start.year, start.month + 1, 0);
        return _Period(start: start, end: end);
      case _StatsRange.year:
        final start = DateTime(today.year + _pageOffset, 1, 1);
        final end = DateTime(start.year, 12, 31);
        return _Period(start: start, end: end);
    }
  }

  String _periodLabel(_Period period) {
    switch (_range) {
      case _StatsRange.week:
        if (period.start.year == period.end.year) {
          return '${period.start.year}年${period.start.month}月${period.start.day}日 - '
              '${period.end.month}月${period.end.day}日';
        }
        return '${formatDate(period.start)} - ${formatDate(period.end)}';
      case _StatsRange.month:
        return '${period.start.year}年${period.start.month}月';
      case _StatsRange.year:
        return '${period.start.year}年';
    }
  }

  _Buckets _buckets(_Period period, List<TrainingSet> sets) {
    final items = <_Bucket>[];
    final trainingDates = sets.map((set) => formatDate(set.date)).toSet();
    switch (_range) {
      case _StatsRange.week:
        for (var i = 0; i < 7; i++) {
          final day = period.start.add(Duration(days: i));
          items.add(
            _Bucket(
              value: trainingDates.contains(formatDate(day)) ? 1 : 0,
              label: weekdayZh(day).replaceAll('周', ''),
              tooltip: '${formatDate(day)} ${weekdayZh(day)}',
              date: day,
              showLabel: true,
            ),
          );
        }
        break;
      case _StatsRange.month:
        final dayCount = period.end.day;
        for (var i = 1; i <= dayCount; i++) {
          final day = DateTime(period.start.year, period.start.month, i);
          items.add(
            _Bucket(
              value: trainingDates.contains(formatDate(day)) ? 1 : 0,
              label: '$i',
              tooltip: formatDate(day),
              date: day,
              showLabel:
                  i == 1 || i == dayCount || (i % 5 == 0 && i <= dayCount - 2),
            ),
          );
        }
        break;
      case _StatsRange.year:
        for (var month = 1; month <= 12; month++) {
          final count = trainingDates.where((value) {
            final date = DateTime.parse(value);
            return date.year == period.start.year && date.month == month;
          }).length;
          items.add(
            _Bucket(
              value: count,
              label: '$month月',
              tooltip: '${period.start.year}年$month月',
              month: month,
              showLabel: true,
            ),
          );
        }
        break;
    }
    var maxValue = 1;
    for (final item in items) {
      if (item.value > maxValue) maxValue = item.value;
    }
    return _Buckets(items: items, maxValue: maxValue);
  }

  void _onBarTap(int index, _Period period, _Buckets buckets) {
    if (index < 0 || index >= buckets.items.length) return;
    final item = buckets.items[index];
    if (_range == _StatsRange.year) {
      final month = DateTime(period.start.year, item.month ?? 1, 1);
      final trainingDays = _trainingDaysInMonth(
        month,
        context.read<FitnessStore>().sets,
      );
      DateTime? selected;
      if (trainingDays.isNotEmpty) {
        selected = trainingDays.last;
      }
      setState(() {
        _selectedMonth = month;
        _selectedDay = selected;
      });
    } else {
      setState(() {
        _selectedDay = item.date;
        _selectedMonth = null;
      });
    }
  }

  bool _isSelectedBucket(_Bucket bucket) {
    if (_range == _StatsRange.year) {
      return _selectedMonth != null && _selectedMonth!.month == bucket.month;
    }
    return bucket.date != null &&
        _selectedDay != null &&
        isSameDate(bucket.date!, _selectedDay!);
  }

  List<DateTime> _trainingDaysInMonth(DateTime month, List<TrainingSet> sets) {
    final result = <DateTime>[];
    final seen = <String>{};
    for (final set in sets) {
      if (set.date.year != month.year || set.date.month != month.month) {
        continue;
      }
      final key = formatDate(set.date);
      if (seen.add(key)) result.add(dateOnly(set.date));
    }
    result.sort();
    return result;
  }
}

class _Period {
  const _Period({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _Bucket {
  const _Bucket({
    required this.value,
    required this.label,
    required this.tooltip,
    required this.showLabel,
    this.date,
    this.month,
  });

  final int value;
  final String label;
  final String tooltip;
  final bool showLabel;
  final DateTime? date;
  final int? month;
}

class _Buckets {
  const _Buckets({required this.items, required this.maxValue});

  final List<_Bucket> items;
  final int maxValue;
}

class _RangeTabs extends StatelessWidget {
  const _RangeTabs({required this.value, required this.onChanged});

  final _StatsRange value;
  final ValueChanged<_StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    const entries = [
      (_StatsRange.week, '周'),
      (_StatsRange.month, '月'),
      (_StatsRange.year, '年'),
    ];
    return Row(
      children: [
        for (final entry in entries)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(entry.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == entry.$1 ? kSafetyOrange : kLine,
                      width: value == entry.$1 ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  entry.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: value == entry.$1 ? kChalk : kSteel,
                    letterSpacing: 2,
                    fontWeight: value == entry.$1
                        ? FontWeight.w700
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

class _MetricStat extends StatelessWidget {
  const _MetricStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 30,
              height: 1,
              color: kChalk,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: kSteel, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: kLine,
    );
  }
}

class _ChartHint extends StatelessWidget {
  const _ChartHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kLineSoft),
          bottom: BorderSide(color: kLineSoft),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kSteel),
      ),
    );
  }
}

class _YearDayPicker extends StatelessWidget {
  const _YearDayPicker({
    required this.month,
    required this.selectedDay,
    required this.trainingDays,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime? selectedDay;
  final List<DateTime> trainingDays;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kLineSoft),
          bottom: BorderSide(color: kLineSoft),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${month.year}年${month.month}月训练日',
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              color: kChalk,
            ),
          ),
          const SizedBox(height: 10),
          if (trainingDays.isEmpty)
            Text(
              '这个月暂无训练记录。',
              style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final day in trainingDays)
                  InkWell(
                    onTap: () => onSelected(day),
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            selectedDay != null && isSameDate(selectedDay!, day)
                            ? kSafetyOrange
                            : Colors.transparent,
                        border: Border.all(
                          color:
                              selectedDay != null &&
                                  isSameDate(selectedDay!, day)
                              ? kSafetyOrange
                              : kLine,
                        ),
                      ),
                      child: Text(
                        '${day.day}日',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              selectedDay != null &&
                                  isSameDate(selectedDay!, day)
                              ? kInk
                              : kChalk,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DailyVolume extends StatelessWidget {
  const _DailyVolume({
    required this.day,
    required this.entries,
    required this.store,
  });

  final DateTime day;
  final List<TrainingEntry> entries;
  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final dayEntries = entries
        .where((entry) => isSameDate(entry.date, day))
        .toList();
    final rows = <_ActionVolume>[];
    for (final entry in dayEntries) {
      final sets = store.setsForEntry(entry.id);
      final volumes = <WeightUnit, double>{};
      for (final set in sets) {
        final unit = WeightUnit.fromIndex(set.weightUnitIndex);
        final value = set.weightValue;
        if (unit == null || value == null) continue;
        volumes[unit] =
            (volumes[unit] ?? 0) + value * set.groupCount * set.reps;
      }
      if (volumes.isNotEmpty) {
        rows.add(
          _ActionVolume(
            entry: entry,
            gymName: store.gymById(entry.gymId)?.name ?? '未知健身房',
            volumes: volumes,
          ),
        );
      }
    }
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kSafetyOrange, width: 1.5),
          bottom: BorderSide(color: kLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '当日累计容量',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
                ),
              ),
              Text(
                formatDate(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kSteel,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Text(
              '当天没有可计算容量的重量数据。',
              style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
            )
          else
            for (final row in rows)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: kLineSoft)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.entry.exerciseName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        color: kChalk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${row.entry.bodyPart} · ${row.gymName}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: kSteel,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final unit in WeightUnit.values)
                          if ((row.volumes[unit] ?? 0) > 0)
                            Text(
                              '${formatWeight(row.volumes[unit])} ${unit.label}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: kSafetyOrange,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ActionVolume {
  const _ActionVolume({
    required this.entry,
    required this.gymName,
    required this.volumes,
  });

  final TrainingEntry entry;
  final String gymName;
  final Map<WeightUnit, double> volumes;
}
