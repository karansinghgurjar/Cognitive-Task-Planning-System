import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../data/settings_repository.dart';
import '../models/notification_preferences.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(syncMutationRecorderProvider.future);
  return SettingsRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final notificationPreferencesProvider = StreamProvider<NotificationPreferences>(
  (ref) async* {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    yield* repository.watchPreferences();
  },
);

final settingsActionControllerProvider =
    AsyncNotifierProvider<SettingsActionController, void>(
      SettingsActionController.new,
    );

class SettingsActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.updatePreferences(preferences);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
