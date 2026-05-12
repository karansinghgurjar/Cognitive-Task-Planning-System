import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../models/knowledge_item.dart';
import '../../providers/knowledge_providers.dart';
import '../screens/knowledge_detail_screen.dart';
import '../screens/knowledge_editor_screen.dart';
import 'knowledge_card.dart';

class LinkedKnowledgeSection extends ConsumerWidget {
  const LinkedKnowledgeSection({
    required this.entityType,
    required this.entityId,
    required this.title,
    super.key,
  });

  final LinkedEntityType entityType;
  final String entityId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(watchKnowledgeItemsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KnowledgeEditorScreen(
                      initialLinks: [
                        EntityLink(entityId: entityId, entityType: entityType),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_stories_rounded),
              label: const Text('Add Knowledge'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        itemsAsync.when(
          data: (items) {
            final linked = items.where((item) {
              return item.links.any(
                (link) =>
                    link.entityType == entityType && link.entityId == entityId,
              );
            }).toList();
            if (linked.isEmpty) {
              return const AppEmptyState(
                icon: Icons.auto_stories_outlined,
                title: 'No knowledge items yet',
                message:
                    'Capture notes, resources, or revision material and keep it linked to this work.',
              );
            }
            return Column(
              children: linked.take(4).map((item) {
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
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('$error'),
        ),
      ],
    );
  }
}
