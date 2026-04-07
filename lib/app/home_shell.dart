import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/navigation/app_navigation.dart';
import '../features/command_palette/presentation/command_palette_dialog.dart';
import '../features/analytics/presentation/analytics_dashboard_screen.dart';
import '../features/goals/presentation/add_goal_screen.dart';
import '../features/quick_capture/presentation/quick_capture_inbox_screen.dart';
import '../features/quick_capture/presentation/quick_capture_sheet.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/schedule/presentation/today_screen.dart';
import '../features/tasks/presentation/add_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/timetable/presentation/add_edit_timetable_slot_screen.dart';
import '../features/timetable/presentation/timetable_screen.dart';
import 'app_router.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.pages});

  final List<Widget>? pages;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  List<Widget> get _pages =>
      widget.pages ??
      const [
        TodayScreen(),
        TasksScreen(),
        GoalsScreen(),
        AnalyticsDashboardScreen(),
        TimetableScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.digit1, control: true):
            _ChangeTabIntent(0),
        SingleActivator(LogicalKeyboardKey.digit2, control: true):
            _ChangeTabIntent(1),
        SingleActivator(LogicalKeyboardKey.digit3, control: true):
            _ChangeTabIntent(2),
        SingleActivator(LogicalKeyboardKey.digit4, control: true):
            _ChangeTabIntent(3),
        SingleActivator(LogicalKeyboardKey.digit5, control: true):
            _ChangeTabIntent(4),
        SingleActivator(LogicalKeyboardKey.comma, control: true):
            _OpenSettingsIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, shift: true, control: true):
            _OpenQuickCaptureIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, shift: true, meta: true):
            _OpenQuickCaptureIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ChangeTabIntent: CallbackAction<_ChangeTabIntent>(
            onInvoke: (intent) {
              ref.read(homeTabIndexProvider.notifier).setIndex(intent.index);
              return null;
            },
          ),
          _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
            onInvoke: (_) {
              AppRouter.openSettings(context);
              return null;
            },
          ),
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (_) {
              CommandPaletteDialog.show(context);
              return null;
            },
          ),
          _OpenQuickCaptureIntent: CallbackAction<_OpenQuickCaptureIntent>(
            onInvoke: (_) {
              QuickCaptureSheet.show(context);
              return null;
            },
          ),
        },
        child: Scaffold(
          body: SafeArea(child: _buildCurrentPage()),
          floatingActionButton: _buildFloatingActionButton(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_rounded),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_rounded),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_rounded),
                label: 'Goals',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'Insights',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_view_week_rounded),
                label: 'Timetable',
              ),
            ],
            onDestinationSelected: (index) {
              ref.read(homeTabIndexProvider.notifier).setIndex(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    final index = ref.watch(homeTabIndexProvider);
    if (index < 0 || index >= _pages.length) {
      return const SizedBox.shrink();
    }
    return _pages[index];
  }

  Widget? _buildFloatingActionButton() {
    final primaryFab = _buildPrimaryFloatingActionButton();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'command-palette-fab',
          tooltip: 'Open Command Palette',
          onPressed: () => CommandPaletteDialog.show(context),
          child: const Icon(Icons.search_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'quick-capture-inbox-fab',
          tooltip: 'Open Quick Capture inbox',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const QuickCaptureInboxScreen(),
              ),
            );
          },
          child: const Icon(Icons.inbox_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'quick-capture-entry-fab',
          tooltip: 'Quick Capture',
          onPressed: () => QuickCaptureSheet.show(context),
          child: const Icon(Icons.bolt_rounded),
        ),
        if (primaryFab != null) ...[const SizedBox(height: 12), primaryFab],
      ],
    );
  }

  Widget? _buildPrimaryFloatingActionButton() {
    switch (ref.watch(homeTabIndexProvider)) {
      case 1:
        return FloatingActionButton.extended(
          heroTag: 'add-task-fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddTaskScreen()),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Task'),
        );
      case 2:
        return FloatingActionButton.extended(
          heroTag: 'add-goal-fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddGoalScreen()),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Goal'),
        );
      case 4:
        return FloatingActionButton.extended(
          heroTag: 'add-slot-fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddEditTimetableSlotScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Slot'),
        );
      default:
        return null;
    }
  }
}

class _ChangeTabIntent extends Intent {
  const _ChangeTabIntent(this.index);

  final int index;
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

class _OpenQuickCaptureIntent extends Intent {
  const _OpenQuickCaptureIntent();
}
