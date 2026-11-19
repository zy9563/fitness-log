import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../calendar/calendar_page.dart';
import '../history/history_page.dart';
import '../more/more_page.dart';
import '../stats/stats_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    CalendarPage(),
    HistoryPage(),
    StatsPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomWordBar(
        index: _index,
        onChanged: (index) {
          HapticFeedback.selectionClick();
          setState(() => _index = index);
        },
      ),
    );
  }
}

/// A four-word control strip. No icons, no blur, no floating pill.
class _BottomWordBar extends StatelessWidget {
  const _BottomWordBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['日历', '记录', '统计', '我的'];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kInk,
        border: Border(top: BorderSide(color: kLine, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: _WordItem(
                    label: _labels[i],
                    selected: index == i,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordItem extends StatelessWidget {
  const _WordItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, 6),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? kChalk : kSteel,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 2,
                color: selected ? kSafetyOrange : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
