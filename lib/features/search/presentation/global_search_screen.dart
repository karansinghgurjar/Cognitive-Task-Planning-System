import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../goals/presentation/goal_detail_screen.dart';
import '../../notes/models/entity_note.dart';
import '../../quick_capture/presentation/quick_capture_inbox_screen.dart';
import '../../review/presentation/weekly_review_screen.dart';
import '../../tasks/presentation/task_detail_screen.dart';
import '../domain/search_models.dart';
import '../providers/search_providers.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  static Future<void> show(BuildContext context) async {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.width >= 700) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SizedBox(
            width: 760,
            child: const GlobalSearchScreen(),
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const GlobalSearchScreen(),
    );
  }

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ref.read(searchQueryProvider.notifier).state = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final sectionsAsync = ref.watch(groupedSearchResultsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search tasks, goals, notes, captures, and reviews',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sectionsAsync.when(
                data: (sections) {
                  if (query.trim().isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.search_rounded,
                      title: 'Search your workspace',
                      message:
                          'Search across tasks, goals, notes, quick captures, and weekly reviews.',
                    );
                  }
                  if (sections.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      message:
                          'Try a shorter keyword, check the spelling, or search for a related task or goal.',
                    );
                  }
                  return ListView(
                    children: sections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SearchSectionCard(
                          section: section,
                          onTap: (result) => _openResult(result),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(ErrorHandler.mapError(error).message),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResult(GlobalSearchResult result) async {
    final dialogNavigator = Navigator.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (dialogNavigator.canPop()) {
      dialogNavigator.pop();
    }
    try {
      switch (result.resultType) {
        case SearchResultType.task:
          await rootNavigator.push(
            MaterialPageRoute<void>(
              builder: (_) => TaskDetailScreen(taskId: result.entityId),
            ),
          );
          break;
        case SearchResultType.goal:
          await rootNavigator.push(
            MaterialPageRoute<void>(
              builder: (_) => GoalDetailScreen(goalId: result.entityId),
            ),
          );
          break;
        case SearchResultType.note:
          if (result.parentEntityId == null || result.parentEntityType == null) {
            throw StateError('That note no longer has a valid parent item.');
          }
          if (result.parentEntityType == EntityAttachmentType.task) {
            await rootNavigator.push(
              MaterialPageRoute<void>(
                builder: (_) => TaskDetailScreen(taskId: result.parentEntityId!),
              ),
            );
          } else {
            await rootNavigator.push(
              MaterialPageRoute<void>(
                builder: (_) => GoalDetailScreen(goalId: result.parentEntityId!),
              ),
            );
          }
          break;
        case SearchResultType.capture:
          await rootNavigator.push(
            MaterialPageRoute<void>(
              builder: (_) => QuickCaptureInboxScreen(
                initialCaptureId: result.entityId,
              ),
            ),
          );
          break;
        case SearchResultType.weeklyReview:
          await rootNavigator.push(
            MaterialPageRoute<void>(
              builder: (_) => WeeklyReviewScreen(
                initialWeekStart: result.weekStart,
              ),
            ),
          );
          break;
      }
    } catch (error) {
      if (!rootNavigator.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        rootNavigator.context,
        error,
        fallbackTitle: 'Open failed',
        fallbackMessage: 'The selected search result could not be opened.',
      );
    }
  }
}

class _SearchSectionCard extends StatelessWidget {
  const _SearchSectionCard({
    required this.section,
    required this.onTap,
  });

  final SearchSection section;
  final ValueChanged<GlobalSearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ...section.results.map((result) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SearchResultTile(result: result, onTap: () => onTap(result)),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onTap,
  });

  final GlobalSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(result.resultType)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (result.isArchived)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: _Badge(label: 'Archived'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (result.snippet.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        result.snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(SearchResultType type) {
    switch (type) {
      case SearchResultType.task:
        return Icons.checklist_rounded;
      case SearchResultType.goal:
        return Icons.track_changes_rounded;
      case SearchResultType.note:
        return Icons.sticky_note_2_outlined;
      case SearchResultType.capture:
        return Icons.inbox_rounded;
      case SearchResultType.weeklyReview:
        return Icons.rate_review_outlined;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
