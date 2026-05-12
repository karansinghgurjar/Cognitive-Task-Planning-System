import 'package:flutter/material.dart';

import '../../../../core/widgets/app_status_chip.dart';
import '../../models/knowledge_item.dart';

class LinkedEntityChip extends StatelessWidget {
  const LinkedEntityChip({required this.link, super.key});

  final EntityLink link;

  @override
  Widget build(BuildContext context) {
    final label = link.relationLabel?.trim().isNotEmpty == true
        ? '${link.entityType.label}: ${link.relationLabel}'
        : link.entityType.label;
    return AppStatusChip(label: link.isStale ? '$label (stale)' : label);
  }
}
