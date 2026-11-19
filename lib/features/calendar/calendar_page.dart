import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/date_x.dart';
import '../../core/theme.dart';
import '../../data/fitness_store.dart';
import '../../data/models/training_entry.dart';
import '../../data/models/training_set.dart';
import '../../widgets/ledger.dart';
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
  static const _monthNames = [
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月',
  ];

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

  void _goToday() {
    final today = dateOnly(DateTime.now());
    setState(() {
      _focusedDay = today;
      _selectedDay = today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitnessStore>();
    final selectedEntries = store.entriesForDate(_selectedDay);
    final gyms = store.gymsWithEntriesOn(_selectedDay);
    final groupCount = selectedEntries.fold<int>(
      0,
      (sum, entry) => sum + store.totalGroupCountForEntry(entry.id),
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kInk,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '健身记录',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 40,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _goToday,
                  style: TextButton.styleFrom(
                    foregroundColor: kSteel,
                    minimumSize: const Size(52, 36),
                  ),
                  child: const Text('今天'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _MonthLedger(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onCalendarCreated: (controller) =>
                  _calendarController = controller,
              onTurn: _turnPage,
              onHoldStart: _startHold,
              onHoldEnd: _stopHold,
              store: store,
              onSelect: (selectedDay, focusedDay) {
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
            const SizedBox(height: 24),
            _DayMasthead(
              day: _selectedDay,
              countText: selectedEntries.isEmpty
                  ? '0 个动作 · 0 组'
                  : '${gyms.length} 个健身房 · ${selectedEntries.length} 个动作 · $groupCount 组',
              onOpen: () => _openDay(_selectedDay),
            ),
            if (selectedEntries.isEmpty)
              _EmptyDay(onOpen: () => _openDay(_selectedDay))
            else ...[
              const LedgerRule(),
              for (final entry in selectedEntries)
                _EntryRow(
                  entry: entry,
                  gymName: store.gymById(entry.gymId)?.name ?? '',
                  presetNote: store.presetForEntry(entry)?.note.trim() ?? '',
                  sets: store.setsForEntry(entry.id),
                  onTap: () => _openDay(_selectedDay),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthLedger extends StatelessWidget {
  const _MonthLedger({
    required this.focusedDay,
    required this.selectedDay,
    required this.onCalendarCreated,
    required this.onTurn,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.store,
    required this.onSelect,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<PageController> onCalendarCreated;
  final void Function(int direction, {bool accelerated}) onTurn;
  final void Function(int direction) onHoldStart;
  final VoidCallback onHoldEnd;
  final FitnessStore store;
  final void Function(DateTime selectedDay, DateTime focusedDay) onSelect;
  final void Function(DateTime focusedDay) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: kCarbon,
        border: Border(
          top: BorderSide(color: kSafetyOrange, width: 1.5),
          bottom: BorderSide(color: kLine),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _CalendarPageState._monthNames[focusedDay.month - 1],
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${focusedDay.year}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: kSteel,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                LedgerArrow(
                  left: true,
                  onTap: () => onTurn(-1),
                  onLongPressStart: () => onHoldStart(-1),
                  onLongPressEnd: onHoldEnd,
                  onLongPressCancel: onHoldEnd,
                ),
                const SizedBox(width: 8),
                LedgerArrow(
                  left: false,
                  onTap: () => onTurn(1),
                  onLongPressStart: () => onHoldStart(1),
                  onLongPressEnd: onHoldEnd,
                  onLongPressCancel: onHoldEnd,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TableCalendar<TrainingEntry>(
            locale: 'zh_CN',
            firstDay: DateTime(2000, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDate(day, selectedDay),
            eventLoader: store.entriesForDate,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: '月'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekHeight: 30,
            rowHeight: 47,
            onCalendarCreated: onCalendarCreated,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: kSteel, fontSize: 11.5),
              weekendStyle: TextStyle(color: kSteel, fontSize: 11.5),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(2),
              cellPadding: EdgeInsets.zero,
              defaultTextStyle: const TextStyle(
                color: kChalk,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: const TextStyle(color: kSteel, fontSize: 14),
              todayDecoration: BoxDecoration(
                border: Border.all(color: kChalk, width: 1),
                shape: BoxShape.rectangle,
              ),
              todayTextStyle: const TextStyle(
                color: kChalk,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: const BoxDecoration(
                color: kSafetyOrange,
                shape: BoxShape.rectangle,
              ),
              selectedTextStyle: const TextStyle(
                color: kInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            calendarBuilders: CalendarBuilders<TrainingEntry>(
              markerBuilder: (context, day, entries) {
                if (isSameDate(day, selectedDay)) {
                  return const SizedBox.shrink();
                }
                if (entries.isEmpty) {
                  return null;
                }
                final allCompleted = entries.every((entry) => entry.completed);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 10,
                    height: 2,
                    color: allCompleted ? kSafetyOrange : kChalk,
                  ),
                );
              },
            ),
            onDaySelected: onSelect,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

class _DayMasthead extends StatelessWidget {
  const _DayMasthead({
    required this.day,
    required this.countText,
    required this.onOpen,
  });

  final DateTime day;
  final String countText;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date =
        '${day.month.toString().padLeft(2, '0')}.${day.day.toString().padLeft(2, '0')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: theme.textTheme.displaySmall?.copyWith(fontSize: 36)),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            weekdayZh(day),
            style: theme.textTheme.labelSmall?.copyWith(
              color: kSteel,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const Spacer(),
        TextButton(onPressed: onOpen, child: const Text('记录  +')),
      ],
    ).withSubtitle(context, countText);
  }
}

extension on Widget {
  Widget withSubtitle(BuildContext context, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this,
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: kSteel, height: 1.5),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LedgerRule(),
          const SizedBox(height: 16),
          Text(
            '今天还没有记录。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: kSteel),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onOpen,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '从第一个动作开始  →',
                style: TextStyle(
                  color: kSafetyOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.gymName,
    required this.presetNote,
    required this.sets,
    required this.onTap,
  });

  final TrainingEntry entry;
  final String gymName;
  final String presetNote;
  final List<TrainingSet> sets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupCount = sets.fold<int>(0, (sum, set) => sum + set.groupCount);
    final planNote = entry.note.trim();
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kLineSoft)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            LedgerStatusLine(active: entry.completed, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          entry.exerciseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (planNote.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '[$planNote]',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: kChalk.withAlpha(200),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$gymName · ${entry.bodyPart} · $groupCount 组',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: kSteel),
                  ),
                ],
              ),
            ),
            if (presetNote.isNotEmpty) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  presetNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kSteel,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Text(
              entry.completed ? '✓' : '›',
              style: TextStyle(
                color: entry.completed ? kSafetyOrange : kSteel,
                fontSize: entry.completed ? 18 : 20,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
