import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../routines/application/routine_formatters.dart';
import '../../routines/presentation/add_edit_routine_screen.dart';
import '../../routines/presentation/routine_widgets.dart';
import '../../routines/providers/routine_providers.dart';
import '../domain/availability_service.dart';
import '../models/timetable_slot.dart';
import '../providers/timetable_providers.dart';
import 'add_edit_timetable_slot_screen.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(watchTimetableSlotsProvider);
    final actionState = ref.watch(timetableActionControllerProvider);
    final weekStart = _startOfCurrentWeek(DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weeklyRoutineOccurrencesAsync = ref.watch(
      weeklyRoutineOccurrencesProvider(
        RoutineWeekRange(startDate: weekStart, endDate: weekEnd),
      ),
    );
    const availabilityService = AvailabilityService();

    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveLayout.breakpointForWidth(
          constraints.maxWidth,
        );
        final padding = ResponsiveLayout.pagePadding(breakpoint);
        return Column(
          children: [
            if (actionState.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: ResponsiveContent(
                child: slotsAsync.when(
                  data: (slots) {
                    final weeklyAvailability = availabilityService
                        .computeWeeklyAvailability(slots);

                    final listChildren = <Widget>[
                      AppSectionHeader(
                        title: 'Timetable',
                        description:
                            'Define your fixed weekly busy and free time blocks.',
                        actions: [
                          IconButton(
                            onPressed: () => AppRouter.openSettings(context),
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Current week: ${formatWeekRangeLabel(weekStart)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ];

                    if (slots.isEmpty) {
                      listChildren.add(
                        const AppEmptyState(
                          icon: Icons.calendar_view_week_rounded,
                          title: 'No timetable yet',
                          message:
                              'Add your fixed busy hours so the planner can compute free time and place sessions realistically.',
                        ),
                      );
                    } else {
                      for (var index = 0; index < 7; index++) {
                        final weekday = index + 1;
                        final daySlots = slots
                            .where((slot) => slot.weekday == weekday)
                            .toList();
                        listChildren.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _DaySection(
                              weekday: weekday,
                              slots: daySlots,
                              availability:
                                  weeklyAvailability[weekday] ?? const [],
                              routineItems:
                                  weeklyRoutineOccurrencesAsync.valueOrNull?[weekday] ??
                                  const [],
                            ),
                          ),
                        );
                      }
                    }

                    return ListView(
                      padding: padding,
                      children: listChildren,
                    );
                  },
                  loading: () => const AppLoadingIndicator(
                    label: 'Loading timetable...',
                  ),
                  error: (error, _) => ErrorBoundaryWidget(error: error),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DaySection extends ConsumerWidget {
  const _DaySection({
    required this.weekday,
    required this.slots,
    required this.availability,
    required this.routineItems,
  });

  final int weekday;
  final List<TimetableSlot> slots;
  final List<AvailabilityWindow> availability;
  final List<RoutineOccurrenceItem> routineItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weekday.weekdayLabel,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (slots.isEmpty)
          const _EmptyDayCard()
        else
          Column(
            children: [
              for (var index = 0; index < slots.length; index++) ...[
                _TimetableSlotCard(slot: slots[index]),
                if (index < slots.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        const SizedBox(height: 12),
        _AvailabilityCard(availability: availability),
        if (routineItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Routine Blocks',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < routineItems.length; index++) ...[
            RoutineOccurrenceCard(
              item: routineItems[index],
              onOpenRoutine: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddEditRoutineScreen(
                      routine: routineItems[index].routine,
                    ),
                  ),
                );
              },
            ),
            if (index < routineItems.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

DateTime _startOfCurrentWeek(DateTime now) {
  final normalized = DateTime(now.year, now.month, now.day);
  return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
}

class _TimetableSlotCard extends ConsumerWidget {
  const _TimetableSlotCard({required this.slot});

  final TimetableSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(slot.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) async {
        final shouldDelete = await AppConfirmationDialog.show(
          context,
          title: 'Delete slot?',
          message: 'Remove "${slot.label}" from the timetable?',
          confirmLabel: 'Delete',
          destructive: true,
        );
        return shouldDelete;
      },
      onDismissed: (_) async {
        try {
          await ref
              .read(timetableActionControllerProvider.notifier)
              .deleteSlot(slot.id);
        } catch (error) {
          if (context.mounted) {
            ErrorHandler.showSnackBar(
              context,
              error,
              fallbackTitle: 'Delete failed',
              fallbackMessage: 'The timetable slot could not be deleted.',
            );
          }
        }
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddEditTimetableSlotScreen(slot: slot),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimeRange(slot),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(isBusy: slot.isBusy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(TimetableSlot slot) {
    final dateFormat = DateFormat.jm();
    final start = DateTime(2026, 1, 1, slot.startHour, slot.startMinute);
    final end = DateTime(2026, 1, 1, slot.endHour, slot.endMinute);
    return '${dateFormat.format(start)} -> ${dateFormat.format(end)}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isBusy
        ? colorScheme.tertiaryContainer
        : colorScheme.secondaryContainer;
    final foreground = isBusy
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSecondaryContainer;

    return AppStatusChip(
      label: isBusy ? 'Busy' : 'Free',
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.availability});

  final List<AvailabilityWindow> availability;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.Hm();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Computed free windows',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (availability.isEmpty)
              Text(
                'No free windows between 06:00 and 23:00.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final window in availability)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${dateFormat.format(_toDateTime(window.startHour, window.startMinute))}'
                        ' - '
                        '${dateFormat.format(_toDateTime(window.endHour, window.endMinute))}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  DateTime _toDateTime(int hour, int minute) {
    return DateTime(2026, 1, 1, hour, minute);
  }
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No timetable slots for this day. Add one if this day has fixed busy or protected time.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

