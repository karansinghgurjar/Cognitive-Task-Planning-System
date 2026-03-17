import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _resourceUrlController = TextEditingController();
  final _resourceTagController = TextEditingController();
  final _uuid = const Uuid();

  TaskType _selectedType = TaskType.study;
  int _selectedPriority = 3;
  DateTime? _selectedDueDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedDurationController.dispose();
    _resourceUrlController.dispose();
    _resourceTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dueDateLabel = _selectedDueDate == null
        ? 'No due date'
        : DateFormat.yMMMd().format(_selectedDueDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
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
              textInputAction: TextInputAction.next,
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
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: TaskType.values.map((type) {
                return DropdownMenuItem<TaskType>(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedDurationController,
              decoration: const InputDecoration(
                labelText: 'Estimated duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a positive number of minutes.';
                }
                return null;
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
              onPressed: _pickDueDate,
              icon: const Icon(Icons.event_available_rounded),
              label: Text('Due date: $dueDateLabel'),
            ),
            if (_selectedDueDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDueDate = null;
                  });
                },
                child: const Text('Clear due date'),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _resourceUrlController,
              decoration: const InputDecoration(
                labelText: 'Resource URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }

                final uri = Uri.tryParse(trimmed);
                if (uri == null ||
                    !uri.hasScheme ||
                    !(uri.scheme == 'http' || uri.scheme == 'https')) {
                  return 'Enter a valid http or https URL.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resourceTagController,
              decoration: const InputDecoration(
                labelText: 'Resource tag',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveTask,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDueDate = picked;
    });
  }

  Future<void> _saveTask() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final task = Task(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      description: _normalizeOptionalText(_descriptionController.text),
      type: _selectedType,
      estimatedDurationMinutes: int.parse(_estimatedDurationController.text),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      resourceUrl: _normalizeOptionalText(_resourceUrlController.text),
      resourceTag: _normalizeOptionalText(_resourceTagController.text),
      isCompleted: false,
      createdAt: DateTime.now(),
      completedAt: null,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(taskActionControllerProvider.notifier).addTask(task);
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
        fallbackTitle: 'Task save failed',
        fallbackMessage: 'The task could not be saved.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _normalizeOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
