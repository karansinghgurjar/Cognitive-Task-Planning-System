import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../backup/presentation/backup_restore_screen.dart';
import '../../demo_data/presentation/demo_data_screen.dart';
import '../../routines/providers/routine_intelligence_providers.dart';

class DataMaintenanceScreen extends ConsumerWidget {
  const DataMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(routineIntelligenceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data & Maintenance')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppSectionHeader(
            title: 'Safe maintenance',
            description:
                'These tools repair derived state and clean up duplicates without deleting your real planning history.',
          ),
          const SizedBox(height: 16),
          if (actionState.isLoading) const LinearProgressIndicator(),
          _MaintenanceCard(
            title: 'Data safety',
            description:
                'Use backups and integrity checks before risky changes, migrations, or device moves.',
            actions: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackupRestoreScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.backup_rounded),
                label: const Text('Open Backup & Restore'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DemoDataScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dataset_rounded),
                label: const Text('Sample Data'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MaintenanceCard(
            title: 'Routine repair tools',
            description:
                'Rebuild future routine state, refresh reminders, or dedupe mirrored occurrences after imports and sync churn.',
            actions: [
              OutlinedButton.icon(
                onPressed: actionState.isLoading
                    ? null
                    : () => _run(
                          context,
                          () => ref
                              .read(routineIntelligenceControllerProvider.notifier)
                              .rebuildPostSyncDerivedState(),
                          successMessage: 'Routine state rebuilt.',
                        ),
                icon: const Icon(Icons.construction_rounded),
                label: const Text('Rebuild Routine State'),
              ),
              OutlinedButton.icon(
                onPressed: actionState.isLoading
                    ? null
                    : () => _run(
                          context,
                          () => ref
                              .read(routineIntelligenceControllerProvider.notifier)
                              .rebuildRoutineReminders(),
                          successMessage: 'Routine reminders rebuilt.',
                        ),
                icon: const Icon(Icons.notifications_active_rounded),
                label: const Text('Rebuild Reminders'),
              ),
              OutlinedButton.icon(
                onPressed: actionState.isLoading
                    ? null
                    : () async {
                        try {
                          final count = await ref
                              .read(routineIntelligenceControllerProvider.notifier)
                              .dedupeRoutineOccurrences();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed $count duplicate routine occurrences.'),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ErrorHandler.showSnackBar(
                            context,
                            error,
                            fallbackTitle: 'Dedupe failed',
                            fallbackMessage: 'The duplicate occurrence repair could not finish.',
                          );
                        }
                      },
                icon: const Icon(Icons.merge_rounded),
                label: const Text('Repair Duplicate Occurrences'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Maintenance action failed',
        fallbackMessage: 'The maintenance action could not complete safely.',
      );
    }
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({
    required this.title,
    required this.description,
    required this.actions,
  });

  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ),
      ),
    );
  }
}
