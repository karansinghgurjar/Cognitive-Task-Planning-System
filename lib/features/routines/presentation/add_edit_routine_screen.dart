import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_repeat_rule.dart';
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
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _startMinuteController;
  late RoutineType _routineType;
  late RoutineRepeatType _repeatType;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _titleController = TextEditingController(text: routine?.title ?? '');
    _descriptionController = TextEditingController(
      text: routine?.description ?? '',
    );
    _durationController = TextEditingController(
      text: '${routine?.preferredDurationMinutes ?? 60}',
    );
    _startMinuteController = TextEditingController(
      text: '${routine?.preferredStartMinuteOfDay ?? 1080}',
    );
    _routineType = routine?.routineType ?? RoutineType.custom;
    _repeatType = routine?.repeatRule.type ?? RoutineRepeatType.daily;
    _weekdays = {...?routine?.repeatRule.weekdays};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _startMinuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(routineActionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Add Routine' : 'Edit Routine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineType>(
              initialValue: _routineType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: RoutineType.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _routineType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineRepeatType>(
              initialValue: _repeatType,
              decoration: const InputDecoration(labelText: 'Repeat'),
              items: RoutineRepeatType.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _repeatType = value);
                }
              },
            ),
            if (_repeatType == RoutineRepeatType.selectedWeekdays) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  return FilterChip(
                    label: Text(_weekdayLabel(weekday)),
                    selected: _weekdays.contains(weekday),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _weekdays.add(weekday);
                        } else {
                          _weekdays.remove(weekday);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Preferred Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startMinuteController,
              decoration: const InputDecoration(
                labelText: 'Preferred Start Minute Of Day',
                helperText: 'Example: 1110 = 6:30 PM',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: actionState.isLoading ? null : _save,
              child: const Text('Save Routine'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    final selectedWeekdays = _weekdays.toList()..sort();
    final repeatRule = RoutineRepeatRule(
      type: _repeatType,
      weekdays: _repeatType == RoutineRepeatType.selectedWeekdays
          ? selectedWeekdays
          : const [],
    );
    final routine =
        widget.routine?.copyWith(
          title: _titleController.text.trim(),
          description: _normalizeOptional(_descriptionController.text),
          clearDescription: _normalizeOptional(_descriptionController.text) == null,
          updatedAt: now,
          repeatRule: repeatRule,
          preferredDurationMinutes: int.tryParse(_durationController.text.trim()),
          preferredStartMinuteOfDay: int.tryParse(
            _startMinuteController.text.trim(),
          ),
          routineType: _routineType,
          categoryId: _routineType.defaultCategoryTag,
        ) ??
        Routine(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _normalizeOptional(_descriptionController.text),
          createdAt: now,
          updatedAt: now,
          anchorDate: now,
          repeatRule: repeatRule,
          preferredDurationMinutes: int.tryParse(_durationController.text.trim()),
          preferredStartMinuteOfDay: int.tryParse(
            _startMinuteController.text.trim(),
          ),
          routineType: _routineType,
          categoryId: _routineType.defaultCategoryTag,
        );

    try {
      final controller = ref.read(routineActionControllerProvider.notifier);
      if (widget.routine == null) {
        await controller.addRoutine(routine);
      } else {
        await controller.updateRoutine(routine);
      }
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
        fallbackTitle: 'Routine save failed',
        fallbackMessage: 'The routine could not be saved.',
      );
    }
  }

  String? _normalizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}
