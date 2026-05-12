import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../backup/presentation/backup_restore_screen.dart';
import '../../settings/models/notification_preferences.dart';
import '../../sync/presentation/account_screen.dart';
import '../../sync/presentation/sync_status_screen.dart';
import '../../sync/providers/sync_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(notificationPreferencesProvider);
    final actionState = ref.watch(settingsActionControllerProvider);
    final syncAccountAsync = ref.watch(syncAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: preferencesAsync.when(
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Appearance & workflow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Theme mode'),
              subtitle: const Text('Use the system setting or keep CogniPlan pinned to one theme.'),
              trailing: DropdownButton<AppThemePreference>(
                value: preferences.themePreference,
                onChanged: (value) {
                  if (value != null) {
                    _update(ref, preferences.copyWith(themePreference: value), context);
                  }
                },
                items: AppThemePreference.values
                    .map(
                      (value) => DropdownMenuItem<AppThemePreference>(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Default planning horizon'),
              subtitle: const Text('Used for calm weekly planning surfaces and future previews.'),
              trailing: DropdownButton<int>(
                value: preferences.defaultPlanningHorizonDays,
                onChanged: (value) {
                  if (value != null) {
                    _update(
                      ref,
                      preferences.copyWith(defaultPlanningHorizonDays: value),
                      context,
                    );
                  }
                },
                items: const [3, 7, 14]
                    .map((value) => DropdownMenuItem<int>(value: value, child: Text('$value days')))
                    .toList(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Routine generation horizon'),
              subtitle: const Text('Controls how far ahead routine occurrences are generated and maintained.'),
              trailing: DropdownButton<int>(
                value: preferences.routineGenerationHorizonDays,
                onChanged: (value) {
                  if (value != null) {
                    _update(
                      ref,
                      preferences.copyWith(routineGenerationHorizonDays: value),
                      context,
                    );
                  }
                },
                items: const [14, 30, 45]
                    .map((value) => DropdownMenuItem<int>(value: value, child: Text('$value days')))
                    .toList(),
              ),
            ),
            const Divider(height: 32),
            syncAccountAsync.when(
              data: (account) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sync account'),
                subtitle: Text(
                  account.isSignedIn
                      ? 'Signed in as ${account.email ?? account.userId}'
                      : account.isConfigured
                      ? 'Not signed in'
                      : 'Supabase sync is not configured',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => account.isSignedIn
                          ? const SyncStatusScreen()
                          : const AccountScreen(),
                    ),
                  );
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Text(ErrorHandler.mapError(error).message),
            ),
            SwitchListTile.adaptive(
              title: const Text('Enable sync'),
              subtitle: const Text('Keep local data queued for upload and synchronize across signed-in devices.'),
              value: preferences.syncEnabled,
              onChanged: (value) => _update(
                ref,
                preferences.copyWith(syncEnabled: value),
                context,
              ),
            ),
            SwitchListTile.adaptive(
              title: const Text('Auto-sync'),
              subtitle: const Text('Attempt sync on app resume and after local edits with a short debounce.'),
              value: preferences.autoSyncEnabled,
              onChanged: preferences.syncEnabled
                  ? (value) => _update(
                        ref,
                        preferences.copyWith(autoSyncEnabled: value),
                        context,
                      )
                  : null,
            ),
            SwitchListTile.adaptive(
              title: const Text('Sync over Wi-Fi only'),
              subtitle: const Text('Keep auto-sync off mobile data when possible.'),
              value: preferences.syncOnWifiOnly,
              onChanged: preferences.syncEnabled
                  ? (value) => _update(
                        ref,
                        preferences.copyWith(syncOnWifiOnly: value),
                        context,
                      )
                  : null,
            ),
            const Divider(height: 32),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              title: const Text('Session reminders'),
              subtitle: const Text('Remind me before and at the start of planned sessions.'),
              value: preferences.sessionRemindersEnabled,
              onChanged: (value) => _update(
                ref,
                preferences.copyWith(sessionRemindersEnabled: value),
                context,
              ),
            ),
            _LeadTimeSelector(
              preferences: preferences,
              onChanged: (value) => _update(
                ref,
                preferences.copyWith(reminderLeadTimeMinutes: value),
                context,
              ),
            ),
            SwitchListTile.adaptive(
              title: const Text('Daily summary'),
              subtitle: const Text('Send a summary of today\'s sessions every morning.'),
              value: preferences.dailySummaryEnabled,
              onChanged: (value) => _update(
                ref,
                preferences.copyWith(dailySummaryEnabled: value),
                context,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily summary time'),
              subtitle: Text(
                TimeOfDay(
                  hour: preferences.dailySummaryHour,
                  minute: preferences.dailySummaryMinute,
                ).format(context),
              ),
              trailing: const Icon(Icons.schedule_rounded),
              onTap: () => _pickDailySummaryTime(context, ref, preferences),
            ),
            SwitchListTile.adaptive(
              title: const Text('Deadline warnings'),
              subtitle: const Text('Warn me when goals or urgent work become infeasible.'),
              value: preferences.deadlineWarningsEnabled,
              onChanged: (value) => _update(
                ref,
                preferences.copyWith(deadlineWarningsEnabled: value),
                context,
              ),
            ),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Backup & Restore'),
              subtitle: const Text('Create JSON backups, import data, export CSV files, and run integrity checks.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BackupRestoreScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: actionState.isLoading
                  ? null
                  : () async {
                      try {
                        final syncService = await ref.read(
                          notificationSyncServiceProvider.future,
                        );
                        await syncService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test notification sent.')),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ErrorHandler.showSnackBar(
                            context,
                            error,
                            fallbackTitle: 'Notification failed',
                            fallbackMessage: 'The test notification could not be sent.',
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Test Notification'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorBoundaryWidget(error: error),
      ),
    );
  }

  Future<void> _pickDailySummaryTime(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences preferences,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: preferences.dailySummaryHour,
        minute: preferences.dailySummaryMinute,
      ),
    );
    if (picked == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    await _update(
      ref,
      preferences.copyWith(
        dailySummaryHour: picked.hour,
        dailySummaryMinute: picked.minute,
      ),
      context,
    );
  }

  Future<void> _update(
    WidgetRef ref,
    NotificationPreferences preferences,
    BuildContext context,
  ) async {
    try {
      await ref.read(settingsActionControllerProvider.notifier).updatePreferences(preferences);
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Settings update failed',
          fallbackMessage: 'The settings could not be saved.',
        );
      }
    }
  }
}

class _LeadTimeSelector extends StatelessWidget {
  const _LeadTimeSelector({required this.preferences, required this.onChanged});

  final NotificationPreferences preferences;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Reminder lead time'),
      subtitle: const Text('Choose how long before a session the reminder should fire.'),
      trailing: DropdownButton<int>(
        value: preferences.reminderLeadTimeMinutes,
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        items: const [5, 10, 15]
            .map(
              (minutes) => DropdownMenuItem<int>(
                value: minutes,
                child: Text('$minutes min'),
              ),
            )
            .toList(),
      ),
    );
  }
}
