import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/widgets/app_confirmation_dialog.dart';

void main() {
  testWidgets('AppConfirmationDialog returns true when confirmed', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await AppConfirmationDialog.show(
                    context,
                    title: 'Delete task?',
                    message: 'Confirm delete.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
