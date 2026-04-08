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
  late final TextEditingController _categoryController;
  late final TextEditingController _durationController;
  late final TextEditingController _priorityController;
  late final TextEditingController _intervalController;
  late final TextEditingController _dayOfMonthController;
  late final TextEditingController _energyController;
  late final TextEditingController _contextTagsController;

  late RoutineType _routineType;
  late RoutineCadenceType _cadenceType;
  late bool _isActive;
  late bool _isArchived;
  late bool _isFlexible;
  late bool _autoRescheduleMissed;
  late bool _countsTowardConsistency;
  late Set<int> _selectedWeekdays;
  TimeOfDay? _preferredTime;
  TimeOfDay? _windowStartTime;
  TimeOfDay? _windowEndTime;
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
    _categoryController = TextEditingController(
      text: routine?.categoryTag ?? routine?.routineType.defaultCategoryTag ?? '',
    );
    _durationController = TextEditingController(
      text: '${routine?.durationMinutes ?? 45}',
    );
    _priorityController = TextEditingController(
      text: '${routine?.priority ?? 3}',
    );
    _intervalController = TextEditingController(text: '${routine?.interval ?? 1}');
    _dayOfMonthController = TextEditingController(
      text: routine?.dayOfMonth?.toString() ?? '',
    );
    _energyController = TextEditingController(text: routine?.energyType ?? '');
    _contextTagsController = TextEditingController(
      text: routine?.contextTags.join(', ') ?? '',
    );
    _routineType = routine?.routineType ?? RoutineType.study;
    _cadenceType = routine?.cadenceType ?? RoutineCadenceType.daily;
    _isActive = routine?.isActive ?? true;
    _isArchived = routine?.isArchived ?? false;
    _isFlexible = routine?.isFlexible ?? true;
    _autoRescheduleMissed = routine?.autoRescheduleMissed ?? false;
    _countsTowardConsistency = routine?.countsTowardConsistency ?? true;
    _selectedWeekdays = {...?routine?.weekdays};
    _preferredTime = _timeOfDayFromMinute(routine?.preferredStartMinuteOfDay);
    _windowStartTime = _timeOfDayFromMinute(routine?.timeWindowStartMinute);
    _windowEndTime = _timeOfDayFromMinute(routine?.timeWindowEndMinute);
    _linkedGoalId = routine?.linkedGoalId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    _priorityController.dispose();
    _intervalController.dispose();
    _dayOfMonthController.dispose();
    _energyController.dispose();
    _contextTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(watchGoalsProvider);
    final actionState = ref.watch(routineActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Routine Block' : 'Create Routine Block'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          children: [
            Text(
              'Create a recurring system block',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Define the recurrence, timing, and behavior once. The app will generate concrete routine occurrences inside the planning horizon.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Workout, Research Reading, Weekly Review',
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
                hintText: 'Optional context, constraints, or reminders',
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<RoutineType>(
                    initialValue: _routineType,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: RoutineType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.label));
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _routineType = value;
                        if (_categoryController.text.trim().isEmpty) {
                          _categoryController.text = value.defaultCategoryTag;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      hintText: 'Health, Deep Work, Revision',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineCadenceType>(
              initialValue: _cadenceType,
              decoration: const InputDecoration(labelText: 'Repeat Pattern'),
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
                  if (value == RoutineCadenceType.weekdays) {
                    _selectedWeekdays = {
                      DateTime.monday,
                      DateTime.tuesday,
                      DateTime.wednesday,
                      DateTime.thursday,
                      DateTime.friday,
                    };
                  } else if (value == RoutineCadenceType.weekly &&
                      _selectedWeekdays.isEmpty) {
                    _selectedWeekdays = {DateTime.monday};
                  } else if (value == RoutineCadenceType.daily) {
                    _selectedWeekdays.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_showsWeekdayPicker) ...[
              Text(
                _cadenceType == RoutineCadenceType.weekly
                    ? 'Choose weekly day(s)'
                    : 'Choose active days',
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
                        if (value) {
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
                      labelText: 'Preferred Duration (minutes)',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Interval',
                      helperText: 'Every N periods',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final interval = int.tryParse(value ?? '');
                      if (interval == null || interval < 1) {
                        return 'Minimum 1.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dayOfMonthController,
                    decoration: const InputDecoration(
                      labelText: 'Day Of Month',
                      helperText: 'Used for monthly routines',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_cadenceType != RoutineCadenceType.monthly ||
                          value == null ||
                          value.trim().isEmpty) {
                        return null;
                      }
                      final day = int.tryParse(value);
                      if (day == null || day < 1 || day > 31) {
                        return 'Use 1 to 31.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TimePickerTile(
              title: 'Preferred Start',
              subtitle: _preferredTime == null
                  ? 'Optional. Used as the first scheduling target.'
                  : _preferredTime!.format(context),
              onChoose: () => _pickTime(
                    initial: _preferredTime ?? const TimeOfDay(hour: 19, minute: 0),
                    onSelected: (value) => setState(() => _preferredTime = value),
                  ),
              onClear: _preferredTime == null
                  ? null
                  : () => setState(() => _preferredTime = null),
            ),
            const SizedBox(height: 12),
            _TimePickerTile(
              title: 'Time Window Start',
              subtitle: _windowStartTime == null
                  ? 'Optional scheduling window start'
                  : _windowStartTime!.format(context),
              onChoose: () => _pickTime(
                    initial: _windowStartTime ?? const TimeOfDay(hour: 18, minute: 0),
                    onSelected: (value) => setState(() => _windowStartTime = value),
                  ),
              onClear: _windowStartTime == null
                  ? null
                  : () => setState(() => _windowStartTime = null),
            ),
            const SizedBox(height: 12),
            _TimePickerTile(
              title: 'Time Window End',
              subtitle: _windowEndTime == null
                  ? 'Optional scheduling window end'
                  : _windowEndTime!.format(context),
              onChoose: () => _pickTime(
                    initial: _windowEndTime ?? const TimeOfDay(hour: 22, minute: 0),
                    onSelected: (value) => setState(() => _windowEndTime = value),
                  ),
              onClear: _windowEndTime == null
                  ? null
                  : () => setState(() => _windowEndTime = null),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _energyController,
              decoration: const InputDecoration(
                labelText: 'Energy / Context',
                hintText: 'Deep Work, Low Energy, Gym, Reading',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contextTagsController,
              decoration: const InputDecoration(
                labelText: 'Context Tags',
                hintText: 'home, laptop, quiet, evening',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _isFlexible,
              title: const Text('Flexible Routine'),
              subtitle: const Text(
                'Flexible routines can move inside the available window. Fixed routines must hold their preferred start.',
              ),
              onChanged: (value) {
                setState(() {
                  _isFlexible = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              value: _autoRescheduleMissed,
              title: const Text('Auto-reschedule missed'),
              subtitle: const Text(
                'Allow missed routine blocks to be recovered in future planning passes.',
              ),
              onChanged: (value) {
                setState(() {
                  _autoRescheduleMissed = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              value: _countsTowardConsistency,
              title: const Text('Counts toward consistency'),
              subtitle: const Text(
                'Use this routine when computing streaks and consistency summaries later.',
              ),
              onChanged: (value) {
                setState(() {
                  _countsTowardConsistency = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              value: _isActive,
              title: const Text('Enabled'),
              subtitle: const Text(
                'Only enabled routines generate future routine occurrences.',
              ),
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            if (_isEditing)
              SwitchListTile.adaptive(
                value: _isArchived,
                title: const Text('Archived'),
                subtitle: const Text(
                  'Archived routines stop generating future occurrences but keep history intact.',
                ),
                onChanged: (value) {
                  setState(() {
                    _isArchived = value;
                  });
                },
              ),
            const SizedBox(height: 8),
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
              label: Text(
                _isEditing ? 'Save Routine Block' : 'Create Routine Block',
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showsWeekdayPicker {
    return _cadenceType == RoutineCadenceType.weekly ||
        _cadenceType == RoutineCadenceType.customWeekdays ||
        _cadenceType == RoutineCadenceType.custom;
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) {
      return;
    }
    onSelected(picked);
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_showsWeekdayPicker && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one weekday.')),
      );
      return;
    }

    final windowStartMinute = _minuteOfDay(_windowStartTime);
    final windowEndMinute = _minuteOfDay(_windowEndTime);
    if ((windowStartMinute == null) != (windowEndMinute == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set both time window start and end, or leave both empty.'),
        ),
      );
      return;
    }
    if (windowStartMinute != null &&
        windowEndMinute != null &&
        windowStartMinute >= windowEndMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time window end must be after the start time.'),
        ),
      );
      return;
    }

    final existing = widget.routine;
    final now = DateTime.now();
    final routine =
        existing?.copyWith(
          title: _titleController.text.trim(),
          description: _normalizeOptionalText(_descriptionController.text),
          clearDescription: _normalizeOptionalText(_descriptionController.text) == null,
          categoryTag: _normalizeOptionalText(_categoryController.text),
          clearCategoryTag: _normalizeOptionalText(_categoryController.text) == null,
          routineType: _routineType,
          isActive: _isActive,
          isArchived: _isArchived,
          archivedAt: _isArchived ? now : null,
          clearArchivedAt: !_isArchived,
          durationMinutes: int.parse(_durationController.text.trim()),
          cadenceType: _cadenceType,
          weekdays: _resolvedWeekdays(),
          dayOfMonth: _cadenceType == RoutineCadenceType.monthly
              ? int.tryParse(_dayOfMonthController.text.trim())
              : null,
          clearDayOfMonth: _cadenceType != RoutineCadenceType.monthly,
          interval: int.parse(_intervalController.text.trim()),
          preferredStartHour: _preferredTime?.hour,
          clearPreferredStartHour: _preferredTime == null,
          preferredStartMinute: _preferredTime?.minute,
          clearPreferredStartMinute: _preferredTime == null,
          timeWindowStartMinute: windowStartMinute,
          clearTimeWindowStartMinute: windowStartMinute == null,
          timeWindowEndMinute: windowEndMinute,
          clearTimeWindowEndMinute: windowEndMinute == null,
          priority: int.parse(_priorityController.text.trim()),
          isFlexible: _isFlexible,
          autoRescheduleMissed: _autoRescheduleMissed,
          countsTowardConsistency: _countsTowardConsistency,
          linkedGoalId: _linkedGoalId,
          clearLinkedGoalId: _linkedGoalId == null,
          energyType: _normalizeOptionalText(_energyController.text),
          clearEnergyType: _normalizeOptionalText(_energyController.text) == null,
          contextTags: _parsedContextTags(),
          updatedAt: now,
        ) ??
        Routine(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _normalizeOptionalText(_descriptionController.text),
          categoryTag: _normalizeOptionalText(_categoryController.text),
          routineType: _routineType,
          isActive: _isActive,
          isArchived: _isArchived,
          archivedAt: _isArchived ? now : null,
          durationMinutes: int.parse(_durationController.text.trim()),
          cadenceType: _cadenceType,
          weekdays: _resolvedWeekdays(),
          dayOfMonth: _cadenceType == RoutineCadenceType.monthly
              ? int.tryParse(_dayOfMonthController.text.trim())
              : null,
          interval: int.parse(_intervalController.text.trim()),
          preferredStartHour: _preferredTime?.hour,
          preferredStartMinute: _preferredTime?.minute,
          timeWindowStartMinute: windowStartMinute,
          timeWindowEndMinute: windowEndMinute,
          priority: int.parse(_priorityController.text.trim()),
          isFlexible: _isFlexible,
          autoRescheduleMissed: _autoRescheduleMissed,
          countsTowardConsistency: _countsTowardConsistency,
          linkedGoalId: _linkedGoalId,
          energyType: _normalizeOptionalText(_energyController.text),
          contextTags: _parsedContextTags(),
          createdAt: now,
          updatedAt: now,
          anchorDate: DateTime(now.year, now.month, now.day),
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
        fallbackMessage: 'The routine block could not be saved right now.',
      );
    }
  }

  List<int> _resolvedWeekdays() {
    switch (_cadenceType) {
      case RoutineCadenceType.weekdays:
        return const [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ];
      case RoutineCadenceType.daily:
      case RoutineCadenceType.monthly:
        return const [];
      case RoutineCadenceType.weekly:
      case RoutineCadenceType.customWeekdays:
      case RoutineCadenceType.custom:
        return _selectedWeekdays.toList()..sort();
    }
  }

  List<String> _parsedContextTags() {
    return _contextTagsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  int? _minuteOfDay(TimeOfDay? value) {
    if (value == null) {
      return null;
    }
    return value.hour * 60 + value.minute;
  }

  TimeOfDay? _timeOfDayFromMinute(int? minuteOfDay) {
    if (minuteOfDay == null) {
      return null;
    }
    return TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  }

  String? _normalizeOptionalText(String value) {
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

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.title,
    required this.subtitle,
    required this.onChoose,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final VoidCallback onChoose;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Wrap(
        spacing: 8,
        children: [
          TextButton(
            onPressed: onClear,
            child: const Text('Clear'),
          ),
          FilledButton.tonal(
            onPressed: onChoose,
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }
}
