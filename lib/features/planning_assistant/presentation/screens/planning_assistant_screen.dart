import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/planning_assistant_providers.dart';
import '../widgets/clarification_card.dart';
import 'planning_draft_preview_screen.dart';

class PlanningAssistantScreen extends ConsumerStatefulWidget {
  const PlanningAssistantScreen({super.key, this.initialPrompt});

  final String? initialPrompt;

  @override
  ConsumerState<PlanningAssistantScreen> createState() =>
      _PlanningAssistantScreenState();
}

class _PlanningAssistantScreenState
    extends ConsumerState<PlanningAssistantScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPrompt ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.initialPrompt ?? '').trim().isNotEmpty) {
        ref
            .read(planningAssistantControllerProvider.notifier)
            .setPrompt(widget.initialPrompt!.trim());
        ref.read(planningAssistantControllerProvider.notifier).analyzePrompt();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planningAssistantControllerProvider);
    final controller = ref.read(planningAssistantControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Planning Assistant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          Text(
            'Describe what you want to build, study, or make consistent. CogniPlan will turn that intent into a previewable plan.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  'I want to prepare for GATE over the next 4 months.\nI need a deep work system for weekdays.\nI want to spend 1 hour daily on thesis work.',
            ),
            onChanged: controller.setPrompt,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  controller.setPrompt(_controller.text);
                  controller.analyzePrompt();
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Analyze Intent'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  controller.setPrompt(_controller.text);
                  controller.generateDraft();
                  if (ref.read(planningAssistantControllerProvider).draft !=
                      null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PlanningDraftPreviewScreen(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.preview_rounded),
                label: const Text('Generate Preview'),
              ),
            ],
          ),
          if (state.parsedIntent != null) ...[
            const SizedBox(height: 24),
            _ParsedIntentCard(),
          ],
          if (state.questions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Clarifications',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final question in state.questions) ...[
              ClarificationCard(
                question: question,
                value: state.answers[question.id] ?? '',
                onChanged: (value) {
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .answerQuestion(question.id, value);
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (state.draft != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draft Ready',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.draft!.loadEstimate.summary),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PlanningDraftPreviewScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Open Draft Preview'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParsedIntentCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedIntent = ref
        .watch(planningAssistantControllerProvider)
        .parsedIntent!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intent Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text('Confidence ${(parsedIntent.confidence * 100).round()}%'),
            if (parsedIntent.goals.isNotEmpty)
              Text(
                'Goals: ${parsedIntent.goals.map((goal) => goal.title).join(', ')}',
              ),
            if (parsedIntent.routines.isNotEmpty)
              Text(
                'Routines: ${parsedIntent.routines.map((routine) => routine.title).join(', ')}',
              ),
            if (parsedIntent.ambiguities.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final ambiguity in parsedIntent.ambiguities)
                Text('- $ambiguity'),
            ],
          ],
        ),
      ),
    );
  }
}
