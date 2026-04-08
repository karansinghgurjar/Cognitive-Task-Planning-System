import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/routine.dart';
import '../providers/routine_providers.dart';
import 'add_edit_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_widgets.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RoutineTabBody(
                  routinesAsync: activeAsync,
                  emptyState: const AppEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No routines yet',
                    message:
                        'Create your first recurring block for repeated work, study, or review.',
                  ),
                ),
                _RoutineTabBody(
                  routinesAsync: archivedAsync,
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
  });

  final AsyncValue<List<Routine>> routinesAsync;
  final Widget emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return routinesAsync.when(
      data: (routines) {
        if (routines.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
            children: [emptyState],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          itemCount: routines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final routine = routines[index] as dynamic;
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
