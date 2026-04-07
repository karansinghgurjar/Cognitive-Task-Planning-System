import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_brand.dart';
import '../../../core/database/isar_providers.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../goals/providers/goal_providers.dart';
import '../../notes/providers/notes_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../data/app_state_snapshot_service.dart';
import '../data/backup_record_repository.dart';
import '../data/backup_restore_store.dart';
import '../data/backup_serialization.dart';
import '../data/file_export_service.dart';
import '../domain/backup_models.dart';
import '../domain/backup_service.dart';
import '../domain/csv_export_service.dart';
import '../domain/data_integrity_service.dart';
import '../models/backup_record.dart';

final backupSerializationProvider = Provider<BackupSerialization>((ref) {
  return const BackupSerialization();
});

final fileExportServiceProvider = Provider<FileExportService>((ref) {
  return const FileExportService();
});

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return const CsvExportService();
});

final dataIntegrityServiceProvider = Provider<DataIntegrityService>((ref) {
  return const DataIntegrityService();
});

final backupRecordRepositoryProvider = FutureProvider<BackupRecordRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return BackupRecordRepository(isar);
});

final watchBackupRecordsProvider = StreamProvider<List<BackupRecord>>((
  ref,
) async* {
  final repository = await ref.watch(backupRecordRepositoryProvider.future);
  yield* repository.watchAllRecords();
});

final backupRecordSummaryProvider = Provider<AsyncValue<BackupRecordSummary>>((
  ref,
) {
  return ref.watch(watchBackupRecordsProvider).whenData((records) {
    return BackupRecordSummary(
      lastBackupAt: records.isEmpty ? null : records.first.createdAt,
      totalBackups: records.length,
    );
  });
});

final appStateSnapshotServiceProvider = FutureProvider<AppStateSnapshotService>(
  (ref) async {
    final taskRepository = await ref.watch(taskRepositoryProvider.future);
    final timetableRepository = await ref.watch(
      timetableRepositoryProvider.future,
    );
    final sessionRepository = await ref.watch(
      plannedSessionRepositoryProvider.future,
    );
    final goalRepository = await ref.watch(goalRepositoryProvider.future);
    final notesRepository = await ref.watch(notesRepositoryProvider.future);
    final resourcesRepository = await ref.watch(
      resourcesRepositoryProvider.future,
    );
    final settingsRepository = await ref.watch(
      settingsRepositoryProvider.future,
    );

    return AppStateSnapshotService(
      taskRepository: taskRepository,
      timetableRepository: timetableRepository,
      plannedSessionRepository: sessionRepository,
      goalRepository: goalRepository,
      notesRepository: notesRepository,
      resourcesRepository: resourcesRepository,
      settingsRepository: settingsRepository,
    );
  },
);

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final snapshotService = await ref.watch(
    appStateSnapshotServiceProvider.future,
  );
  final isar = await ref.watch(isarInstanceProvider.future);
  return BackupService(
    snapshotService: snapshotService,
    serialization: ref.read(backupSerializationProvider),
    restoreStore: IsarBackupRestoreStore(isar),
  );
});

final backupActionControllerProvider =
    AsyncNotifierProvider<BackupActionController, void>(
      BackupActionController.new,
    );

class BackupActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<ExportResult> createAndSaveFullBackup() async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final backupService = await ref.read(backupServiceProvider.future);
      final serialization = ref.read(backupSerializationProvider);
      final fileExportService = ref.read(fileExportServiceProvider);
      final bundle = await backupService.createFullBackup();
      final json = serialization.encodeBundle(bundle);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final result = await fileExportService.saveJsonFile(
        content: json,
        suggestedName: '${AppBrand.backupFilePrefix}_backup_$timestamp.json',
      );
      await _recordExport(
        type: BackupRecordType.fullJson,
        result: result,
        recordCount: bundle.metadata.entityCounts.values.fold<int>(
          0,
          (sum, value) => sum + value,
        ),
      );
      debugPrint(
        'Backup export: totalEntities=${bundle.metadata.entityCounts.values.fold<int>(0, (sum, value) => sum + value)} file=${result.filePath}',
      );
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<LoadedBackupImport?> loadBackupForImport() async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final fileExportService = ref.read(fileExportServiceProvider);
      final loadedFile = await fileExportService.pickJsonFile();
      if (loadedFile == null) {
        state = const AsyncData(null);
        return null;
      }

      final backupService = await ref.read(backupServiceProvider.future);
      final validation = backupService.validateBackupJson(loadedFile.content);
      if (!validation.isValid || validation.bundle == null) {
        final message = validation.errors.isEmpty
            ? 'Backup validation failed.'
            : validation.errors.join('\n');
        throw FormatException(message);
      }

      final snapshotService = await ref.read(
        appStateSnapshotServiceProvider.future,
      );
      final existing = await snapshotService.createSnapshot();
      final preview = backupService.previewImport(validation.bundle!, existing);
      debugPrint(
        'Backup import preview: warnings=${preview.warnings.length} conflicts=${preview.conflicts.length} mode=${preview.recommendedMode.name}',
      );
      state = const AsyncData(null);
      return LoadedBackupImport(
        sourcePath: loadedFile.path,
        bundle: validation.bundle!,
        preview: preview,
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<RestoreResult> restoreBackup(
    AppBackupBundle bundle,
    RestoreMode mode,
  ) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final backupService = await ref.read(backupServiceProvider.future);
      final result = await backupService.restoreBackup(bundle, mode);
      final syncQueueRepository = await ref.read(syncQueueRepositoryProvider.future);
      final syncStateRepository = await ref.read(syncStateRepositoryProvider.future);
      await syncQueueRepository.clearAll();
      await syncStateRepository.clearForRestore();
      state = const AsyncData(null);
      ref.invalidate(watchTasksProvider);
      ref.invalidate(watchTimetableSlotsProvider);
      ref.invalidate(watchAllSessionsProvider);
      ref.invalidate(watchGoalsProvider);
      ref.invalidate(watchAllMilestonesProvider);
      ref.invalidate(watchDependenciesProvider);
      ref.invalidate(notificationPreferencesProvider);
      ref.invalidate(syncLocalStateProvider);
      ref.invalidate(watchAllSyncOperationsProvider);
      ref.invalidate(watchSyncConflictsProvider);
      debugPrint(
        'Backup restore: mode=${result.mode.name} applied=${result.appliedCounts.values.fold<int>(0, (sum, value) => sum + value)} warnings=${result.warnings.length}',
      );
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<ExportResult> exportTasksCsv() async {
    final taskRepository = await ref.read(taskRepositoryProvider.future);
    final tasks = await taskRepository.getAllTasks();
    return _saveCsv(
      content: ref.read(csvExportServiceProvider).exportTasksCsv(tasks),
      suggestedName: '${AppBrand.backupFilePrefix}_tasks.csv',
      recordCount: tasks.length,
      type: BackupRecordType.tasksCsv,
    );
  }

  Future<ExportResult> exportSessionsCsv() async {
    final sessionRepository = await ref.read(
      plannedSessionRepositoryProvider.future,
    );
    final taskRepository = await ref.read(taskRepositoryProvider.future);
    final sessions = await sessionRepository.getAllSessions();
    final tasks = await taskRepository.getAllTasks();
    return _saveCsv(
      content: ref
          .read(csvExportServiceProvider)
          .exportSessionsCsv(sessions, tasks),
      suggestedName: '${AppBrand.backupFilePrefix}_sessions.csv',
      recordCount: sessions.length,
      type: BackupRecordType.sessionsCsv,
    );
  }

  Future<ExportResult> exportGoalsCsv() async {
    final goalRepository = await ref.read(goalRepositoryProvider.future);
    final goals = await goalRepository.getAllGoals();
    return _saveCsv(
      content: ref.read(csvExportServiceProvider).exportGoalsCsv(goals),
      suggestedName: '${AppBrand.backupFilePrefix}_goals.csv',
      recordCount: goals.length,
      type: BackupRecordType.goalsCsv,
    );
  }

  Future<ExportResult> exportAnalyticsSummaryCsv() async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final dashboard = ref.read(analyticsDashboardDataProvider).valueOrNull;
      if (dashboard == null) {
        throw StateError('Analytics are not ready yet.');
      }
      final content = ref
          .read(csvExportServiceProvider)
          .exportAnalyticsSummaryCsv(
            CsvAnalyticsSnapshot(
              rangeLabel: dashboard.selectedRange.label,
              plannedMinutes: dashboard.rangeStats.plannedMinutes,
              completedMinutes: dashboard.rangeStats.completedMinutes,
              completionRate: dashboard.rangeStats.completionRate,
              currentFocusStreak:
                  dashboard.streakSummary.currentFocusStreak.length,
              longestFocusStreak:
                  dashboard.streakSummary.longestFocusStreak.length,
              goalAnalytics: dashboard.goalAnalytics,
              insights: dashboard.productivityInsights,
              burnoutRisk: dashboard.burnoutReport.severity,
            ),
          );
      final result = await _saveCsv(
        content: content,
        suggestedName: '${AppBrand.backupFilePrefix}_analytics_summary.csv',
        recordCount: dashboard.goalAnalytics.length,
        type: BackupRecordType.analyticsCsv,
      );
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<DataIntegrityReport> runIntegrityCheck() async {
    state = const AsyncLoading();
    try {
      final snapshot = await (await ref.read(
        appStateSnapshotServiceProvider.future,
      )).createSnapshot();
      final report = ref.read(dataIntegrityServiceProvider).scan(snapshot);
      state = const AsyncData(null);
      return report;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<ExportResult> exportIntegrityReport(DataIntegrityReport report) async {
    final result = await ref
        .read(fileExportServiceProvider)
        .saveTextFile(
          content: ref
              .read(csvExportServiceProvider)
              .exportIntegrityReportCsv(report),
          suggestedName: '${AppBrand.backupFilePrefix}_integrity_report.csv',
        );
    await _recordExport(
      type: BackupRecordType.integrityReport,
      result: result,
      recordCount: report.issues.length,
    );
    return result;
  }

  Future<ExportResult> _saveCsv({
    required String content,
    required String suggestedName,
    required int recordCount,
    required BackupRecordType type,
  }) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(fileExportServiceProvider)
          .saveCsvFile(content: content, suggestedName: suggestedName);
      await _recordExport(type: type, result: result, recordCount: recordCount);
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another backup action is already in progress.');
    }
  }

  Future<void> _recordExport({
    required BackupRecordType type,
    required ExportResult result,
    required int recordCount,
  }) async {
    final repository = await ref.read(backupRecordRepositoryProvider.future);
    await repository.addRecord(
      BackupRecord(
        createdAt: DateTime.now(),
        backupType: type,
        recordCount: recordCount,
        status: result.success
            ? BackupRecordStatus.success
            : result.filePath == null
            ? BackupRecordStatus.cancelled
            : BackupRecordStatus.failed,
        filePath: result.filePath,
      ),
    );
  }
}
