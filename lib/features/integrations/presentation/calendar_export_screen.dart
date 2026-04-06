import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../backup/domain/backup_models.dart';
import '../models/calendar_export_options.dart';
import '../providers/calendar_export_providers.dart';

class CalendarExportScreen extends ConsumerStatefulWidget {
  const CalendarExportScreen({super.key});

  @override
  ConsumerState<CalendarExportScreen> createState() =>
      _CalendarExportScreenState();
}

class _CalendarExportScreenState extends ConsumerState<CalendarExportScreen> {
  late CalendarExportOptions _options;
  late final TextEditingController _calendarNameController;
  late final TextEditingController _fileNameController;

  @override
  void initState() {
    super.initState();
    _options = CalendarExportOptions.next7Days();
    _calendarNameController = TextEditingController(
      text: _options.calendarName,
    );
    _fileNameController = TextEditingController(text: _options.fileName ?? '');
  }

  @override
  void dispose() {
    _calendarNameController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(calendarExportActionControllerProvider);
    final dateFormatter = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('Export to Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppSectionHeader(
            title: 'Calendar Export',
            description:
                'Export planned sessions as a standard .ics file for Google Calendar, Outlook, Apple Calendar, and similar tools.',
            actions: [
              FilledButton.tonalIcon(
                onPressed: actionState.isLoading
                    ? null
                    : () => _applyPreset(CalendarExportRangePreset.next7Days),
                icon: const Icon(Icons.view_week_rounded),
                label: const Text('Next 7 Days'),
              ),
              FilledButton.tonalIcon(
                onPressed: actionState.isLoading
                    ? null
                    : () => _applyPreset(CalendarExportRangePreset.next30Days),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Next 30 Days'),
              ),
            ],
          ),
          if (actionState.isLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 16),
          _buildRangeCard(context, dateFormatter, actionState.isLoading),
          const SizedBox(height: 16),
          _buildFilterCard(context, actionState.isLoading),
          const SizedBox(height: 16),
          _buildMetadataCard(context, actionState.isLoading),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: actionState.isLoading ? null : _export,
            icon: const Icon(Icons.file_download_rounded),
            label: const Text('Export Calendar File'),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeCard(
    BuildContext context,
    DateFormat dateFormatter,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Range',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SegmentedButton<CalendarExportRangePreset>(
              segments: const [
                ButtonSegment(
                  value: CalendarExportRangePreset.next7Days,
                  label: Text('Next 7 Days'),
                ),
                ButtonSegment(
                  value: CalendarExportRangePreset.next30Days,
                  label: Text('Next 30 Days'),
                ),
                ButtonSegment(
                  value: CalendarExportRangePreset.custom,
                  label: Text('Custom'),
                ),
              ],
              selected: {_options.rangePreset},
              onSelectionChanged: isLoading
                  ? null
                  : (selection) => _applyPreset(selection.first),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      isLoading ||
                          _options.rangePreset !=
                              CalendarExportRangePreset.custom
                      ? null
                      : () => _pickDate(isStart: true),
                  icon: const Icon(Icons.event_available_rounded),
                  label: Text(
                    'Start: ${dateFormatter.format(_options.startDate)}',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      isLoading ||
                          _options.rangePreset !=
                              CalendarExportRangePreset.custom
                      ? null
                      : () => _pickDate(isStart: false),
                  icon: const Icon(Icons.event_rounded),
                  label: Text('End: ${dateFormatter.format(_options.endDate)}'),
                ),
              ],
            ),
            if (_options.rangePreset != CalendarExportRangePreset.custom)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'The range covers ${dateFormatter.format(_options.startDate)} to ${dateFormatter.format(_options.endDate)}.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context, bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Filters',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _options.includePendingSessions,
              contentPadding: EdgeInsets.zero,
              title: const Text('Include pending and in-progress sessions'),
              onChanged: isLoading
                  ? null
                  : (value) =>
                        _updateOptions(includePendingSessions: value ?? false),
            ),
            CheckboxListTile(
              value: _options.includeCompletedSessions,
              contentPadding: EdgeInsets.zero,
              title: const Text('Include completed sessions'),
              onChanged: isLoading
                  ? null
                  : (value) => _updateOptions(
                      includeCompletedSessions: value ?? false,
                    ),
            ),
            CheckboxListTile(
              value: _options.includeMissedSessions,
              contentPadding: EdgeInsets.zero,
              title: const Text('Include missed sessions'),
              subtitle: const Text(
                'Disabled by default so imported calendars stay practical.',
              ),
              onChanged: isLoading
                  ? null
                  : (value) =>
                        _updateOptions(includeMissedSessions: value ?? false),
            ),
            CheckboxListTile(
              value: _options.includeCancelledSessions,
              contentPadding: EdgeInsets.zero,
              title: const Text('Include cancelled sessions'),
              onChanged: isLoading
                  ? null
                  : (value) => _updateOptions(
                      includeCancelledSessions: value ?? false,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _calendarNameController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Calendar Name',
                hintText: 'CogniPlan Schedule',
              ),
              onChanged: (value) => _updateOptions(calendarName: value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fileNameController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Optional custom file name',
              ),
              onChanged: (value) => _updateOptions(fileName: value),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This exports a standard .ics file only. It does not enable live calendar sync.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _options.startDate : _options.endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    final updatedStart = isStart ? picked : _options.startDate;
    final updatedEnd = isStart ? _options.endDate : picked;
    if (updatedEnd.isBefore(updatedStart)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The export end date must be on or after the start date.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _options = _options.copyWith(
        startDate: updatedStart,
        endDate: updatedEnd,
      );
    });
  }

  void _applyPreset(CalendarExportRangePreset preset) {
    setState(() {
      switch (preset) {
        case CalendarExportRangePreset.next7Days:
          _options = CalendarExportOptions.next7Days(
            includeCompletedSessions: _options.includeCompletedSessions,
            includeMissedSessions: _options.includeMissedSessions,
            includeCancelledSessions: _options.includeCancelledSessions,
            calendarName: _effectiveCalendarName(),
            fileName: _normalizedFileName(),
          );
          break;
        case CalendarExportRangePreset.next30Days:
          _options = CalendarExportOptions.next30Days(
            includeCompletedSessions: _options.includeCompletedSessions,
            includeMissedSessions: _options.includeMissedSessions,
            includeCancelledSessions: _options.includeCancelledSessions,
            calendarName: _effectiveCalendarName(),
            fileName: _normalizedFileName(),
          );
          break;
        case CalendarExportRangePreset.custom:
          _options = _options.copyWith(
            rangePreset: CalendarExportRangePreset.custom,
          );
          break;
      }
    });
  }

  void _updateOptions({
    DateTime? startDate,
    DateTime? endDate,
    bool? includePendingSessions,
    bool? includeCompletedSessions,
    bool? includeMissedSessions,
    bool? includeCancelledSessions,
    String? calendarName,
    String? fileName,
  }) {
    setState(() {
      _options = _options.copyWith(
        startDate: startDate,
        endDate: endDate,
        includePendingSessions: includePendingSessions,
        includeCompletedSessions: includeCompletedSessions,
        includeMissedSessions: includeMissedSessions,
        includeCancelledSessions: includeCancelledSessions,
        calendarName: calendarName,
        fileName: fileName,
      );
    });
  }

  String _effectiveCalendarName() {
    final trimmed = _calendarNameController.text.trim();
    return trimmed.isEmpty ? 'CogniPlan Schedule' : trimmed;
  }

  String? _normalizedFileName() {
    final trimmed = _fileNameController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _export() async {
    if (_options.endDate.isBefore(_options.startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The export end date must be on or after the start date.',
          ),
        ),
      );
      return;
    }

    final options = _options.copyWith(
      calendarName: _effectiveCalendarName(),
      fileName: _normalizedFileName(),
    );

    try {
      final result = await ref
          .read(calendarExportActionControllerProvider.notifier)
          .exportCalendar(options);
      if (!mounted) {
        return;
      }
      _showResult(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Calendar export failed',
        fallbackMessage: 'The .ics export could not be created safely.',
      );
    }
  }

  void _showResult(ExportResult result) {
    final warningText = result.warnings.isEmpty
        ? ''
        : '\n${result.warnings.join('\n')}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.message}$warningText')));
  }
}
