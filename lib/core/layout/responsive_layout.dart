import 'package:flutter/material.dart';

enum AppBreakpoint { compact, medium, expanded }

class ResponsiveLayout {
  const ResponsiveLayout._();

  static AppBreakpoint breakpointForWidth(double width) {
    if (width >= 1100) {
      return AppBreakpoint.expanded;
    }
    if (width >= 720) {
      return AppBreakpoint.medium;
    }
    return AppBreakpoint.compact;
  }

  static double maxContentWidth(AppBreakpoint breakpoint) {
    switch (breakpoint) {
      case AppBreakpoint.compact:
        return 680;
      case AppBreakpoint.medium:
        return 920;
      case AppBreakpoint.expanded:
        return 1280;
    }
  }

  static EdgeInsets pagePadding(AppBreakpoint breakpoint) {
    switch (breakpoint) {
      case AppBreakpoint.compact:
        return const EdgeInsets.fromLTRB(16, 20, 16, 96);
      case AppBreakpoint.medium:
        return const EdgeInsets.fromLTRB(24, 24, 24, 96);
      case AppBreakpoint.expanded:
        return const EdgeInsets.fromLTRB(32, 28, 32, 96);
    }
  }

  static bool useWideCards(double width) => width >= 960;
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    super.key,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
  });

  final Widget child;
  final Alignment alignment;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveLayout.breakpointForWidth(
          constraints.maxWidth,
        );
        final resolvedMaxWidth =
            maxWidth ?? ResponsiveLayout.maxContentWidth(breakpoint);
        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
