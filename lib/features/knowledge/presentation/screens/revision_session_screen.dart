import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../providers/knowledge_providers.dart';
import '../widgets/due_review_card.dart';
import 'knowledge_detail_screen.dart';

class RevisionSessionScreen extends ConsumerWidget {
  const RevisionSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(dueKnowledgeItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Revision Queue')),
      body: dueAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_edu_outlined,
              title: 'Nothing is due right now',
              message:
                  'When notes or resources are scheduled for review, they will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return DueReviewCard(
                item: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => KnowledgeDetailScreen(itemId: item.id),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
