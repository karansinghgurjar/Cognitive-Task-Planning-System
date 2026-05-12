import 'package:flutter/material.dart';

import '../../models/knowledge_item.dart';

class DueReviewCard extends StatelessWidget {
  const DueReviewCard({required this.item, required this.onTap, super.key});

  final KnowledgeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(item.title),
        subtitle: Text(
          item.dueReviewAt == null
              ? item.type.label
              : 'Due ${item.dueReviewAt!.toLocal().toString().substring(0, 16)}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
