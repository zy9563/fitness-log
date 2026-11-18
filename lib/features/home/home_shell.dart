import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
      // 让页面内容真正滚动到导航栏后面，BackdropFilter 才能透出内容。
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        onChanged: (index) => setState(() => _index = index),
      ),
    );
  }
}

/// 底部导航：透明背景 + 顶部向底部加深的线性渐变 + 高斯模糊。
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = <_NavItem>[
    _NavItem(
      label: '日历',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    _NavItem(
      label: '记录',
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
    ),
    _NavItem(
      label: '统计',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
    _NavItem(
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrim = pageScrimColor(context);
    final pageText =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final darkScrim =
        ThemeData.estimateBrightnessForColor(scrim) == Brightness.dark;
    final selectedColor = darkScrim
        ? const Color(0xFF9BC8FF)
        : theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
          tileMode: ui.TileMode.clamp,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scrim.withAlpha(0),
                scrim.withAlpha(150),
                scrim.withAlpha(225),
              ],
              stops: const [0, 0.42, 1],
            ),
            border: Border(
              top: BorderSide(color: pageText.withAlpha(24), width: 0.7),
            ),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 6),
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavIcon(
                        item: _items[i],
                        selected: index == i,
                        selectedColor: selectedColor,
                        unselectedColor: pageText.withAlpha(190),
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              scale: selected ? 1.08 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 52,
                height: 48,
                decoration: selected
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor.withAlpha(24),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withAlpha(55),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: selected ? 25 : 23,
                  color: selected ? selectedColor : unselectedColor,
                  shadows: selected
                      ? [
                          Shadow(
                            color: selectedColor.withAlpha(120),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
