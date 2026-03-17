import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../models/timetable_slot.dart';
import '../providers/timetable_providers.dart';

class AddEditTimetableSlotScreen extends ConsumerStatefulWidget {
  const AddEditTimetableSlotScreen({super.key, this.slot});

  final TimetableSlot? slot;

  @override
  ConsumerState<AddEditTimetableSlotScreen> createState() =>
      _AddEditTimetableSlotScreenState();
}

class _AddEditTimetableSlotScreenState
    extends ConsumerState<AddEditTimetableSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _uuid = const Uuid();

  int? _selectedWeekday;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isBusy = true;
  bool _isSaving = false;

  bool get _isEditing => widget.slot != null;

  @override
  void initState() {
    super.initState();
    final slot = widget.slot;
    if (slot != null) {
      _labelController.text = slot.label;
      _selectedWeekday = slot.weekday;
      _startTime = TimeOfDay(hour: slot.startHour, minute: slot.startMinute);
      _endTime = TimeOfDay(hour: slot.endHour, minute: slot.endMinute);
      _isBusy = slot.isBusy;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Slot' : 'Add Slot';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _selectedWeekday,
              decoration: const InputDecoration(
                labelText: 'Weekday',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var weekday = 1; weekday <= 7; weekday++)
                  DropdownMenuItem<int>(
                    value: weekday,
                    child: Text(weekday.weekdayLabel),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWeekday = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Select a weekday.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _TimePickerField(
              label: 'Start time',
              value: _startTime,
              onTap: () async {
                final picked = await _pickTime(_startTime);
                if (picked == null) {
                  return;
                }
                setState(() {
                  _startTime = picked;
                });
              },
            ),
            const SizedBox(height: 16),
            _TimePickerField(
              label: 'End time',
              value: _endTime,
              onTap: () async {
                final picked = await _pickTime(_endTime);
                if (picked == null) {
                  return;
                }
                setState(() {
                  _endTime = picked;
                });
              },
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final error = _timeValidationMessage();
                if (error == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Label is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('Busy')),
                  ButtonSegment<bool>(value: false, label: Text('Free')),
                ],
                selected: {_isBusy},
                onSelectionChanged: (selection) {
                  setState(() {
                    _isBusy = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save slot'),
            ),
          ],
        ),
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay? initialValue) {
    return showTimePicker(
      context: context,
      initialTime: initialValue ?? const TimeOfDay(hour: 9, minute: 0),
    );
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    final timeError = _timeValidationMessage();
    if (form == null || !form.validate() || timeError != null) {
      setState(() {});
      return;
    }

    final slot = TimetableSlot(
      id: widget.slot?.id ?? _uuid.v4(),
      weekday: _selectedWeekday!,
      startHour: _startTime!.hour,
      startMinute: _startTime!.minute,
      endHour: _endTime!.hour,
      endMinute: _endTime!.minute,
      isBusy: _isBusy,
      label: _labelController.text.trim(),
    )..isarId = widget.slot?.isarId ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(timetableActionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateSlot(slot);
      } else {
        await controller.addSlot(slot);
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
        fallbackTitle: 'Slot save failed',
        fallbackMessage: 'The timetable slot could not be saved.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _timeValidationMessage() {
    if (_startTime == null || _endTime == null) {
      return 'Select both start and end times.';
    }

    final start = (_startTime!.hour * 60) + _startTime!.minute;
    final end = (_endTime!.hour * 60) + _endTime!.minute;

    if (end <= start) {
      return 'End time must be after start time.';
    }

    return null;
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedValue = value == null
        ? 'Select time'
        : value!.format(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(formattedValue),
        ],
      ),
    );
  }
}
