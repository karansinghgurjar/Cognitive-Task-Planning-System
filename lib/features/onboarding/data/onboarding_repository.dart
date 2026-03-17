import 'package:isar/isar.dart';

import '../models/onboarding_state.dart';

class OnboardingRepository {
  OnboardingRepository(this._isar);

  static const defaultId = 1;

  final Isar _isar;

  Future<OnboardingStateRecord> getState() async {
    final existing = await _isar.onboardingStateRecords.get(defaultId);
    if (existing != null) {
      return existing;
    }

    final initial = OnboardingStateRecord(id: defaultId);
    await _isar.writeTxn(() async {
      await _isar.onboardingStateRecords.put(initial);
    });
    return initial;
  }

  Stream<OnboardingStateRecord> watchState() async* {
    yield await getState();
    yield* _isar.onboardingStateRecords
        .watchObject(defaultId, fireImmediately: false)
        .asyncMap((value) async => value ?? getState());
  }

  Future<void> markViewed() async {
    final state = await getState();
    await updateState(
      state.copyWith(hasBeenSeen: true, lastViewedAt: DateTime.now()),
    );
  }

  Future<void> complete() async {
    final state = await getState();
    await updateState(
      state.copyWith(
        isCompleted: true,
        hasBeenSeen: true,
        completedAt: DateTime.now(),
        clearSkippedAt: true,
      ),
    );
  }

  Future<void> skip() async {
    final state = await getState();
    await updateState(
      state.copyWith(
        isCompleted: true,
        hasBeenSeen: true,
        skippedAt: DateTime.now(),
        clearCompletedAt: true,
      ),
    );
  }

  Future<void> reset() async {
    await updateState(OnboardingStateRecord(id: defaultId));
  }

  Future<void> updateState(OnboardingStateRecord state) async {
    await _isar.writeTxn(() async {
      await _isar.onboardingStateRecords.put(state);
    });
  }
}
