import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/app/home_shell.dart';

void main() {
  testWidgets('renders navigation shell labels', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeShell(
            pages: [SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()],
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Timetable'), findsOneWidget);
  });
}
