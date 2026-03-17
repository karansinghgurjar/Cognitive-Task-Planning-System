import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../data/onboarding_repository.dart';
import '../models/onboarding_state.dart';

final onboardingRepositoryProvider = FutureProvider<OnboardingRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return OnboardingRepository(isar);
});

final onboardingStateProvider = StreamProvider<OnboardingStateRecord>((
  ref,
) async* {
  final repository = await ref.watch(onboardingRepositoryProvider.future);
  yield* repository.watchState();
});

final onboardingActionControllerProvider =
    AsyncNotifierProvider<OnboardingActionController, void>(
      OnboardingActionController.new,
    );

class OnboardingActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> markViewed() => _run((repository) => repository.markViewed());

  Future<void> complete() => _run((repository) => repository.complete());

  Future<void> skip() => _run((repository) => repository.skip());

  Future<void> reset() => _run((repository) => repository.reset());

  Future<void> _run(
    Future<void> Function(OnboardingRepository repository) action,
  ) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(onboardingRepositoryProvider.future);
      await action(repository);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
