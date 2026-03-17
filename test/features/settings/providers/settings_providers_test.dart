import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/settings/data/settings_repository.dart';
import 'package:study_flow/features/settings/models/notification_preferences.dart';
import 'package:study_flow/features/settings/providers/settings_providers.dart';

void main() {
  test(
    'settings action controller persists notification preferences updates',
    () async {
      final repository = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final updated = repository.preferences.copyWith(
        sessionRemindersEnabled: false,
        dailySummaryHour: 8,
        dailySummaryMinute: 30,
      );

      await container
          .read(settingsActionControllerProvider.notifier)
          .updatePreferences(updated);

      expect(repository.preferences.sessionRemindersEnabled, isFalse);
      expect(repository.preferences.dailySummaryHour, 8);
      expect(repository.preferences.dailySummaryMinute, 30);
    },
  );
}

class FakeSettingsRepository implements SettingsRepository {
  final _controller = StreamController<NotificationPreferences>.broadcast();
  NotificationPreferences preferences = NotificationPreferences();

  @override
  Future<NotificationPreferences> getPreferences() async => preferences;

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    this.preferences = preferences;
    _controller.add(this.preferences);
  }

  @override
  Stream<NotificationPreferences> watchPreferences() async* {
    yield preferences;
    yield* _controller.stream;
  }
}
