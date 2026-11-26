import 'package:flutter/material.dart';

/// Material 3 Window Size Class helpers for responsive mobile-to-tablet layouts.
abstract final class Responsive {
  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 840;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mediumBreakpoint;

  static bool isMediumOrWider(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mediumBreakpoint;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expandedBreakpoint;

  static EdgeInsets pagePadding(BuildContext context, {double bottom = 28}) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w >= mediumBreakpoint ? 24.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 8, horizontal, bottom);
  }

  /// Computes a comfortable Kanban column width for 360dp phones up to tablets.
  static double kanbanColumnWidth(double viewportWidth) {
    if (viewportWidth < 380) {
      return (viewportWidth - 48).clamp(256.0, 296.0);
    }
    if (viewportWidth < mediumBreakpoint) {
      return (viewportWidth * 0.78).clamp(284.0, 316.0);
    }
    return 320.0;
  }

  /// Number of KPI cards per row based on available width.
  static int kpiColumns(double width) => width >= 640 ? 4 : 2;

  /// Number of card columns in List / Reminder views on larger screens.
  static int cardGridColumns(double width) => width >= 680 ? 2 : 1;
}

/// Centers content with a clean maximum readable width on tablets and landscape screens,
/// while staying edge-to-edge on compact phones.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
