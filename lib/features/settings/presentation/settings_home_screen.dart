import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup/presentation/backup_restore_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../onboarding/providers/onboarding_providers.dart';
import '../../sync/presentation/account_screen.dart';
import '../../sync/presentation/sync_status_screen.dart';
import '../../sync/providers/sync_providers.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAccountAsync = ref.watch(syncAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Settings & Tools',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage reminders, sync, backup, onboarding, and release details from one place.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications & reminders'),
            subtitle: const Text(
              'Session reminders, daily summary, deadline warnings, and backup reminder cadence.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          syncAccountAsync.when(
            data: (account) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sync_rounded),
              title: const Text('Sync & account'),
              subtitle: Text(
                account.isSignedIn
                    ? 'Signed in as ${account.email ?? account.userId}'
                    : account.isConfigured
                    ? 'Configure or sign in to sync across devices'
                    : 'Sync backend is not configured',
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
            error: (_, _) => const SizedBox.shrink(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & restore'),
            subtitle: const Text(
              'Create JSON backups, import data, export CSV or calendar files, and run integrity checks.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BackupRestoreScreen(),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_outlined),
            title: const Text('Replay onboarding'),
            subtitle: const Text(
              'Run the first-time setup walkthrough again later.',
            ),
            trailing: const Icon(Icons.replay_rounded),
            onTap: () async {
              await ref
                  .read(onboardingActionControllerProvider.notifier)
                  .reset();
              if (!context.mounted) {
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            subtitle: const Text(
              'Version, release context, storage notes, and sync cautions.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
