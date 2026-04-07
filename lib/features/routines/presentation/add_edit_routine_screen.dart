import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../../goals/providers/goal_providers.dart';
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
  late final TextEditingController _priorityController;

  late RoutineType _routineType;
  late RoutineCadenceType _cadenceType;
  late bool _isActive;
  late Set<int> _selectedWeekdays;
  TimeOfDay? _preferredTime;
  String? _linkedGoalId;

  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _titleController = TextEditingController(text: routine?.title ?? '');
    _descriptionController = TextEditingController(
      text: routine?.description ?? '',
    );
    _durationController = TextEditingController(
      text: '${routine?.durationMinutes ?? 45}',
    );
    _priorityController = TextEditingController(
      text: '${routine?.priority ?? 3}',
    );
    _routineType = routine?.routineType ?? RoutineType.study;
    _cadenceType = routine?.cadenceType ?? RoutineCadenceType.daily;
    _isActive = routine?.isActive ?? true;
    _selectedWeekdays = {...?routine?.weekdays};
    _preferredTime = routine?.hasPreferredStartTime == true
        ? TimeOfDay(
            hour: routine!.preferredStartHour!,
            minute: routine.preferredStartMinute!,
          )
        : null;
    _linkedGoalId = routine?.linkedGoalId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(watchGoalsProvider);
    final actionState = ref.watch(routineActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Routine' : 'Add Routine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Daily DSA Practice',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional context or reminders',
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineType>(
              initialValue: _routineType,
              decoration: const InputDecoration(labelText: 'Routine Type'),
              items: RoutineType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.label));
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _routineType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineCadenceType>(
              initialValue: _cadenceType,
              decoration: const InputDecoration(labelText: 'Cadence'),
              items: RoutineCadenceType.values.map((cadence) {
                return DropdownMenuItem(
                  value: cadence,
                  child: Text(cadence.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _cadenceType = value;
                  if (value == RoutineCadenceType.daily) {
                    _selectedWeekdays.clear();
                  } else if (value == RoutineCadenceType.weekly &&
                      _selectedWeekdays.length > 1) {
                    _selectedWeekdays = {_selectedWeekdays.first};
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_cadenceType != RoutineCadenceType.daily) ...[
              Text(
                _cadenceType == RoutineCadenceType.weekly
                    ? 'Choose one weekday'
                    : 'Choose weekdays',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final selected = _selectedWeekdays.contains(weekday);
                  return FilterChip(
                    label: Text(_weekdayLabel(weekday)),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (_cadenceType == RoutineCadenceType.weekly) {
                          _selectedWeekdays = value ? {weekday} : <int>{};
                        } else if (value) {
                          _selectedWeekdays.add(weekday);
                        } else {
                          _selectedWeekdays.remove(weekday);
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final duration = int.tryParse(value ?? '');
                      if (duration == null || duration < 5) {
                        return 'Enter at least 5 minutes.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priorityController,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final priority = int.tryParse(value ?? '');
                      if (priority == null || priority < 1 || priority > 5) {
                        return 'Use 1 to 5.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: _isActive,
              title: const Text('Active'),
              subtitle: const Text(
                'Only active routines generate routine blocks.',
              ),
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Preferred Start Time'),
              subtitle: Text(
                _preferredTime == null
                    ? 'No preferred time. The first available slot will be used.'
                    : _preferredTime!.format(context),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _preferredTime == null
                        ? null
                        : () {
                            setState(() {
                              _preferredTime = null;
                            });
                          },
                    child: const Text('Clear'),
                  ),
                  FilledButton.tonal(
                    onPressed: _pickTime,
                    child: const Text('Choose Time'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            goalsAsync.when(
              data: (goals) => DropdownButtonFormField<String?>(
                initialValue: _linkedGoalId,
                decoration: const InputDecoration(
                  labelText: 'Linked Goal',
                  hintText: 'Optional',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No linked goal'),
                  ),
                  ...goals.map((goal) {
                    return DropdownMenuItem<String?>(
                      value: goal.id,
                      child: Text(goal.title),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _linkedGoalId = value;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                ErrorHandler.mapError(error).message,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: actionState.isLoading ? null : _saveRoutine,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditing ? 'Save Routine' : 'Add Routine'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _preferredTime = picked;
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_cadenceType != RoutineCadenceType.daily && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one weekday.')),
      );
      return;
    }

    final existing = widget.routine;
    final now = DateTime.now();
    final routine =
        existing?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          clearDescription: _descriptionController.text.trim().isEmpty,
          routineType: _routineType,
          isActive: _isActive,
          durationMinutes: int.parse(_durationController.text.trim()),
          cadenceType: _cadenceType,
          weekdays: _selectedWeekdays.toList()..sort(),
          preferredStartHour: _preferredTime?.hour,
          clearPreferredStartHour: _preferredTime == null,
          preferredStartMinute: _preferredTime?.minute,
          clearPreferredStartMinute: _preferredTime == null,
          priority: int.parse(_priorityController.text.trim()),
          linkedGoalId: _linkedGoalId,
          clearLinkedGoalId: _linkedGoalId == null,
          updatedAt: now,
        ) ??
        Routine(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          routineType: _routineType,
          isActive: _isActive,
          durationMinutes: int.parse(_durationController.text.trim()),
          cadenceType: _cadenceType,
          weekdays: _selectedWeekdays.toList()..sort(),
          preferredStartHour: _preferredTime?.hour,
          preferredStartMinute: _preferredTime?.minute,
          priority: int.parse(_priorityController.text.trim()),
          linkedGoalId: _linkedGoalId,
          createdAt: now,
          updatedAt: now,
        );

    try {
      final controller = ref.read(routineActionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateRoutine(routine);
      } else {
        await controller.addRoutine(routine);
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
        fallbackMessage: 'The routine could not be saved right now.',
      );
    }
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
