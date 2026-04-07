import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_flow/features/goals/data/goal_repository.dart';
import 'package:study_flow/features/goals/providers/goal_providers.dart';
import 'package:study_flow/features/notes/domain/entity_attachments_cleanup_service.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/notes/providers/notes_providers.dart';
import 'package:study_flow/features/tasks/data/task_repository.dart';
import 'package:study_flow/features/tasks/providers/task_providers.dart';

void main() {
  test('deleteGoal removes linked attachments before deleting the goal', () async {
    final goalRepository = _MockGoalRepository();
    final taskRepository = _MockTaskRepository();
    final cleanupService = _MockEntityAttachmentsCleanupService();

    when(
      () => cleanupService.deleteForEntity(EntityAttachmentType.goal, 'goal-1'),
    ).thenAnswer((_) async {});
    when(() => goalRepository.deleteGoal('goal-1')).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        goalRepositoryProvider.overrideWith((ref) async => goalRepository),
        taskRepositoryProvider.overrideWith((ref) async => taskRepository),
        entityAttachmentsCleanupServiceProvider.overrideWith(
          (ref) async => cleanupService,
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(goalActionControllerProvider.notifier)
        .deleteGoal('goal-1');

    verifyInOrder([
      () => cleanupService.deleteForEntity(EntityAttachmentType.goal, 'goal-1'),
      () => goalRepository.deleteGoal('goal-1'),
    ]);
  });
}

class _MockGoalRepository extends Mock implements GoalRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockEntityAttachmentsCleanupService extends Mock
    implements EntityAttachmentsCleanupService {}
