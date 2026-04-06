import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../models/learning_goal.dart';
import '../providers/goal_providers.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialGoalType,
    this.initialPriority,
    this.initialEstimatedMinutes,
    this.initialTargetDate,
  });

  final String? initialTitle;
  final String? initialDescription;
  final GoalType? initialGoalType;
  final int? initialPriority;
  final int? initialEstimatedMinutes;
  final DateTime? initialTargetDate;

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();
  final _uuid = const Uuid();

  GoalType _selectedGoalType = GoalType.learning;
  int _selectedPriority = 3;
  DateTime? _selectedTargetDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedGoalType = widget.initialGoalType ?? GoalType.learning;
    _selectedPriority = widget.initialPriority ?? 3;
    _selectedTargetDate = widget.initialTargetDate;
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _estimatedMinutesController.text =
        widget.initialEstimatedMinutes?.toString() ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetDateLabel = _selectedTargetDate == null
        ? 'No target date'
        : DateFormat.yMMMd().format(_selectedTargetDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GoalType>(
              initialValue: _selectedGoalType,
              decoration: const InputDecoration(
                labelText: 'Goal type',
                border: OutlineInputBorder(),
              ),
              items: GoalType.values.map((goalType) {
                return DropdownMenuItem<GoalType>(
                  value: goalType,
                  child: Text(goalType.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedGoalType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(5, (index) {
                  final priority = index + 1;
                  return ChoiceChip(
                    label: Text(priority.toString()),
                    selected: _selectedPriority == priority,
                    onSelected: (_) {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickTargetDate,
              icon: const Icon(Icons.flag_rounded),
              label: Text('Target date: $targetDateLabel'),
            ),
            if (_selectedTargetDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTargetDate = null;
                  });
                },
                child: const Text('Clear target date'),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedMinutesController,
              decoration: const InputDecoration(
                labelText: 'Estimated total minutes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }

                final parsed = int.tryParse(trimmed);
                if (parsed == null || parsed <= 0) {
                  return 'Enter a positive number of minutes.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveGoal,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedTargetDate = picked;
    });
  }

  Future<void> _saveGoal() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final goal = LearningGoal(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      description: _normalizeOptionalText(_descriptionController.text),
      goalType: _selectedGoalType,
      targetDate: _selectedTargetDate,
      priority: _selectedPriority,
      status: GoalStatus.active,
      estimatedTotalMinutes: _normalizePositiveInt(
        _estimatedMinutesController.text,
      ),
      createdAt: DateTime.now(),
      completedAt: null,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(goalActionControllerProvider.notifier).addGoal(goal);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(goal.id);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Goal save failed',
        fallbackMessage: 'The goal could not be saved.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  int? _normalizePositiveInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }

  String? _normalizeOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
