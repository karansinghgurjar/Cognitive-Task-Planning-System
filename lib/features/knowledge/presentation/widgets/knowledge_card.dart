import 'package:flutter/material.dart';

import '../../../../core/widgets/app_status_chip.dart';
import '../../models/knowledge_item.dart';
import 'linked_entity_chip.dart';
import 'resource_status_chip.dart';

class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({required this.item, required this.onTap, super.key});

  final KnowledgeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title.trim().isEmpty ? 'Untitled' : item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ResourceStatusChip(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusChip(label: item.type.label),
                  AppStatusChip(label: item.priority.label),
                  if (item.dueReviewAt != null)
                    const AppStatusChip(label: 'Review queued'),
                  if (item.hasStaleLinks)
                    const AppStatusChip(label: 'Stale link'),
                ],
              ),
              if (item.content?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(
                  item.content!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.links.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.links
                      .take(3)
                      .map((link) => LinkedEntityChip(link: link))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
