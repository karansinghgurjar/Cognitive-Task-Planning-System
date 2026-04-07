import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/widgets/app_section_header.dart';

void main() {
  testWidgets('stacks actions below header text on compact widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Scaffold(
            body: AppSectionHeader(
              title: 'Tasks',
              description: 'Track work',
              actions: [
                FilledButton(onPressed: () {}, child: const Text('Action')),
              ],
            ),
          ),
        ),
      ),
    );

    final titleBottom = tester.getBottomLeft(find.text('Tasks')).dy;
    final actionTop = tester.getTopLeft(find.text('Action')).dy;

    expect(actionTop, greaterThan(titleBottom));
  });

  testWidgets('keeps actions beside header text on wide widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1000, 800)),
          child: Scaffold(
            body: AppSectionHeader(
              title: 'Tasks',
              description: 'Track work',
              actions: [
                FilledButton(onPressed: () {}, child: const Text('Action')),
              ],
            ),
          ),
        ),
      ),
    );

    final titleTop = tester.getTopLeft(find.text('Tasks')).dy;
    final actionTop = tester.getTopLeft(find.text('Action')).dy;

    expect((actionTop - titleTop).abs(), lessThan(24));
  });
}
