import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/notifications/notification_log.dart';
import '../../features/backup/models/backup_record.dart';
import '../../features/goals/models/goal_milestone.dart';
import '../../features/goals/models/learning_goal.dart';
import '../../features/notes/models/entity_note.dart';
import '../../features/notes/models/entity_resource.dart';
import '../../features/onboarding/models/onboarding_state.dart';
import '../../features/goals/models/task_dependency.dart';
import '../../features/quick_capture/models/quick_capture_item.dart';
import '../../features/review/models/weekly_review.dart';
import '../../features/routines/models/routine.dart';
import '../../features/routines/models/routine_occurrence.dart';
import '../../features/schedule/models/planned_session.dart';
import '../../features/settings/models/notification_preferences.dart';
import '../../features/sync/models/pending_sync_operation.dart';
import '../../features/sync/models/sync_entity_metadata.dart';
import '../../features/sync/models/sync_local_state.dart';
import '../../features/sync/models/sync_run_record.dart';
import '../../features/tasks/models/task.dart';
import '../../features/timetable/models/timetable_slot.dart';

class IsarService {
  static const _instanceName = 'study_flow_db';

  Isar? _isar;
  Future<Isar>? _opening;

  Future<Isar> openIsar() {
    final current = _isar;
    if (current != null && current.isOpen) {
      return Future.value(current);
    }

    final existing = Isar.getInstance(_instanceName);
    if (existing != null && existing.isOpen) {
      _isar = existing;
      return Future.value(existing);
    }

    final opening = _opening;
    if (opening != null) {
      return opening;
    }

    final future = _open();
    _opening = future;
    return future;
  }

  Future<Isar> _open() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final isar = await Isar.open(
        [
          TaskSchema,
          TimetableSlotSchema,
          PlannedSessionSchema,
          LearningGoalSchema,
          GoalMilestoneSchema,
          TaskDependencySchema,
          EntityNoteSchema,
          EntityResourceSchema,
          QuickCaptureItemSchema,
          WeeklyReviewSchema,
          RoutineSchema,
          RoutineOccurrenceSchema,
          OnboardingStateRecordSchema,
          NotificationPreferencesSchema,
          NotificationLogEntrySchema,
          BackupRecordSchema,
          PendingSyncOperationRecordSchema,
          SyncEntityMetadataSchema,
          SyncLocalStateSchema,
          SyncRunRecordSchema,
        ],
        directory: directory.path,
        name: _instanceName,
        inspector: false,
      );
      _isar = isar;
      return isar;
    } finally {
      _opening = null;
    }
  }
}
