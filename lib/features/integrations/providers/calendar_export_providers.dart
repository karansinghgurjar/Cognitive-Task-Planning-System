import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_brand.dart';
import '../../backup/domain/backup_models.dart';
import '../../goals/providers/goal_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/calendar_export_repository.dart';
import '../data/calendar_file_export_service.dart';
import '../domain/ics_export_service.dart';
import '../models/calendar_export_options.dart';

final icsExportServiceProvider = Provider<IcsExportService>((ref) {
  return const IcsExportService();
});

final calendarFileExportServiceProvider = Provider<CalendarFileExportService>((
  ref,
) {
  return const CalendarFileExportService();
});

final calendarExportRepositoryProvider =
    FutureProvider<CalendarExportRepository>((ref) async {
      final sessionRepository = await ref.watch(
        plannedSessionRepositoryProvider.future,
      );
      final taskRepository = await ref.watch(taskRepositoryProvider.future);
      final goalRepository = await ref.watch(goalRepositoryProvider.future);

      return CalendarExportRepository(
        loadSessionsInRange: sessionRepository.getSessionsInRange,
        loadTasks: taskRepository.getAllTasks,
        loadGoals: goalRepository.getAllGoals,
      );
    });

final calendarExportActionControllerProvider =
    AsyncNotifierProvider<CalendarExportActionController, void>(
      CalendarExportActionController.new,
    );

class CalendarExportActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<ExportResult> exportCalendar(CalendarExportOptions options) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        calendarExportRepositoryProvider.future,
      );
      final prepared = await repository.prepareExport(options);
      if (prepared.sessions.isEmpty) {
        state = const AsyncData(null);
        final message = prepared.warnings.isNotEmpty
            ? prepared.warnings.join(' ')
            : 'No planned sessions matched the selected export filters.';
        return ExportResult(
          success: false,
          filePath: null,
          bytesWritten: 0,
          message: message,
          warnings: prepared.warnings,
        );
      }

      final content = ref
          .read(icsExportServiceProvider)
          .generateIcsForSessions(
            prepared.sessions,
            prepared.taskMap,
            goalMap: prepared.goalMap,
            calendarName: options.calendarName,
            generatedAt: DateTime.now().toUtc(),
          );
      final saveResult = await ref
          .read(calendarFileExportServiceProvider)
          .saveIcsFile(
            content: content,
            suggestedName: _buildSuggestedFileName(options),
          );

      state = const AsyncData(null);
      return ExportResult(
        success: saveResult.success,
        filePath: saveResult.filePath,
        bytesWritten: saveResult.bytesWritten,
        message: saveResult.message,
        warnings: [...saveResult.warnings, ...prepared.warnings],
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  String _buildSuggestedFileName(CalendarExportOptions options) {
    final explicit = options.fileName?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit.toLowerCase().endsWith('.ics')
          ? explicit
          : '$explicit.ics';
    }

    final formatter = DateFormat('yyyyMMdd');
    final start = formatter.format(options.normalizedStart);
    final end = formatter.format(
      options.normalizedEndExclusive.subtract(const Duration(days: 1)),
    );
    return '${AppBrand.backupFilePrefix}_calendar_${start}_$end.ics';
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another calendar export is already in progress.');
    }
  }
}
