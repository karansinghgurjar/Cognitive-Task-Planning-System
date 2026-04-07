import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/providers/goal_providers.dart';
import '../../schedule/providers/rescheduling_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../focus_session/providers/focus_session_providers.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/providers/task_providers.dart';
import '../domain/command_execution_service.dart';
import '../domain/command_models.dart';
import '../domain/command_registry_service.dart';
import '../domain/command_search_service.dart';
import '../domain/entity_launcher_service.dart';

final commandRegistryServiceProvider = Provider<CommandRegistryService>((ref) {
  return const CommandRegistryService();
});

final commandSearchServiceProvider = Provider<CommandSearchService>((ref) {
  return const CommandSearchService();
});

final entityLauncherServiceProvider = Provider<EntityLauncherService>((ref) {
  return const EntityLauncherService();
});

final commandExecutionServiceProvider = Provider<CommandExecutionService>((ref) {
  return const CommandExecutionService();
});

final commandPaletteQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final commandPaletteContextProvider = Provider<CommandContext>((ref) {
  final tasks = ref.watch(watchTasksProvider).valueOrNull ?? const [];
  final goals = ref.watch(watchGoalsProvider).valueOrNull ?? const [];
  final sessions = ref.watch(watchAllSessionsProvider).valueOrNull ?? const <PlannedSession>[];
  final activeFocusSession = ref.watch(focusSessionControllerProvider);
  final scheduleActionState = ref.watch(scheduleActionControllerProvider);
  final reschedulingState = ref.watch(reschedulingControllerProvider);
  final now = DateTime.now();
  final missedSessionCount = sessions.where((session) {
    if (session.isMissed) {
      return true;
    }
    return session.isPending && session.end.isBefore(now);
  }).length;

  return CommandContext(
    tasks: tasks,
    goals: goals,
    activeFocusSession: activeFocusSession,
    missedSessionCount: missedSessionCount,
    isGeneratingSchedule: scheduleActionState.isLoading,
    isRecoveringSchedule: reschedulingState.isLoading,
  );
});

final availableCommandsProvider = Provider<List<AppCommand>>((ref) {
  final context = ref.watch(commandPaletteContextProvider);
  return ref.read(commandRegistryServiceProvider).getCommands(context);
});

final matchedCommandsProvider = Provider<List<CommandMatchResult>>((ref) {
  final query = ref.watch(commandPaletteQueryProvider);
  final commands = ref.watch(availableCommandsProvider);
  return ref.read(commandSearchServiceProvider).search(query, commands);
});

final matchedLauncherEntitiesProvider =
    Provider<List<LauncherEntityResult>>((ref) {
      final query = ref.watch(commandPaletteQueryProvider);
      final context = ref.watch(commandPaletteContextProvider);
      return ref
          .read(entityLauncherServiceProvider)
          .search(query: query, tasks: context.tasks, goals: context.goals);
    });
