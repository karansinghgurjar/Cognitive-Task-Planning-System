import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_section_header.dart';
import '../providers/demo_data_providers.dart';

class DemoDataScreen extends ConsumerWidget {
  const DemoDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDemoAsync = ref.watch(hasDemoDataProvider);
    final actionState = ref.watch(demoDataControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sample Data')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppSectionHeader(
            title: 'Portfolio-safe workspace',
            description:
                'Load a realistic CogniPlan dataset for demos, interviews, and screenshots without exposing personal planning data.',
          ),
          const SizedBox(height: 16),
          if (actionState.isLoading) const LinearProgressIndicator(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: hasDemoAsync.when(
                data: (hasDemo) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasDemo
                          ? 'Sample data is currently loaded.'
                          : 'No sample data is loaded yet.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The sample profile includes goals, tasks, routines, knowledge items, timetable constraints, focus history, and a weekly review snapshot.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: actionState.isLoading
                              ? null
                              : () => _load(context, ref),
                          icon: const Icon(Icons.download_rounded),
                          label: Text(hasDemo ? 'Reload Sample Data' : 'Load Sample Data'),
                        ),
                        OutlinedButton.icon(
                          onPressed: actionState.isLoading || !hasDemo
                              ? null
                              : () => _clear(context, ref),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Clear Sample Data'),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => ErrorBoundaryWidget(error: error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load(BuildContext context, WidgetRef ref) async {
    try {
      final summary = await ref.read(demoDataControllerProvider.notifier).loadSampleData();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loaded sample data: ${summary.goals} goals, ${summary.tasks} tasks, ${summary.routines} routines, and ${summary.knowledgeItems} knowledge items.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Sample data failed',
        fallbackMessage: 'The sample workspace could not be loaded safely.',
      );
    }
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    try {
      final removed = await ref.read(demoDataControllerProvider.notifier).clearSampleData();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $removed sample records.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Sample data cleanup failed',
        fallbackMessage: 'The sample workspace could not be removed safely.',
      );
    }
  }
}
