import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/onboarding/data/onboarding_repository.dart';
import 'package:study_flow/features/onboarding/models/onboarding_state.dart';
import 'package:study_flow/features/onboarding/providers/onboarding_providers.dart';

void main() {
  group('Onboarding providers', () {
    test('complete persists onboarding state through the repository', () async {
      final repository = FakeOnboardingRepository();
      final container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(onboardingActionControllerProvider.notifier).complete();

      expect(repository.state.isCompleted, isTrue);
      expect(repository.state.completedAt, isNotNull);
    });

    test('reset clears completion state for replay', () async {
      final repository = FakeOnboardingRepository(
        initialState: OnboardingStateRecord(
          isCompleted: true,
          hasBeenSeen: true,
          completedAt: DateTime(2026, 3, 16),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(onboardingActionControllerProvider.notifier).reset();

      expect(repository.state.isCompleted, isFalse);
      expect(repository.state.completedAt, isNull);
    });
  });
}

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({OnboardingStateRecord? initialState})
    : state = initialState ?? OnboardingStateRecord();

  final _controller = StreamController<OnboardingStateRecord>.broadcast();
  OnboardingStateRecord state;

  @override
  Future<void> complete() async {
    state = state.copyWith(
      isCompleted: true,
      hasBeenSeen: true,
      completedAt: DateTime(2026, 3, 16),
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
      skippedAt: DateTime(2026, 3, 16),
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
