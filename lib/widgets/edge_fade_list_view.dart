import 'package:flutter/material.dart';

import '../core/theme.dart';

/// 把页面滚动控制器暴露给卡片，让卡片可以独立计算自己的透明度。
class EdgeFadeScope extends InheritedWidget {
  const EdgeFadeScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final ScrollController controller;

  static EdgeFadeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EdgeFadeScope>();
  }

  @override
  bool updateShouldNotify(EdgeFadeScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// 页面级上下渐变蒙层。
///
/// 该蒙层只负责页面边缘的整体淡出；卡片自身还会根据自己的屏幕位置
/// 做第二次透明度插值（见 AppSectionCard），两种效果互不替代。
///
/// [topFadeHeight] / [bottomFadeHeight] 控制渐变高度，
/// [topFadeOpacity] / [bottomFadeOpacity] 控制边缘最大不透明度；
/// [scrimColor] 不传时自动读取当前主题的页面基准色。
class EdgeFadeListView extends StatefulWidget {
  const EdgeFadeListView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 120),
    this.topFadeHeight = 160,
    this.bottomFadeHeight = 120,
    this.topFadeOpacity = 0.98,
    this.bottomFadeOpacity = 0.96,
    this.scrimColor,
    this.controller,
    this.physics,
    this.cacheExtent,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double topFadeHeight;
  final double bottomFadeHeight;
  final double topFadeOpacity;
  final double bottomFadeOpacity;
  final Color? scrimColor;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double? cacheExtent;

  @override
  State<EdgeFadeListView> createState() => _EdgeFadeListViewState();
}

class _EdgeFadeListViewState extends State<EdgeFadeListView> {
  late ScrollController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(EdgeFadeListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? ScrollController();
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrim = widget.scrimColor ?? pageScrimColor(context);
    return EdgeFadeScope(
      controller: _controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            controller: _controller,
            padding: widget.padding,
            physics: widget.physics,
            cacheExtent: widget.cacheExtent,
            children: widget.children,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: widget.topFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scrim.withAlpha(
                        (255 * widget.topFadeOpacity)
                            .round()
                            .clamp(0, 255)
                            .toInt(),
                      ),
                      scrim.withAlpha(
                        (245 * widget.topFadeOpacity)
                            .round()
                            .clamp(0, 255)
                            .toInt(),
                      ),
                      scrim.withAlpha(0),
                    ],
                    stops: const [0, 0.58, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: widget.bottomFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      scrim.withAlpha(
                        (255 * widget.bottomFadeOpacity)
                            .round()
                            .clamp(0, 255)
                            .toInt(),
                      ),
                      scrim.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
