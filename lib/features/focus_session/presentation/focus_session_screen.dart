import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/focus_session_providers.dart';

class FocusSessionScreen extends ConsumerWidget {
  const FocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(focusSessionControllerProvider, (previous, next) {
      if (previous != null && next == null && context.mounted) {
        Navigator.of(context).pop();
      }
    });

    final session = ref.watch(focusSessionControllerProvider);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Focus Session')),
        body: const Center(child: Text('No active focus session.')),
      );
    }

    final controller = ref.read(focusSessionControllerProvider.notifier);
    final minutes = session.remainingSeconds ~/ 60;
    final seconds = session.remainingSeconds % 60;
    final status = session.isPaused ? 'Paused' : 'Running';

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Session')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                session.taskTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Planned session: ${session.plannedDurationMinutes} min',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: session.completionPercentage.clamp(0, 1),
                      strokeWidth: 12,
                    ),
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                status,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: session.isPaused
                        ? controller.resumeSession
                        : controller.pauseSession,
                    icon: Icon(
                      session.isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                    label: Text(session.isPaused ? 'Resume' : 'Pause'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => controller.completeSession(),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Complete Now'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context, controller),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel Session'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    FocusSessionController controller,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel focus session?'),
          content: const Text(
            'This will stop the timer and leave the planned session incomplete.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Going'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel Session'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await controller.cancelSession();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
