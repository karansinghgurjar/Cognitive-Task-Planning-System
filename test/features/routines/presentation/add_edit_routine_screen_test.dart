import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/presentation/add_edit_routine_screen.dart';

void main() {
  testWidgets('Routine editor renders grouped planning sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddEditRoutineScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Timing'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Behavior'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Behavior'), findsOneWidget);
  });
}
