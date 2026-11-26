import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared Material 3 motion tokens and Reduce-Motion-aware helpers for LamarLog.
abstract final class AppMotion {
  // Timing tokens (express distance & consequence; exit faster than entrance)
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration routeEnter = Duration(milliseconds: 280);
  static const Duration routeExit = Duration(milliseconds: 200);
  static const Duration themeSwitch = Duration(milliseconds: 260);

  // Material 3 emphasized curves (natural deceleration, no reflexive bounce)
  static const Curve enterCurve = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve exitCurve = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve standardCurve = Curves.easeOutCubic;

  static bool reduceMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  static Duration duration(BuildContext context, Duration normal) {
    return reduceMotion(context) ? Duration.zero : normal;
  }

  /// Subtle haptic feedback for segmented controls, tabs, and filter picks.
  static void selectionHaptic() => HapticFeedback.selectionClick();

  /// Tactile confirmation haptic for Kanban drag start or status drop.
  static void impactHaptic() => HapticFeedback.mediumImpact();

  /// Light haptic feedback for completed status changes.
  static void lightHaptic() => HapticFeedback.lightImpact();

  /// Smooth horizontal shared-axis route (for drill-down detail / PDF screens).
  /// Automatically falls back to an instant/gentle crossfade under Reduce Motion.
  static Route<T> sharedAxisRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: routeEnter,
      reverseTransitionDuration: routeExit,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (reduceMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: enterCurve,
          reverseCurve: exitCurve,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Smooth vertical shared-axis route (for creation/edit modal flows like Form).
  static Route<T> slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: routeEnter,
      reverseTransitionDuration: routeExit,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (reduceMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: enterCurve,
          reverseCurve: exitCurve,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}

/// Subtle press-scale micro-interaction (1.0 -> 0.985) using GPU transform only.
/// Respects system Reduce Motion automatically.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.985,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.standardCurve,
        child: widget.child,
      ),
    );
  }
}

/// Smooth Material 3 fade-through container that keeps tab state alive via
/// [IndexedStack] (so inactive tabs stay offstage for GPU & screen readers)
/// while animating opacity + subtle scale when switching tabs.
class FadeThroughIndexedStack extends StatefulWidget {
  const FadeThroughIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<FadeThroughIndexedStack> createState() =>
      _FadeThroughIndexedStackState();
}

class _FadeThroughIndexedStackState extends State<FadeThroughIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
      value: 1.0,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enterCurve,
    );
    _fade = Tween<double>(begin: 0.72, end: 1.0).animate(curved);
    _scale = Tween<double>(begin: 0.985, end: 1.0).animate(curved);
  }

  @override
  void didUpdateWidget(covariant FadeThroughIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (AppMotion.reduceMotion(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stack = IndexedStack(
      index: widget.index,
      children: widget.children,
    );

    if (AppMotion.reduceMotion(context)) return stack;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: stack,
      ),
    );
  }
}
