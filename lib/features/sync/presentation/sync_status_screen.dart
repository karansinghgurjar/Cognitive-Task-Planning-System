import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../domain/sync_models.dart';
import '../models/sync_entity_metadata.dart';
import '../models/sync_run_record.dart';
import '../providers/sync_providers.dart';
import 'sign_in_screen.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(syncStatusSummaryProvider);
    final conflictsAsync = ref.watch(watchSyncConflictsProvider);
    final runsAsync = ref.watch(watchSyncRunsProvider);
    final bootstrapPlanAsync = ref.watch(bootstrapPlanProvider);
    final actionState = ref.watch(syncActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final breakpoint = ResponsiveLayout.breakpointForWidth(
            constraints.maxWidth,
          );
          final padding = ResponsiveLayout.pagePadding(breakpoint);
          return ResponsiveContent(
            child: summaryAsync.when(
              data: (summary) => ListView(
                padding: padding,
                children: [
                  AppSectionHeader(
                    title: 'Sync Status',
                    description:
                        'Review account state, pending changes, conflicts, and recent sync runs.',
                  ),
                  if (actionState.isLoading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 16),
                  _SummaryCard(summary: summary),
                  const SizedBox(height: 16),
                  if (!summary.isSignedIn)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Sign In'),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Sync Now',
                          child: FilledButton.icon(
                            onPressed: actionState.isLoading
                                ? null
                                : () => ref
                                      .read(
                                        syncActionControllerProvider.notifier,
                                      )
                                      .syncNow(),
                            icon: const Icon(Icons.sync_rounded),
                            label: const Text('Sync Now'),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              actionState.isLoading || summary.failedCount == 0
                              ? null
                              : () => ref
                                    .read(syncActionControllerProvider.notifier)
                                    .retryFailed(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Failed'),
                        ),
                      ],
                    ),
                  if (actionState.hasError) ...[
                    const SizedBox(height: 12),
                    ErrorBoundaryWidget(error: actionState.error!),
                  ],
                  const SizedBox(height: 16),
                  bootstrapPlanAsync.when(
                    data: (plan) => plan.requiresChoice
                        ? _BootstrapCard(plan: plan)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => ErrorBoundaryWidget(error: error),
                  ),
                  const SizedBox(height: 16),
                  conflictsAsync.when(
                    data: (conflicts) => _ConflictCard(conflicts: conflicts),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => ErrorBoundaryWidget(error: error),
                  ),
                  const SizedBox(height: 16),
                  runsAsync.when(
                    data: (runs) => _RunHistoryCard(runs: runs),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => ErrorBoundaryWidget(error: error),
                  ),
                ],
              ),
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading sync status...'),
              error: (error, _) => ErrorBoundaryWidget(error: error),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final SyncStatusSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('Status: ${summary.statusLabel}'),
            if (summary.email != null) Text('Account: ${summary.email}'),
            if (summary.deviceId != null) Text('Device: ${summary.deviceId}'),
            Text('Pending changes: ${summary.pendingCount}'),
            Text('Failed operations: ${summary.failedCount}'),
            Text('Conflicts: ${summary.conflictCount}'),
            Text(
              summary.lastSyncAt == null
                  ? 'Last sync: never'
                  : 'Last sync: ${DateFormat.yMMMd().add_jm().format(summary.lastSyncAt!)}',
            ),
            if (summary.lastSyncError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  summary.lastSyncError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapCard extends ConsumerWidget {
  const _BootstrapCard({required this.plan});

  final BootstrapPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bootstrap Choice Required',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(plan.message ?? ''),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () => ref
                      .read(syncActionControllerProvider.notifier)
                      .applyBootstrapChoice(BootstrapChoice.uploadLocal),
                  child: const Text('Upload Local'),
                ),
                OutlinedButton(
                  onPressed: () => ref
                      .read(syncActionControllerProvider.notifier)
                      .applyBootstrapChoice(BootstrapChoice.downloadRemote),
                  child: const Text('Download Remote'),
                ),
                OutlinedButton(
                  onPressed: () => ref
                      .read(syncActionControllerProvider.notifier)
                      .applyBootstrapChoice(BootstrapChoice.merge),
                  child: const Text('Merge'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({required this.conflicts});

  final List<SyncEntityMetadata> conflicts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Conflicts',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (conflicts.isEmpty)
              const Text('No conflicts detected.')
            else
              for (final conflict in conflicts.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${conflict.entityType.name} - ${conflict.entityId}',
                      ),
                      Text(
                        conflict.lastConflictSummary ?? 'Conflict detected.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _RunHistoryCard extends StatelessWidget {
  const _RunHistoryCard({required this.runs});

  final List<SyncRunRecord> runs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Sync Runs',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (runs.isEmpty)
              const Text('No sync runs recorded yet.')
            else
              for (final run in runs.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${run.status.name} - ${DateFormat.yMMMd().add_jm().format(run.startedAt)}',
                      ),
                      Text(
                        'Pushed ${run.pushedCount}, pulled ${run.pulledCount}, conflicts ${run.conflictCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (run.errorSummary != null)
                        Text(
                          run.errorSummary!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
