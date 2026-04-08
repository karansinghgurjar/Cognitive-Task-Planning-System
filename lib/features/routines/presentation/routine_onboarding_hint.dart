import 'package:flutter/material.dart';

class RoutineOnboardingHint extends StatelessWidget {
  const RoutineOnboardingHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Building Your Routine System',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Start with a starter pack or one simple routine.'),
            const SizedBox(height: 4),
            const Text('Fixed blocks protect time. Flexible blocks ask the planner to place them.'),
            const SizedBox(height: 4),
            const Text('Recovery only matters when you miss a block and want to re-place it later.'),
          ],
        ),
      ),
    );
  }
}
