import 'package:flutter/material.dart';

import '../../domain/models/planning_draft.dart';

class PlanningWarningCard extends StatelessWidget {
  const PlanningWarningCard({required this.warning, super.key});

  final PlanningWarning warning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = switch (warning.severity) {
      PlanningWarningSeverity.info => colorScheme.secondaryContainer,
      PlanningWarningSeverity.caution => colorScheme.tertiaryContainer,
      PlanningWarningSeverity.high => colorScheme.errorContainer,
    };
    final foreground = switch (warning.severity) {
      PlanningWarningSeverity.info => colorScheme.onSecondaryContainer,
      PlanningWarningSeverity.caution => colorScheme.onTertiaryContainer,
      PlanningWarningSeverity.high => colorScheme.onErrorContainer,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warning.message,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            warning.explanation,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
