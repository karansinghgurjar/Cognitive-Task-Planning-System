import '../domain/routine_sync_service.dart';
import '../data/routine_occurrence_repository.dart';
import '../models/routine.dart';
import 'routine_reminder_service.dart';

class RoutineBackupRestoreService {
  const RoutineBackupRestoreService({
    required RoutineSyncService syncService,
    required RoutineOccurrenceRepository occurrenceRepository,
    required RoutineReminderService reminderService,
  }) : _syncService = syncService,
       _occurrenceRepository = occurrenceRepository,
       _reminderService = reminderService;

  final RoutineSyncService _syncService;
  final RoutineOccurrenceRepository _occurrenceRepository;
  final RoutineReminderService _reminderService;

  Future<void> rebuildDerivedStateAfterRestore({
    required List<Routine> routines,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final startDate = DateTime(timestamp.year, timestamp.month, timestamp.day)
        .subtract(const Duration(days: 7));
    final endDate = startDate.add(const Duration(days: 37));
    await _syncService.syncAllRoutines(startDate: startDate, endDate: endDate);
    final occurrences = await _occurrenceRepository.getOccurrencesInRange(
      startDate,
      endDate,
    );
    await _reminderService.syncRoutineReminders(
      routines: routines,
      occurrences: occurrences,
      now: timestamp,
    );
  }
}
