import 'package:flutter/material.dart';

import '../../../../core/widgets/app_status_chip.dart';
import '../../models/knowledge_item.dart';

class ResourceStatusChip extends StatelessWidget {
  const ResourceStatusChip({required this.status, super.key});

  final KnowledgeStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(label: status.label);
  }
}
