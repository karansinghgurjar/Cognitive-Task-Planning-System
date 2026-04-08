import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../application/routine_formatters.dart';
import '../application/routine_form_controller.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../providers/routine_providers.dart';

class AddEditRoutineScreen extends ConsumerStatefulWidget {
  const AddEditRoutineScreen({this.routine, super.key});

  final Routine? routine;

  @override
  ConsumerState<AddEditRoutineScreen> createState() =>
      _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends ConsumerState<AddEditRoutineScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _intervalController;
  late final TextEditingController _durationController;
  late final TextEditingController _reminderLeadController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(routineFormControllerProvider(widget.routine));
    _titleController = TextEditingController(text: state.title)
      ..addListener(() {
        ref
            .read(routineFormControllerProvider(widget.routine).notifier)
            .setTitle(_titleController.text);
      });
    _descriptionController = TextEditingController(text: state.description)
      ..addListener(() {
        ref
            .read(routineFormControllerProvider(widget.routine).notifier)
            .setDescription(_descriptionController.text);
      });
    _intervalController = TextEditingController(text: '${state.interval}');
    _durationController = TextEditingController(
      text: state.preferredDurationMinutes?.toString() ?? '',
    );
    _reminderLeadController = TextEditingController(
      text: state.reminderLeadMinutes?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _intervalController.dispose();
    _durationController.dispose();
    _reminderLeadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(routineFormControllerProvider(widget.routine));
    final controller = ref.read(
      routineFormControllerProvider(widget.routine).notifier,
    );
    _intervalController.value = _intervalController.value.copyWith(
      text: '${formState.interval}',
      selection: TextSelection.collapsed(
        offset: '${formState.interval}'.length,
      ),
      composing: TextRange.empty,
    );
    _durationController.value = _durationController.value.copyWith(
      text: formState.preferredDurationMinutes?.toString() ?? '',
      selection: TextSelection.collapsed(
        offset: (formState.preferredDurationMinutes?.toString() ?? '').length,
      ),
      composing: TextRange.empty,
    );
    _reminderLeadController.value = _reminderLeadController.value.copyWith(
      text: formState.reminderLeadMinutes?.toString() ?? '',
      selection: TextSelection.collapsed(
        offset: (formState.reminderLeadMinutes?.toString() ?? '').length,
      ),
      composing: TextRange.empty,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(formState.isEditMode ? 'Edit Routine' : 'New Routine'),
        actions: [
          if (formState.isEditMode)
            IconButton(
              onPressed: formState.isSaving
                  ? null
                  : () async {
                      try {
                        await controller.archive();
                        if (!mounted) {
                          return;
                        }
                        Navigator.of(this.context).pop();
                      } catch (error) {
                        if (mounted) {
                          ErrorHandler.showSnackBar(
                            this.context,
                            error,
                            fallbackTitle: 'Routine update failed',
                            fallbackMessage:
                                'The routine block could not be updated.',
                          );
                        }
                      }
                    },
              icon: Icon(
                formState.initialRoutine?.isArchived == true
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              tooltip: formState.initialRoutine?.isArchived == true
                  ? 'Unarchive'
                  : 'Archive',
            ),
          if (formState.isEditMode)
            IconButton(
              onPressed: formState.isSaving
                  ? null
                  : () => _deleteRoutine(controller),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          _SectionCard(
            title: 'Basics',
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: formState.validationErrors['title'],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Repeat',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<RoutineRepeatType>(
                  initialValue: formState.repeatType,
                  decoration: const InputDecoration(labelText: 'Repeat type'),
                  items: RoutineRepeatType.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setRepeatType(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Interval',
                    helperText: 'Use 1 for the standard cadence.',
                    errorText: formState.validationErrors['interval'],
                  ),
                  onChanged: (value) =>
                      controller.setInterval(int.tryParse(value.trim()) ?? 0),
                ),
                if (formState.repeatType == RoutineRepeatType.selectedWeekdays) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      return FilterChip(
                        label: Text(formatWeekdayShortLabel(weekday)),
                        selected: formState.selectedWeekdays.contains(weekday),
                        onSelected: (_) => controller.toggleWeekday(weekday),
                      );
                    }),
                  ),
                  if (formState.validationErrors['selectedWeekdays'] case final error?)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
                if (formState.repeatType == RoutineRepeatType.monthly) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue:
                        formState.monthlyDayOfMonth ?? formState.anchorDate.day,
                    decoration: const InputDecoration(
                      labelText: 'Day of month',
                    ),
                    items: List.generate(
                      31,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('Day ${index + 1}'),
                      ),
                    ),
                    onChanged: controller.setMonthlyDayOfMonth,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Timing',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MinuteOfDayTile(
                  label: 'Preferred start time',
                  value: formState.preferredStartMinuteOfDay,
                  onChanged: controller.setPreferredStartMinuteOfDay,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration in minutes',
                    errorText:
                        formState.validationErrors['preferredDurationMinutes'],
                  ),
                  onChanged: (value) => controller.setPreferredDurationMinutes(
                    int.tryParse(value.trim()),
                  ),
                ),
                const SizedBox(height: 12),
                _MinuteOfDayTile(
                  label: 'Window start',
                  value: formState.timeWindowStartMinuteOfDay,
                  onChanged: controller.setTimeWindowStartMinuteOfDay,
                ),
                const SizedBox(height: 12),
                _MinuteOfDayTile(
                  label: 'Window end',
                  value: formState.timeWindowEndMinuteOfDay,
                  onChanged: controller.setTimeWindowEndMinuteOfDay,
                ),
                if (formState.validationErrors['timeWindow'] case final error?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Behavior',
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text('Flexible')),
                    ButtonSegment<bool>(value: false, label: Text('Fixed')),
                  ],
                  selected: {formState.isFlexible},
                  onSelectionChanged: (selection) =>
                      controller.setFlexible(selection.first),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-reschedule missed'),
                  subtitle: const Text(
                    'Store recovery intent now, refine the automation later.',
                  ),
                  value: formState.autoRescheduleMissed,
                  onChanged: controller.setAutoRescheduleMissed,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Count toward consistency'),
                  value: formState.countsTowardConsistency,
                  onChanged: controller.setCountsTowardConsistency,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable reminders'),
                  subtitle: const Text(
                    'Only scheduled upcoming routine blocks can trigger reminders.',
                  ),
                  value: formState.remindersEnabled,
                  onChanged: controller.setRemindersEnabled,
                ),
                if (formState.remindersEnabled) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reminderLeadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reminder lead minutes',
                      helperText: '0 means remind right at start time.',
                      errorText: formState.validationErrors['reminderLeadMinutes'],
                    ),
                    onChanged: (value) =>
                        controller.setReminderLeadMinutes(int.tryParse(value.trim())),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: formState.isSaving ? null : () => _save(controller),
            child: Text(formState.isEditMode ? 'Save Changes' : 'Save Routine'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(RoutineFormController controller) async {
    try {
      final savedRoutine = await controller.save();
      if (savedRoutine != null && mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine save failed',
          fallbackMessage: 'The routine block could not be saved.',
        );
      }
    }
  }

  Future<void> _deleteRoutine(RoutineFormController controller) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete routine?',
      message:
          'Delete this routine and its occurrence history? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await controller.delete();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Routine delete failed',
        fallbackMessage: 'The routine block could not be deleted.',
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MinuteOfDayTile extends StatelessWidget {
  const _MinuteOfDayTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value == null ? 'Not set' : _formatMinuteOfDay(value!)),
      trailing: Wrap(
        spacing: 8,
        children: [
          if (value != null)
            IconButton(
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Clear',
            ),
          IconButton(
            onPressed: () async {
              final initialTime = value == null
                  ? const TimeOfDay(hour: 18, minute: 0)
                  : TimeOfDay(hour: value! ~/ 60, minute: value! % 60);
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );
              if (picked != null) {
                onChanged(picked.hour * 60 + picked.minute);
              }
            },
            icon: const Icon(Icons.access_time_rounded),
            tooltip: 'Pick time',
          ),
        ],
      ),
    );
  }

  String _formatMinuteOfDay(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final normalizedHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute $period';
  }
}
