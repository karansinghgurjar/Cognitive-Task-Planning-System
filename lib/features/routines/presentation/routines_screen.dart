import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/routine.dart';
import '../providers/routine_providers.dart';
import 'routine_diagnostics_screen.dart';
import 'add_edit_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_groups_screen.dart';
import 'routine_onboarding_hint.dart';
import 'routine_templates_screen.dart';
import 'routine_widgets.dart';

enum _RoutineViewFilter { all, fixed, flexible }

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _RoutineViewFilter _filter = _RoutineViewFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeRoutinesProvider);
    final archivedAsync = ref.watch(archivedRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Blocks'),
        actions: [
          IconButton(
            tooltip: 'Templates',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RoutineTemplatesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.library_books_rounded),
          ),
          IconButton(
            tooltip: 'Systems',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RoutineGroupsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_tree_rounded),
          ),
          IconButton(
            tooltip: 'Diagnostics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RoutineDiagnosticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddEditRoutineScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Routine'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: AppSectionHeader(
              title: 'Routine Blocks',
              description:
                  'Recurring structures for work, study, and personal systems.',
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: RoutineOnboardingHint(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<_RoutineViewFilter>(
                    segments: const [
                      ButtonSegment(
                        value: _RoutineViewFilter.all,
                        label: Text('All'),
                      ),
                      ButtonSegment(
                        value: _RoutineViewFilter.fixed,
                        label: Text('Fixed'),
                      ),
                      ButtonSegment(
                        value: _RoutineViewFilter.flexible,
                        label: Text('Flexible'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (selection) {
                      setState(() => _filter = selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: _RoutineWeeklySummaryCard(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RoutineTabBody(
                  routinesAsync: activeAsync,
                  filter: _filter,
                  emptyState: const AppEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No routines yet',
                    message:
                        'Create your first recurring block for repeated work, study, or review.',
                  ),
                ),
                _RoutineTabBody(
                  routinesAsync: archivedAsync,
                  filter: _filter,
                  emptyState: const AppEmptyState(
                    icon: Icons.archive_outlined,
                    title: 'No archived routines',
                    message: 'Archived routine blocks will appear here.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineTabBody extends ConsumerWidget {
  const _RoutineTabBody({
    required this.routinesAsync,
    required this.emptyState,
    required this.filter,
  });

  final AsyncValue<List<Routine>> routinesAsync;
  final Widget emptyState;
  final _RoutineViewFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return routinesAsync.when(
      data: (routines) {
        final filteredRoutines = switch (filter) {
          _RoutineViewFilter.all => routines,
          _RoutineViewFilter.fixed =>
            routines.where((routine) => !routine.isFlexible).toList(),
          _RoutineViewFilter.flexible =>
            routines.where((routine) => routine.isFlexible).toList(),
        };
        if (filteredRoutines.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
            children: [emptyState],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          itemCount: filteredRoutines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final routine = filteredRoutines[index];
            return RoutineListCard(
              routine: routine,
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RoutineDetailScreen(routineId: routine.id),
                  ),
                );
              },
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddEditRoutineScreen(routine: routine),
                  ),
                );
              },
              onArchiveToggle: () => _toggleArchive(context, ref, routine),
              onDelete: () => _deleteRoutine(context, ref, routine.id),
            );
          },
        );
      },
      error: (error, _) =>
          Center(child: Text(ErrorHandler.mapError(error).message)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    final controller = ref.read(routineFormControllerProvider(routine).notifier);
    try {
      await controller.archive();
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine update failed',
          fallbackMessage: 'The routine block could not be updated.',
        );
      }
    }
  }

  Future<void> _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    String routineId,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete routine?',
      message:
          'Delete this routine and its occurrence history? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final routines = ref.read(watchAllRoutinesProvider).valueOrNull ?? const [];
    final routine = routines.where((item) => item.id == routineId).firstOrNull;
    if (routine == null) {
      return;
    }
    try {
      await ref.read(routineFormControllerProvider(routine).notifier).delete();
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine delete failed',
          fallbackMessage: 'The routine block could not be deleted.',
        );
      }
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _RoutineWeeklySummaryCard extends ConsumerWidget {
  const _RoutineWeeklySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weeklyRoutinePlanningSummaryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: summaryAsync.when(
          data: (summary) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Routine Orchestration',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${summary.scheduledRoutineCount} scheduled • ${summary.flexibleNeedsPlacementCount} flexible to place • ${summary.recoverableMissedCount} recoverable missed',
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.consistencyCount} consistency-tracked blocks • ${summary.totalPlannedMinutes} planned minutes',
              ),
            ],
          ),
          error: (error, _) => Text(ErrorHandler.mapError(error).message),
          loading: () => const Text('Loading routine summary...'),
        ),
      ),
    );
  }
}
