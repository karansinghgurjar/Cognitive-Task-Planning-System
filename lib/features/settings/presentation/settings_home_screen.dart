import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../onboarding/providers/onboarding_providers.dart';
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
            'Settings & Safety',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep CogniPlan calm, safe, and daily-usable from one place.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            icon: Icons.palette_outlined,
            title: 'Appearance & planning defaults',
            subtitle:
                'Theme mode, planning horizons, reminders, and sync preferences.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          syncAccountAsync.when(
            data: (account) => _SettingsCard(
              icon: Icons.sync_rounded,
              title: 'Sync status',
              subtitle: account.isSignedIn
                  ? 'Signed in as ${account.email ?? account.userId}'
                  : account.isConfigured
                  ? 'Configured, but not signed in yet.'
                  : 'Sync backend is not configured.',
              onTap: () => AppRouter.openSyncStatus(context),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.backup_outlined,
            title: 'Backup & export',
            subtitle:
                'Create backups, import data, export CSV/calendar files, and validate integrity.',
            onTap: () => AppRouter.openBackupRestore(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.build_circle_outlined,
            title: 'Data & maintenance',
            subtitle:
                'Rebuild routine state, repair duplicates, and reach the safer maintenance tools.',
            onTap: () => AppRouter.openMaintenance(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.dataset_rounded,
            title: 'Sample data',
            subtitle:
                'Load a portfolio-safe demo workspace or clear it again later.',
            onTap: () => AppRouter.openDemoData(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.school_outlined,
            title: 'Replay onboarding',
            subtitle: 'Run the first-run setup again with the calmer Phase 12 flow.',
            onTap: () async {
              await ref.read(onboardingActionControllerProvider.notifier).reset();
              if (!context.mounted) {
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Version, release notes, storage expectations, and portfolio context.',
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
