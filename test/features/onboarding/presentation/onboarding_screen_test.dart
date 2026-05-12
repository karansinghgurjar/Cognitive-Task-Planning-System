import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/onboarding/data/onboarding_repository.dart';
import 'package:study_flow/features/onboarding/models/onboarding_state.dart';
import 'package:study_flow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:study_flow/features/onboarding/providers/onboarding_providers.dart';

void main() {
  testWidgets('onboarding shows setup choices on the final step', (tester) async {
    final repository = _FakeOnboardingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Primary use case'), findsOneWidget);
    expect(find.text('Planning style'), findsOneWidget);
    expect(find.text('Starter direction'), findsOneWidget);
    expect(find.text('Structured'), findsWidgets);
    expect(find.text('Balanced weekly system'), findsWidgets);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  final _controller = StreamController<OnboardingStateRecord>.broadcast();
  OnboardingStateRecord state = OnboardingStateRecord();

  @override
  Future<void> complete() async {
    state = state.copyWith(
      isCompleted: true,
      hasBeenSeen: true,
      completedAt: DateTime(2026, 5, 12),
    );
    _controller.add(state);
  }

  @override
  Future<OnboardingStateRecord> getState() async => state;

  @override
  Future<void> markViewed() async {
    state = state.copyWith(hasBeenSeen: true, lastViewedAt: DateTime.now());
    _controller.add(state);
  }

  @override
  Future<void> reset() async {
    state = OnboardingStateRecord();
    _controller.add(state);
  }

  @override
  Future<void> skip() async {
    state = state.copyWith(
      isCompleted: true,
      hasBeenSeen: true,
      skippedAt: DateTime(2026, 5, 12),
    );
    _controller.add(state);
  }

  @override
  Future<void> updateState(OnboardingStateRecord state) async {
    this.state = state;
    _controller.add(this.state);
  }

  @override
  Stream<OnboardingStateRecord> watchState() async* {
    yield state;
    yield* _controller.stream;
  }
}
