import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/database/database_version.dart';
import '../data/app_state_snapshot_service.dart';
import '../data/backup_restore_store.dart';
import '../data/backup_serialization.dart';
import 'backup_models.dart';

class BackupService {
  BackupService({
    AppStateSnapshotService? snapshotService,
    required BackupSerialization serialization,
    required BackupRestoreStore restoreStore,
    Future<ExistingAppStateSnapshot> Function()? snapshotLoader,
    Future<String> Function()? appVersionLoader,
    String Function()? platformLoader,
  }) : assert(
         snapshotService != null || snapshotLoader != null,
         'Provide either snapshotService or snapshotLoader.',
       ),
       _serialization = serialization,
       _restoreStore = restoreStore,
       _snapshotLoader = snapshotLoader ?? snapshotService!.createSnapshot,
       _appVersionLoader =
           appVersionLoader ??
           (() async {
             final info = await PackageInfo.fromPlatform();
             return info.version;
           }),
       _platformLoader = platformLoader ?? (() => Platform.operatingSystem);

  final BackupSerialization _serialization;
  final BackupRestoreStore _restoreStore;
  final Future<ExistingAppStateSnapshot> Function() _snapshotLoader;
  final Future<String> Function() _appVersionLoader;
  final String Function() _platformLoader;

  Future<AppBackupBundle> createFullBackup() async {
    final snapshot = await _snapshotLoader();
    return AppBackupBundle(
      metadata: BackupMetadata(
        appVersion: await _appVersionLoader(),
        schemaVersion: AppDatabaseVersion.schemaVersion,
        backupFormatVersion: AppDatabaseVersion.backupFormatVersion,
        createdAt: DateTime.now(),
        platform: _platformLoader(),
        entityCounts: snapshot.entityCounts,
      ),
      tasks: snapshot.tasks,
      timetableSlots: snapshot.timetableSlots,
      plannedSessions: snapshot.plannedSessions,
      goals: snapshot.goals,
      milestones: snapshot.milestones,
      dependencies: snapshot.dependencies,
      preferences: snapshot.preferences,
    );
  }

  BackupValidationResult validateBackupJson(String json) {
    return _serialization.decodeBundle(json);
  }

  ImportPreview previewImport(
    AppBackupBundle bundle,
    ExistingAppStateSnapshot existing,
  ) {
    final conflicts = <ImportConflict>[];

    void collectConflicts<T>(
      String collection,
      Iterable<T> imported,
      Iterable<T> current,
      String Function(T item) idOf,
    ) {
      final currentIds = current.map(idOf).toSet();
      for (final item in imported) {
        final id = idOf(item);
        if (currentIds.contains(id)) {
          conflicts.add(
            ImportConflict(
              collection: collection,
              entityId: id,
              description:
                  '$collection item $id already exists locally and will conflict during merge.',
            ),
          );
        }
      }
    }

    collectConflicts('tasks', bundle.tasks, existing.tasks, (item) => item.id);
    collectConflicts(
      'timetableSlots',
      bundle.timetableSlots,
      existing.timetableSlots,
      (item) => item.id,
    );
    collectConflicts(
      'plannedSessions',
      bundle.plannedSessions,
      existing.plannedSessions,
      (item) => item.id,
    );
    collectConflicts('goals', bundle.goals, existing.goals, (item) => item.id);
    collectConflicts(
      'milestones',
      bundle.milestones,
      existing.milestones,
      (item) => item.id,
    );
    collectConflicts(
      'dependencies',
      bundle.dependencies,
      existing.dependencies,
      (item) => item.id,
    );

    final importCounts = {
      'tasks': bundle.tasks.length,
      'timetableSlots': bundle.timetableSlots.length,
      'plannedSessions': bundle.plannedSessions.length,
      'goals': bundle.goals.length,
      'milestones': bundle.milestones.length,
      'dependencies': bundle.dependencies.length,
      'settings': 1,
    };

    return ImportPreview(
      metadata: bundle.metadata,
      importCounts: importCounts,
      existingCounts: existing.entityCounts,
      conflicts: conflicts,
      warnings: bundle.warnings,
      recommendedMode: conflicts.isEmpty
          ? RestoreMode.replaceAll
          : RestoreMode.mergePreferImported,
      summary: conflicts.isEmpty
          ? 'No ID conflicts were found. A full replace is safe if you want an exact restore.'
          : '${conflicts.length} ID conflicts were found. Merge mode will update those items instead of deleting everything.',
    );
  }

  Future<RestoreResult> restoreBackup(
    AppBackupBundle bundle,
    RestoreMode mode,
  ) async {
    switch (mode) {
      case RestoreMode.replaceAll:
        await _restoreStore.replaceAll(bundle);
        return RestoreResult(
          mode: RestoreMode.replaceAll,
          appliedCounts: _bundleCounts(bundle),
          skippedCounts: const {},
          warnings: bundle.warnings,
        );
      case RestoreMode.mergePreferImported:
        return _restoreMerge(bundle, preferImported: true);
      case RestoreMode.mergePreferExisting:
        return _restoreMerge(bundle, preferImported: false);
    }
  }

  Future<RestoreResult> _restoreMerge(
    AppBackupBundle bundle, {
    required bool preferImported,
  }) async {
    final existing = await _snapshotLoader();
    final appliedCounts = <String, int>{};
    final skippedCounts = <String, int>{};

    List<T> filterForMode<T>(
      Iterable<T> imported,
      Set<String> existingIds,
      String collection,
      String Function(T item) idOf,
    ) {
      final kept = <T>[];
      var skipped = 0;
      for (final item in imported) {
        final exists = existingIds.contains(idOf(item));
        if (exists && !preferImported) {
          skipped += 1;
          continue;
        }
        kept.add(item);
      }
      appliedCounts[collection] = kept.length;
      if (skipped > 0) {
        skippedCounts[collection] = skipped;
      }
      return kept;
    }

    final tasks = filterForMode(
      bundle.tasks,
      existing.tasks.map((item) => item.id).toSet(),
      'tasks',
      (item) => item.id,
    );
    final slots = filterForMode(
      bundle.timetableSlots,
      existing.timetableSlots.map((item) => item.id).toSet(),
      'timetableSlots',
      (item) => item.id,
    );
    final sessions = filterForMode(
      bundle.plannedSessions,
      existing.plannedSessions.map((item) => item.id).toSet(),
      'plannedSessions',
      (item) => item.id,
    );
    final goals = filterForMode(
      bundle.goals,
      existing.goals.map((item) => item.id).toSet(),
      'goals',
      (item) => item.id,
    );
    final milestones = filterForMode(
      bundle.milestones,
      existing.milestones.map((item) => item.id).toSet(),
      'milestones',
      (item) => item.id,
    );
    final dependencies = filterForMode(
      bundle.dependencies,
      existing.dependencies.map((item) => item.id).toSet(),
      'dependencies',
      (item) => item.id,
    );

    await _restoreStore.mergeBundle(
      tasks: tasks,
      timetableSlots: slots,
      plannedSessions: sessions,
      goals: goals,
      milestones: milestones,
      dependencies: dependencies,
      preferences: preferImported ? bundle.preferences : null,
    );

    if (preferImported) {
      appliedCounts['settings'] = 1;
    } else {
      skippedCounts['settings'] = 1;
    }

    return RestoreResult(
      mode: preferImported
          ? RestoreMode.mergePreferImported
          : RestoreMode.mergePreferExisting,
      appliedCounts: appliedCounts,
      skippedCounts: skippedCounts,
      warnings: bundle.warnings,
    );
  }

  Map<String, int> _bundleCounts(AppBackupBundle bundle) {
    return {
      'tasks': bundle.tasks.length,
      'timetableSlots': bundle.timetableSlots.length,
      'plannedSessions': bundle.plannedSessions.length,
      'goals': bundle.goals.length,
      'milestones': bundle.milestones.length,
      'dependencies': bundle.dependencies.length,
      'settings': 1,
    };
  }
}
