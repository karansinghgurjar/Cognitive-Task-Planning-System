import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../tasks/presentation/task_detail_screen.dart';
import '../../models/knowledge_item.dart';
import '../../providers/knowledge_providers.dart';
import '../widgets/linked_entity_chip.dart';
import 'knowledge_editor_screen.dart';

class KnowledgeDetailScreen extends ConsumerWidget {
  const KnowledgeDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(watchKnowledgeItemProvider(itemId));
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Item')),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const AppEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'Knowledge item not found',
              message: 'It may have been deleted or moved on another device.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenu(context, ref, item, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'task', child: Text('Create Task')),
                      PopupMenuItem(
                        value: 'review',
                        child: Text('Schedule Review'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusChip(label: item.type.label),
                  AppStatusChip(label: item.status.label),
                  AppStatusChip(label: item.priority.label),
                  if (item.reviewCount > 0)
                    AppStatusChip(label: 'Reviews ${item.reviewCount}'),
                ],
              ),
              if (item.content?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text(item.content!),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
              ],
              if (item.links.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Linked entities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.links
                      .map((link) => LinkedEntityChip(link: link))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Review actions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReviewDifficulty.values.map((difficulty) {
                  return FilledButton.tonal(
                    onPressed: () =>
                        _recordReview(context, ref, item, difficulty),
                    child: Text(difficulty.label),
                  );
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(ErrorHandler.mapError(error).message)),
      ),
    );
  }

  Future<void> _handleMenu(
    BuildContext context,
    WidgetRef ref,
    KnowledgeItem item,
    String value,
  ) async {
    try {
      switch (value) {
        case 'edit':
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => KnowledgeEditorScreen(initialItem: item),
            ),
          );
          break;
        case 'task':
          final task = await ref
              .read(knowledgeActionControllerProvider.notifier)
              .createTaskFromItem(item);
          if (context.mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskDetailScreen(taskId: task.id),
              ),
            );
          }
          break;
        case 'review':
          await ref
              .read(knowledgeActionControllerProvider.notifier)
              .scheduleReview(
                item,
                DateTime.now().add(const Duration(days: 1)),
              );
          break;
        case 'delete':
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Delete knowledge item?',
            message: 'This removes the item permanently from this workspace.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (confirmed == true) {
            await ref
                .read(knowledgeActionControllerProvider.notifier)
                .deleteItem(item.id);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
          break;
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Knowledge action failed',
        fallbackMessage: 'That knowledge action could not be completed.',
      );
    }
  }

  Future<void> _recordReview(
    BuildContext context,
    WidgetRef ref,
    KnowledgeItem item,
    ReviewDifficulty difficulty,
  ) async {
    try {
      await ref
          .read(knowledgeActionControllerProvider.notifier)
          .recordReview(item, difficulty);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Review update failed',
        fallbackMessage: 'The review schedule could not be updated.',
      );
    }
  }
}
