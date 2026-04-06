import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../models/quick_capture_item.dart';
import '../providers/quick_capture_providers.dart';
import 'quick_capture_inbox_screen.dart';

enum QuickCaptureEntryMode { auto, task, goal, note }

class QuickCaptureSheet extends ConsumerStatefulWidget {
  const QuickCaptureSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final mediaQuery = MediaQuery.of(context);
    final useDialog = mediaQuery.size.width >= 700;
    if (useDialog) {
      await showDialog<void>(
        context: context,
        builder: (_) => const Dialog(child: QuickCaptureSheet()),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const QuickCaptureSheet(),
    );
  }

  @override
  ConsumerState<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends ConsumerState<QuickCaptureSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  QuickCaptureEntryMode _mode = QuickCaptureEntryMode.auto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets.bottom),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quick Capture',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Open inbox',
                  onPressed: _isSaving ? null : _openInbox,
                  icon: const Icon(Icons.inbox_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Capture a task, goal, or note without opening the full creation flow.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_isSaving,
              minLines: 4,
              maxLines: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _capture(),
              decoration: const InputDecoration(
                hintText:
                    'Revise Java OOP\nPrepare DSA arrays\nLearn REST APIs',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: QuickCaptureEntryMode.values.map((mode) {
                final selected = _mode == mode;
                return ChoiceChip(
                  label: Text(_modeLabel(mode)),
                  selected: selected,
                  onSelected: _isSaving
                      ? null
                      : (_) {
                          setState(() {
                            _mode = mode;
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _capture,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt_rounded),
                  label: Text(_isSaving ? 'Capturing...' : 'Capture'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capture() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ErrorHandler.showSnackBar(
        context,
        StateError('Capture text cannot be empty.'),
        fallbackTitle: 'Capture failed',
        fallbackMessage: 'Enter something to capture first.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(quickCaptureActionControllerProvider.notifier)
          .addCaptureFromText(text, suggestedType: _manualSuggestedType());
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Captured to inbox.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Capture failed',
        fallbackMessage: 'The item could not be captured.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openInbox() async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => const QuickCaptureInboxScreen()),
    );
  }

  QuickCaptureSuggestedType? _manualSuggestedType() {
    switch (_mode) {
      case QuickCaptureEntryMode.auto:
        return null;
      case QuickCaptureEntryMode.task:
        return QuickCaptureSuggestedType.task;
      case QuickCaptureEntryMode.goal:
        return QuickCaptureSuggestedType.goal;
      case QuickCaptureEntryMode.note:
        return QuickCaptureSuggestedType.note;
    }
  }

  String _modeLabel(QuickCaptureEntryMode mode) {
    switch (mode) {
      case QuickCaptureEntryMode.auto:
        return 'Auto';
      case QuickCaptureEntryMode.task:
        return 'Task';
      case QuickCaptureEntryMode.goal:
        return 'Goal';
      case QuickCaptureEntryMode.note:
        return 'Note';
    }
  }
}
