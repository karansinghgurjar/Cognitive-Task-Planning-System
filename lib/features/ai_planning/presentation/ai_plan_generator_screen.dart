import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/ai_planning_models.dart';
import '../providers/ai_planning_providers.dart';
import 'ai_plan_preview_screen.dart';

class AiPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AiPlanGeneratorScreen({
    super.key,
    this.existingGoalId,
    this.initialPrompt,
    this.initialTargetDate,
    this.initialPriority = 3,
    this.title = 'Generate Plan with AI',
  });

  final String? existingGoalId;
  final String? initialPrompt;
  final DateTime? initialTargetDate;
  final int initialPriority;
  final String title;

  @override
  ConsumerState<AiPlanGeneratorScreen> createState() =>
      _AiPlanGeneratorScreenState();
}

class _AiPlanGeneratorScreenState extends ConsumerState<AiPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _promptController;

  DateTime? _targetDate;
  late int _priority;
  PlanningIntensity _intensity = PlanningIntensity.balanced;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.initialPrompt ?? '');
    _targetDate = widget.initialTargetDate;
    _priority = widget.initialPriority;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(aiPlanningControllerProvider);
    final planningOpportunityAsync = ref.watch(aiPlanningOpportunityProvider);
    final targetDateLabel = _targetDate == null
        ? 'No target date'
        : DateFormat.yMMMd().format(_targetDate!);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Describe what you want to learn or complete.',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'The planner will turn your prompt into a goal, milestones, tasks, durations, and dependencies using offline heuristics.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            planningOpportunityAsync.when(
              data: (message) => message == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InfoCard(message: message),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            TextFormField(
              controller: _promptController,
              minLines: 6,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Describe what you want to learn or complete...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a goal or work description.';
                }
                if (value.trim().length < 10) {
                  return 'Give the planner more context than a short title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Planning mode',
                border: OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PlanningIntensity.values.map((intensity) {
                  return ChoiceChip(
                    label: Text(_intensityLabel(intensity)),
                    selected: _intensity == intensity,
                    onSelected: (_) {
                      setState(() {
                        _intensity = intensity;
                      });
                    },
                  );
                }).toList(),
              ),
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
                  final value = index + 1;
                  return ChoiceChip(
                    label: Text(value.toString()),
                    selected: _priority == value,
                    onSelected: (_) {
                      setState(() {
                        _priority = value;
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
            if (_targetDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _targetDate = null),
                  child: const Text('Clear target date'),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isGenerating || actionState.isLoading
                  ? null
                  : _generatePlan,
              icon: _isGenerating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Preview'),
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
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _targetDate = picked;
    });
  }

  Future<void> _generatePlan() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final request = NaturalLanguagePlanRequest(
      prompt: _promptController.text.trim(),
      targetDate: _targetDate,
      priority: _priority,
      intensity: _intensity,
      existingGoalId: widget.existingGoalId,
    );

    try {
      final preview = await ref
          .read(aiPlanningControllerProvider.notifier)
          .generatePreview(request);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AiPlanPreviewScreen(
            initialPreview: preview,
            existingGoalId: widget.existingGoalId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate plan: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  String _intensityLabel(PlanningIntensity intensity) {
    switch (intensity) {
      case PlanningIntensity.conservative:
        return 'Conservative';
      case PlanningIntensity.balanced:
        return 'Balanced';
      case PlanningIntensity.aggressive:
        return 'Aggressive';
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
