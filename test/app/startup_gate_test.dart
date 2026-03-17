import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/app/startup_gate.dart';

void main() {
  group('StartupDecisionService', () {
    const service = StartupDecisionService();

    test('routes to onboarding when onboarding is incomplete', () {
      final destination = service.resolve(onboardingCompleted: false);

      expect(destination, StartupDestination.onboarding);
    });

    test('routes to home when onboarding is complete', () {
      final destination = service.resolve(onboardingCompleted: true);

      expect(destination, StartupDestination.home);
    });
  });
}
