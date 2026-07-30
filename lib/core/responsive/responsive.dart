import 'package:flutter/material.dart';

abstract final class Breakpoints {
  static const mobile = 600.0;
  static const desktop = 1024.0;
  static const maxContent = 1240.0;
}

extension ResponsiveContext on BuildContext {
  double get viewportWidth => MediaQuery.sizeOf(this).width;
  bool get isMobile => viewportWidth < Breakpoints.mobile;
  bool get isDesktop => viewportWidth >= Breakpoints.desktop;
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxWidth = Breakpoints.maxContent,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
