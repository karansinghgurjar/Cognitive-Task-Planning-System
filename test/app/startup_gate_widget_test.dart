import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/app/startup_gate.dart';
import 'package:study_flow/features/onboarding/models/onboarding_state.dart';
import 'package:study_flow/features/onboarding/providers/onboarding_providers.dart';

void main() {
  testWidgets('StartupGate shows recoverable startup failure state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingStateProvider.overrideWith(
            (ref) => Stream.value(OnboardingStateRecord()),
          ),
        ],
        child: MaterialApp(
          home: StartupGate(startupIssue: StateError('sync init failed')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Continue Offline'), findsOneWidget);
  });

  testWidgets('StartupGate shows safe fallback when onboarding state fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingStateProvider.overrideWith(
            (ref) => Stream<OnboardingStateRecord>.error(Exception('db broken')),
          ),
        ],
        child: const MaterialApp(home: StartupGate()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not start the app'), findsOneWidget);
    expect(find.textContaining('could not be loaded safely'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
