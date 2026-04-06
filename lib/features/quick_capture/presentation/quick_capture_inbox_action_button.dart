import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quick_capture_providers.dart';
import 'quick_capture_inbox_screen.dart';

class QuickCaptureInboxActionButton extends ConsumerWidget {
  const QuickCaptureInboxActionButton({
    super.key,
    this.tooltip = 'Open Quick Capture inbox',
  });

  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount =
        ref.watch(unprocessedCaptureCountProvider).valueOrNull ?? 0;

    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const QuickCaptureInboxScreen(),
          ),
        );
      },
      tooltip: inboxCount > 0 ? '$tooltip ($inboxCount)' : tooltip,
      icon: Badge.count(
        count: inboxCount,
        isLabelVisible: inboxCount > 0,
        child: const Icon(Icons.inbox_rounded),
      ),
    );
  }
}
