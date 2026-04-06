import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../integrations/presentation/calendar_export_screen.dart';
import '../../settings/models/notification_preferences.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/backup_models.dart';
import '../models/backup_record.dart';
import '../providers/backup_providers.dart';
import 'import_preview_screen.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  DataIntegrityReport? _integrityReport;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(backupActionControllerProvider);
    final summaryAsync = ref.watch(backupRecordSummaryProvider);
    final recordsAsync = ref.watch(watchBackupRecordsProvider);
    final preferencesAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final breakpoint = ResponsiveLayout.breakpointForWidth(
            constraints.maxWidth,
          );
          final padding = ResponsiveLayout.pagePadding(breakpoint);
          return ResponsiveContent(
            child: ListView(
              padding: padding,
              children: [
                AppSectionHeader(
                  title: 'Backup & Restore',
                  description:
                      'Protect local data with exports, imports, and integrity checks before risky changes.',
                ),
                summaryAsync.when(
                  data: (summary) => _HeaderCard(summary: summary),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ErrorBoundaryWidget(error: error),
                  ),
                ),
                const SizedBox(height: 16),
                if (actionState.isLoading) const LinearProgressIndicator(),
                _ActionCard(
                  title: 'Full JSON Backup',
                  description:
                      'Create an app-controlled JSON backup of tasks, sessions, timetable, goals, dependencies, and settings.',
                  actions: [
                    FilledButton.icon(
                      onPressed: actionState.isLoading ? null : _createBackup,
                      icon: const Icon(Icons.backup_rounded),
                      label: const Text('Create Backup'),
                    ),
                    Semantics(
                      button: true,
                      label: 'Import Backup',
                      child: OutlinedButton.icon(
                        onPressed: actionState.isLoading ? null : _importBackup,
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Import Backup'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'CSV Exports',
                  description:
                      'Export tasks, sessions, goals, and analytics summaries for review or external analysis.',
                  actions: [
                    OutlinedButton(
                      onPressed: actionState.isLoading ? null : _exportTasksCsv,
                      child: const Text('Export Tasks CSV'),
                    ),
                    OutlinedButton(
                      onPressed: actionState.isLoading
                          ? null
                          : _exportSessionsCsv,
                      child: const Text('Export Sessions CSV'),
                    ),
                    OutlinedButton(
                      onPressed: actionState.isLoading ? null : _exportGoalsCsv,
                      child: const Text('Export Goals CSV'),
                    ),
                    OutlinedButton(
                      onPressed: actionState.isLoading
                          ? null
                          : _exportAnalyticsCsv,
                      child: const Text('Export Analytics Summary'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Calendar Export',
                  description:
                      'Export planned sessions as a standard .ics calendar file for Google Calendar, Outlook, Apple Calendar, and similar tools.',
                  actions: [
                    FilledButton.tonalIcon(
                      onPressed: actionState.isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const CalendarExportScreen(),
                                ),
                              );
                            },
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text('Export to Calendar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                preferencesAsync.when(
                  data: (preferences) => _BackupReminderCard(
                    preferences: preferences,
                    onToggle: (value) => _updatePreferences(
                      preferences.copyWith(backupReminderEnabled: value),
                    ),
                    onCadenceChanged: (value) => _updatePreferences(
                      preferences.copyWith(backupReminderCadence: value),
                    ),
                    summary: summaryAsync.valueOrNull,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => ErrorBoundaryWidget(error: error),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Integrity Check',
                  description:
                      'Scan for orphaned sessions, missing references, and suspicious completion state mismatches.',
                  actions: [
                    FilledButton.tonalIcon(
                      onPressed: actionState.isLoading
                          ? null
                          : _runIntegrityCheck,
                      icon: const Icon(Icons.health_and_safety_rounded),
                      label: const Text('Run Integrity Check'),
                    ),
                    if (_integrityReport != null)
                      OutlinedButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : _exportIntegrityReport,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export Report'),
                      ),
                  ],
                ),
                if (_integrityReport != null) ...[
                  const SizedBox(height: 16),
                  _IntegrityReportCard(report: _integrityReport!),
                ],
                const SizedBox(height: 16),
                recordsAsync.when(
                  data: (records) => _HistoryCard(records: records),
                  loading: () => const AppLoadingIndicator(
                    label: 'Loading backup history...',
                  ),
                  error: (error, _) => ErrorBoundaryWidget(error: error),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createBackup() async {
    await _runExport(
      () => ref
          .read(backupActionControllerProvider.notifier)
          .createAndSaveFullBackup(),
      successMessage: 'Backup saved.',
    );
  }

  Future<void> _importBackup() async {
    try {
      final loaded = await ref
          .read(backupActionControllerProvider.notifier)
          .loadBackupForImport();
      if (!mounted || loaded == null) {
        return;
      }
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ImportPreviewScreen(loadedBackup: loaded),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Import failed',
        fallbackMessage:
            'The selected backup could not be opened or validated.',
      );
    }
  }

  Future<void> _exportTasksCsv() async {
    await _runExport(
      () => ref.read(backupActionControllerProvider.notifier).exportTasksCsv(),
      successMessage: 'Tasks CSV exported.',
    );
  }

  Future<void> _exportSessionsCsv() async {
    await _runExport(
      () =>
          ref.read(backupActionControllerProvider.notifier).exportSessionsCsv(),
      successMessage: 'Sessions CSV exported.',
    );
  }

  Future<void> _exportGoalsCsv() async {
    await _runExport(
      () => ref.read(backupActionControllerProvider.notifier).exportGoalsCsv(),
      successMessage: 'Goals CSV exported.',
    );
  }

  Future<void> _exportAnalyticsCsv() async {
    await _runExport(
      () => ref
          .read(backupActionControllerProvider.notifier)
          .exportAnalyticsSummaryCsv(),
      successMessage: 'Analytics summary exported.',
    );
  }

  Future<void> _runIntegrityCheck() async {
    try {
      final report = await ref
          .read(backupActionControllerProvider.notifier)
          .runIntegrityCheck();
      if (!mounted) {
        return;
      }
      setState(() {
        _integrityReport = report;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            report.hasIssues
                ? 'Integrity scan found ${report.issues.length} issues.'
                : 'Integrity scan found no issues.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Integrity check failed',
        fallbackMessage: 'The integrity scan could not complete.',
      );
    }
  }

  Future<void> _exportIntegrityReport() async {
    final report = _integrityReport;
    if (report == null) {
      return;
    }
    await _runExport(
      () => ref
          .read(backupActionControllerProvider.notifier)
          .exportIntegrityReport(report),
      successMessage: 'Integrity report exported.',
    );
  }

  Future<void> _runExport(
    Future<ExportResult> Function() action, {
    required String successMessage,
  }) async {
    try {
      final result = await action();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? successMessage : result.message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Export failed',
        fallbackMessage: 'The export action did not complete successfully.',
      );
    }
  }

  Future<void> _updatePreferences(NotificationPreferences preferences) async {
    try {
      await ref
          .read(settingsActionControllerProvider.notifier)
          .updatePreferences(preferences);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Preference update failed',
        fallbackMessage: 'The backup reminder preference could not be saved.',
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.summary});

  final BackupRecordSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Safety',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              summary.lastBackupAt == null
                  ? 'No backups recorded yet.'
                  : 'Last backup: ${DateFormat.yMMMd().add_jm().format(summary.lastBackupAt!)}',
            ),
            const SizedBox(height: 4),
            Text('Recent backup/export records: ${summary.totalBackups}'),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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

class _BackupReminderCard extends StatelessWidget {
  const _BackupReminderCard({
    required this.preferences,
    required this.onToggle,
    required this.onCadenceChanged,
    required this.summary,
  });

  final NotificationPreferences preferences;
  final ValueChanged<bool> onToggle;
  final ValueChanged<BackupReminderCadence> onCadenceChanged;
  final BackupRecordSummary? summary;

  @override
  Widget build(BuildContext context) {
    final reminderDue = _isReminderDue(summary?.lastBackupAt, preferences);

    return Card(
      color: reminderDue
          ? Theme.of(context).colorScheme.tertiaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Reminder',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable backup reminder'),
              subtitle: const Text(
                'Store a reminder cadence so the app can nudge you when backups are overdue.',
              ),
              value: preferences.backupReminderEnabled,
              onChanged: onToggle,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder cadence'),
              trailing: DropdownButton<BackupReminderCadence>(
                value: preferences.backupReminderCadence,
                onChanged: preferences.backupReminderEnabled
                    ? (value) {
                        if (value != null) {
                          onCadenceChanged(value);
                        }
                      }
                    : null,
                items: BackupReminderCadence.values.map((value) {
                  return DropdownMenuItem<BackupReminderCadence>(
                    value: value,
                    child: Text(value.label),
                  );
                }).toList(),
              ),
            ),
            if (reminderDue)
              const Text(
                'A backup is overdue for the selected cadence. Create one now to keep data safe.',
              ),
          ],
        ),
      ),
    );
  }

  bool _isReminderDue(
    DateTime? lastBackupAt,
    NotificationPreferences preferences,
  ) {
    if (!preferences.backupReminderEnabled) {
      return false;
    }
    if (lastBackupAt == null) {
      return true;
    }
    final days = switch (preferences.backupReminderCadence) {
      BackupReminderCadence.weekly => 7,
      BackupReminderCadence.everyTwoWeeks => 14,
      BackupReminderCadence.monthly => 30,
    };
    return DateTime.now().difference(lastBackupAt).inDays >= days;
  }
}

class _IntegrityReportCard extends StatelessWidget {
  const _IntegrityReportCard({required this.report});

  final DataIntegrityReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integrity Report',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              report.hasIssues
                  ? '${report.issues.length} issues found.'
                  : 'No integrity issues detected.',
            ),
            const SizedBox(height: 12),
            for (final issue in report.issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[${issue.severity.name.toUpperCase()}] ${issue.message}',
                    ),
                    if (issue.suggestedRepair != null)
                      Text(
                        'Suggested repair: ${issue.suggestedRepair}',
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.records});

  final List<BackupRecord> records;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Backups & Exports',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              const Text('No backup/export history yet.')
            else
              for (final record in records.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.backupType.name} - ${record.status.name}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                record.createdAt,
                              ),
                            ),
                            if (record.filePath != null)
                              Text(
                                record.filePath!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      Text('${record.recordCount} items'),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
