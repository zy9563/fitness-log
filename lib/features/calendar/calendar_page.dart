import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/edge_fade_list_view.dart';
import '../training/day_training_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = dateOnly(DateTime.now());
  DateTime _selectedDay = dateOnly(DateTime.now());
  PageController? _calendarController;
  Timer? _holdTimer;
  Timer? _suppressSelectionTimer;
  int _holdDirection = 0;
  int _holdCount = 0;
  bool _suppressSelection = false;

  static const _lastCalendarPage = (2100 - 2000) * 12 + 11;

  @override
  void dispose() {
    _stopHold();
    _suppressSelectionTimer?.cancel();
    super.dispose();
  }

  void _turnPage(int direction, {bool accelerated = false}) {
    final controller = _calendarController;
    if (controller == null || !controller.hasClients) {
      setState(() {
        _focusedDay = DateTime(
          _focusedDay.year,
          _focusedDay.month + direction,
          1,
        );
      });
      return;
    }
    final current = (controller.page ?? controller.initialPage.toDouble())
        .round();
    final target = (current + direction).clamp(0, _lastCalendarPage).toInt();
    if (target == current) return;
    controller.animateToPage(
      target,
      duration: Duration(milliseconds: accelerated ? 130 : 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _startHold(int direction) {
    _stopHold();
    _suppressSelectionTimer?.cancel();
    _suppressSelection = true;
    _holdDirection = direction;
    _holdCount = 0;
    // 长按后立即翻一页，随后间隔逐次缩短，形成连续加速。
    _turnPage(direction, accelerated: true);
    _scheduleHoldTick();
  }

  void _scheduleHoldTick() {
    final delay = (300 - _holdCount * 35).clamp(70, 300);
    _holdTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _holdCount++;
      _turnPage(_holdDirection, accelerated: true);
      _scheduleHoldTick();
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_suppressSelection) {
      _suppressSelectionTimer?.cancel();
      // 页面上移后，手指抬起的位置可能落到新的日期格上；短暂吞掉这次选择。
      _suppressSelectionTimer = Timer(const Duration(milliseconds: 380), () {
        _suppressSelection = false;
      });
    }
  }

  Future<void> _openDay(DateTime day) async {
    final store = context.read<FitnessStore>();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DayTrainingPage(
          date: dateOnly(day),
          initialGymId: store.latestGymIdForDate(day),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final selectedEntries = store.entriesForDate(_selectedDay);
    final gyms = store.gymsWithEntriesOn(_selectedDay);

    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('健身记录'),
        actions: [
          IconButton(
            tooltip: '回到今天',
            onPressed: () {
              final today = dateOnly(DateTime.now());
              setState(() {
                _focusedDay = today;
                _selectedDay = today;
              });
            },
            icon: const Icon(Icons.today_outlined),
          ),
        ],
      ),
      body: EdgeFadeListView(
        padding: EdgeInsets.fromLTRB(12, topInset, 12, 120),
        topFadeHeight: topInset + 16,
        bottomFadeHeight: 130,
        children: [
          AppSectionCard(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            elevated: true,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                  child: Row(
                    children: [
                      _CalendarArrow(
                        icon: Icons.chevron_left,
                        tooltip: '上个月',
                        onTap: () => _turnPage(-1),
                        onHoldStart: () => _startHold(-1),
                        onHoldEnd: _stopHold,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${_focusedDay.year}年${_focusedDay.month}月',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      _CalendarArrow(
                        icon: Icons.chevron_right,
                        tooltip: '下个月',
                        onTap: () => _turnPage(1),
                        onHoldStart: () => _startHold(1),
                        onHoldEnd: _stopHold,
                      ),
                    ],
                  ),
                ),
                TableCalendar<TrainingEntry>(
                  locale: 'zh_CN',
                  firstDay: DateTime(2000, 1, 1),
                  lastDay: DateTime(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDate(day, _selectedDay),
                  eventLoader: store.entriesForDate,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: '月'},
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerVisible: false,
                  onCalendarCreated: (controller) =>
                      _calendarController = controller,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.all(4),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders<TrainingEntry>(
                    markerBuilder: (context, day, entries) {
                      if (entries.isEmpty) return null;
                      final allCompleted = entries.every(
                        (entry) => entry.completed,
                      );
                      return Container(
                        width: 18,
                        height: 4,
                        decoration: BoxDecoration(
                          color: allCompleted ? kPrimaryBlue : kWarmYellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (_suppressSelection) return;
                    setState(() {
                      _selectedDay = dateOnly(selectedDay);
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    if (mounted) {
                      setState(() => _focusedDay = focusedDay);
                    } else {
                      _focusedDay = focusedDay;
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SectionTitle(
            '${formatDateChinese(_selectedDay)} ${weekdayZh(_selectedDay)}',
            subtitle: selectedEntries.isEmpty
                ? '还没有训练记录'
                : '${gyms.length} 个健身房 · ${selectedEntries.length} 个动作 · '
                      '${selectedEntries.fold<int>(0, (sum, entry) => sum + store.totalGroupCountForEntry(entry.id))} 组',
            trailing: TextButton(
              onPressed: () => _openDay(_selectedDay),
              child: const Text('记录'),
            ),
          ),
          if (selectedEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(
                '当天暂无训练记录，点右下角 + 记录这一天。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final entry in selectedEntries)
              _EntrySummary(
                entry: entry,
                gymName: store.gymById(entry.gymId)?.name ?? '',
                sets: store.setsForEntry(entry.id),
                onTap: () => _openDay(_selectedDay),
              ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 82),
        child: FloatingActionButton(
          tooltip: '记录 ${formatDate(_selectedDay)}',
          onPressed: () => _openDay(_selectedDay),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPressStart: (_) => onHoldStart(),
          onLongPressEnd: (_) => onHoldEnd(),
          onLongPressCancel: onHoldEnd,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withAlpha(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}

class _EntrySummary extends StatelessWidget {
  const _EntrySummary({
    required this.entry,
    required this.gymName,
    required this.sets,
    required this.onTap,
  });

  final TrainingEntry entry;
  final String gymName;
  final List<TrainingSet> sets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final groupCount = sets.fold<int>(0, (sum, set) => sum + set.groupCount);
    return AppSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.exerciseName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$gymName · ${entry.bodyPart} · $groupCount 组',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            entry.completed ? Icons.check_circle : Icons.chevron_right,
            color: entry.completed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
