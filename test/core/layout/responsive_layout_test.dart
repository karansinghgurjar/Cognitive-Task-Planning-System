import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/layout/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    test('maps widths to expected breakpoints', () {
      expect(ResponsiveLayout.breakpointForWidth(420), AppBreakpoint.compact);
      expect(ResponsiveLayout.breakpointForWidth(800), AppBreakpoint.medium);
      expect(ResponsiveLayout.breakpointForWidth(1280), AppBreakpoint.expanded);
    });

    test('uses wider card mode on desktop widths', () {
      expect(ResponsiveLayout.useWideCards(800), isFalse);
      expect(ResponsiveLayout.useWideCards(1000), isTrue);
    });
  });
}
