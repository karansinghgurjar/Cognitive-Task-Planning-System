import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../domain/backup_models.dart';
import '../providers/backup_providers.dart';

class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({required this.loadedBackup, super.key});

  final LoadedBackupImport loadedBackup;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  late RestoreMode _restoreMode;

  @override
  void initState() {
    super.initState();
    _restoreMode = widget.loadedBackup.preview.recommendedMode;
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(backupActionControllerProvider);
    final preview = widget.loadedBackup.preview;
    final metadata = preview.metadata;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Preview')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Backup created ${DateFormat.yMMMd().add_jm().format(metadata.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('App version: ${metadata.appVersion}'),
          Text('Schema version: ${metadata.schemaVersion}'),
          Text('Platform: ${metadata.platform}'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Counts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in preview.importCounts.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(entry.value.toString()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restore Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<RestoreMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<RestoreMode>(
                        value: RestoreMode.replaceAll,
                        label: Text('Replace All'),
                      ),
                      ButtonSegment<RestoreMode>(
                        value: RestoreMode.mergePreferImported,
                        label: Text('Prefer Imported'),
                      ),
                      ButtonSegment<RestoreMode>(
                        value: RestoreMode.mergePreferExisting,
                        label: Text('Prefer Existing'),
                      ),
                    ],
                    selected: {_restoreMode},
                    onSelectionChanged: (selection) {
                      setState(() => _restoreMode = selection.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(switch (_restoreMode) {
                    RestoreMode.replaceAll =>
                      'Clear current app data and replace it with the backup contents.',
                    RestoreMode.mergePreferImported =>
                      'Import everything and overwrite local items that share the same IDs.',
                    RestoreMode.mergePreferExisting =>
                      'Import only items that do not already exist locally.',
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (preview.conflicts.isNotEmpty)
            _WarningSection(
              title: 'Conflicts',
              items: preview.conflicts
                  .map((conflict) => conflict.description)
                  .toList(),
            ),
          if (preview.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _WarningSection(title: 'Warnings', items: preview.warnings),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(preview.summary),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: actionState.isLoading ? null : _applyRestore,
            icon: const Icon(Icons.download_done_rounded),
            label: const Text('Confirm Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyRestore() async {
    if (_restoreMode == RestoreMode.replaceAll) {
      final confirmed = await AppConfirmationDialog.show(
        context,
        title: 'Replace all local data?',
        message:
            'This clears current app data on this device and replaces it with the backup after validation succeeds.',
        confirmLabel: 'Replace Data',
        destructive: true,
      );
      if (!confirmed || !mounted) {
        return;
      }
    }

    try {
      final result = await ref
          .read(backupActionControllerProvider.notifier)
          .restoreBackup(widget.loadedBackup.bundle, _restoreMode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restore completed in ${result.mode.name}. Applied ${result.appliedCounts.values.fold<int>(0, (sum, value) => sum + value)} records.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Restore failed',
        fallbackMessage:
            'The backup could not be restored safely on this device.',
      );
    }
  }
}

class _WarningSection extends StatelessWidget {
  const _WarningSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('- $item'),
              ),
          ],
        ),
      ),
    );
  }
}
