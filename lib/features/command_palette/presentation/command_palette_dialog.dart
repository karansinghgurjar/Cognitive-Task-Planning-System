import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../domain/command_models.dart';
import '../domain/entity_launcher_service.dart';
import '../providers/command_palette_providers.dart';

class CommandPaletteDialog extends ConsumerStatefulWidget {
  const CommandPaletteDialog({required this.hostContext, super.key});

  final BuildContext hostContext;

  static Future<void> show(BuildContext context) async {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.width >= 700) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: SizedBox(
            width: 680,
            child: CommandPaletteDialog(hostContext: context),
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CommandPaletteDialog(hostContext: context),
    );
  }

  @override
  ConsumerState<CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

sealed class _PaletteResult {
  String get title;
  String? get subtitle;
}

class _CommandPaletteResult extends _PaletteResult {
  _CommandPaletteResult(this.match);

  final CommandMatchResult match;

  @override
  String get title => match.command.title;

  @override
  String? get subtitle => match.command.subtitle;
}

class _EntityPaletteResult extends _PaletteResult {
  _EntityPaletteResult(this.entity);

  final LauncherEntityResult entity;

  @override
  String get title => entity.title;

  @override
  String? get subtitle => entity.subtitle;
}

class _CommandPaletteDialogState extends ConsumerState<CommandPaletteDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;

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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final commandMatches = ref.watch(matchedCommandsProvider);
    final entityMatches = ref.watch(matchedLauncherEntitiesProvider);
    final combinedResults = <_PaletteResult>[
      ...commandMatches.map(_CommandPaletteResult.new),
      ...entityMatches.map(_EntityPaletteResult.new),
    ];
    if (_selectedIndex >= combinedResults.length &&
        combinedResults.isNotEmpty) {
      _selectedIndex = combinedResults.length - 1;
    } else if (combinedResults.isEmpty) {
      _selectedIndex = 0;
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveSelectionIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveSelectionIntent(-1),
        SingleActivator(LogicalKeyboardKey.enter): _SubmitSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveSelectionIntent: CallbackAction<_MoveSelectionIntent>(
            onInvoke: (intent) {
              _moveSelection(intent.delta, combinedResults.length);
              return null;
            },
          ),
          _SubmitSelectionIntent: CallbackAction<_SubmitSelectionIntent>(
            onInvoke: (_) {
              if (combinedResults.isNotEmpty) {
                _execute(combinedResults[_selectedIndex]);
              }
              return null;
            },
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: screenHeight * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Command Palette',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search commands, tasks, and goals',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    ref.read(commandPaletteQueryProvider.notifier).state =
                        value;
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  onSubmitted: (_) {
                    if (combinedResults.isNotEmpty) {
                      _execute(combinedResults[_selectedIndex]);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: combinedResults.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No commands or items match your search.',
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: combinedResults.length,
                          itemBuilder: (context, index) {
                            final result = combinedResults[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: switch (result) {
                                _CommandPaletteResult() => _CommandRow(
                                  match: result.match,
                                  selected: index == _selectedIndex,
                                  onTap: () => _execute(result),
                                ),
                                _EntityPaletteResult() => _EntityRow(
                                  entity: result.entity,
                                  selected: index == _selectedIndex,
                                  onTap: () => _execute(result),
                                ),
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _moveSelection(int delta, int count) {
    if (count <= 0) {
      return;
    }
    setState(() {
      final next = _selectedIndex + delta;
      if (next < 0) {
        _selectedIndex = count - 1;
      } else if (next >= count) {
        _selectedIndex = 0;
      } else {
        _selectedIndex = next;
      }
    });
  }

  Future<void> _execute(_PaletteResult result) async {
    Navigator.of(context).pop();
    CommandExecutionResult executionResult;
    switch (result) {
      case _CommandPaletteResult():
        executionResult = await ref
            .read(commandExecutionServiceProvider)
            .executeCommand(
              context: widget.hostContext,
              ref: ref,
              command: result.match.command,
            );
        break;
      case _EntityPaletteResult():
        executionResult = await ref
            .read(commandExecutionServiceProvider)
            .executeEntity(context: widget.hostContext, entity: result.entity);
        break;
    }

    if (!widget.hostContext.mounted ||
        executionResult.success ||
        executionResult.message == null) {
      return;
    }
    ErrorHandler.showSnackBar(
      widget.hostContext,
      StateError(executionResult.message!),
      fallbackTitle: 'Command failed',
      fallbackMessage: executionResult.message!,
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.match,
    required this.selected,
    required this.onTap,
  });

  final CommandMatchResult match;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final command = match.command;
    return Semantics(
      button: true,
      label: command.title,
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(command.icon),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width >= 480 ? 320 : 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        command.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (command.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(command.subtitle!),
                      ],
                    ],
                  ),
                ),
                _CategoryBadge(label: command.category.label),
                if (!command.isEnabled) ...[
                  const _CategoryBadge(label: 'Unavailable'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntityRow extends StatelessWidget {
  const _EntityRow({
    required this.entity,
    required this.selected,
    required this.onTap,
  });

  final LauncherEntityResult entity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = entity.entityType == LauncherEntityType.task
        ? Icons.checklist_rounded
        : Icons.track_changes_rounded;
    final label = entity.entityType == LauncherEntityType.task
        ? 'Task'
        : 'Goal';
    return Semantics(
      button: true,
      label: entity.title,
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(icon),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width >= 480 ? 320 : 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(entity.subtitle),
                    ],
                  ),
                ),
                _CategoryBadge(label: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _MoveSelectionIntent extends Intent {
  const _MoveSelectionIntent(this.delta);

  final int delta;
}

class _SubmitSelectionIntent extends Intent {
  const _SubmitSelectionIntent();
}
