import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../models/knowledge_item.dart';
import '../../providers/knowledge_providers.dart';
import '../widgets/knowledge_card.dart';
import 'knowledge_detail_screen.dart';
import 'knowledge_editor_screen.dart';
import 'revision_session_screen.dart';

class KnowledgeDashboardScreen extends ConsumerWidget {
  const KnowledgeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(knowledgeDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge'),
        actions: [
          IconButton(
            tooltip: 'Revision queue',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RevisionSessionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_edu_rounded),
          ),
          IconButton(
            tooltip: 'Refresh stale links',
            onPressed: () {
              ref
                  .read(knowledgeActionControllerProvider.notifier)
                  .refreshStaleLinks();
            },
            icon: const Icon(Icons.sync_problem_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const KnowledgeEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Knowledge'),
      ),
      body: dashboardAsync.when(
        data: (dashboard) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: 'Inbox', items: dashboard.inbox),
              _Section(title: 'Due for review', items: dashboard.dueReview),
              _Section(
                title: 'Active resources',
                items: dashboard.activeResources,
              ),
              _Section(
                title: 'Linked to current goals',
                items: dashboard.linkedToCurrentGoals,
              ),
              _Section(title: 'Stale links', items: dashboard.staleItems),
              _Section(
                title: 'Recently updated',
                items: dashboard.recentlyUpdated,
              ),
              _Section(
                title: 'Completed this week',
                items: dashboard.completedThisWeek,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<KnowledgeItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: title,
            description: '${items.length} item${items.length == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const AppEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'Nothing here yet',
              message:
                  'This section will fill in as you capture notes, resources, and revision material.',
            )
          else
            Builder(
              builder: (context) {
                return Column(
                  children: items.take(6).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: KnowledgeCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  KnowledgeDetailScreen(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
