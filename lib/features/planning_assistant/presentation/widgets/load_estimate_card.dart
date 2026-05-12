import 'package:flutter/material.dart';

import '../../domain/models/planning_draft.dart';

class LoadEstimateCard extends StatelessWidget {
  const LoadEstimateCard({required this.estimate, super.key});

  final PlanningLoadEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Load',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(estimate.summary),
            const SizedBox(height: 8),
            Text(
              'Recurring: ${_formatMinutes(estimate.routineMinutes)} | Setup: ${_formatMinutes(estimate.taskMinutes)}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) {
      return '${remainder}m';
    }
    if (remainder == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainder}m';
  }
}
