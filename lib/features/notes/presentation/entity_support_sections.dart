import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../domain/resource_url_validator.dart';
import '../models/entity_note.dart';
import '../models/entity_resource.dart';
import '../providers/notes_providers.dart';
import 'add_edit_note_screen.dart';
import 'add_edit_resource_screen.dart';

class EntityNotesSection extends ConsumerWidget {
  const EntityNotesSection({
    required this.entityType,
    required this.entityId,
    required this.title,
    super.key,
  });

  final EntityAttachmentType entityType;
  final String entityId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(
      watchNotesForEntityProvider(
        EntityAttachmentTarget(entityType: entityType, entityId: entityId),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _openAddNote(context),
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('Add Note'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return AppEmptyState(
                icon: Icons.sticky_note_2_outlined,
                title: 'No notes yet',
                message:
                    'Use notes for revision reminders, implementation details, and context you want to keep close to this item.',
                action: FilledButton.tonal(
                  onPressed: () => _openAddNote(context),
                  child: const Text('Add Note'),
                ),
              );
            }
            return Column(
              children: notes.map((note) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NoteCard(note: note),
                );
              }).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(ErrorHandler.mapError(error).message),
        ),
      ],
    );
  }

  Future<void> _openAddNote(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditNoteScreen(
          entityType: entityType,
          entityId: entityId,
        ),
      ),
    );
  }
}

class EntityResourcesSection extends ConsumerWidget {
  const EntityResourcesSection({
    required this.entityType,
    required this.entityId,
    required this.title,
    super.key,
  });

  final EntityAttachmentType entityType;
  final String entityId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(
      watchResourcesForEntityProvider(
        EntityAttachmentTarget(entityType: entityType, entityId: entityId),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _openAddResource(context),
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Add Resource'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        resourcesAsync.when(
          data: (resources) {
            if (resources.isEmpty) {
              return AppEmptyState(
                icon: Icons.link_rounded,
                title: 'No resources yet',
                message:
                    'Attach links, videos, repos, articles, or references you want to use while working on this item.',
                action: FilledButton.tonal(
                  onPressed: () => _openAddResource(context),
                  child: const Text('Add Resource'),
                ),
              );
            }
            return Column(
              children: resources.map((resource) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResourceCard(resource: resource),
                );
              }).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(ErrorHandler.mapError(error).message),
        ),
      ],
    );
  }

  Future<void> _openAddResource(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditResourceScreen(
          entityType: entityType,
          entityId: entityId,
        ),
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note});

  final EntityNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(note.title?.trim().isNotEmpty == true ? note.title! : 'Untitled Note'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (note.isPinned) const AppStatusChip(label: 'Pinned'),
                AppStatusChip(label: note.entityType.label),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _edit(context),
        trailing: PopupMenuButton<_NoteAction>(
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _NoteAction.pinToggle,
              child: Text(note.isPinned ? 'Unpin' : 'Pin'),
            ),
            const PopupMenuItem(
              value: _NoteAction.edit,
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: _NoteAction.delete,
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _NoteAction action,
  ) async {
    try {
      switch (action) {
        case _NoteAction.pinToggle:
          await ref
              .read(notesActionControllerProvider.notifier)
              .setPinned(note.id, !note.isPinned);
          break;
        case _NoteAction.edit:
          await _edit(context);
          break;
        case _NoteAction.delete:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Delete note?',
            message: 'This note will be removed permanently.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (confirmed == true) {
            await ref.read(notesActionControllerProvider.notifier).deleteNote(note.id);
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
        fallbackTitle: 'Note action failed',
        fallbackMessage: 'The note could not be updated.',
      );
    }
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditNoteScreen(
          entityType: note.entityType,
          entityId: note.entityId,
          initialNote: note,
        ),
      ),
    );
  }
}

class _ResourceCard extends ConsumerWidget {
  const _ResourceCard({required this.resource});

  final EntityResource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ResourceUrlValidator.hostLabel(resource.url);
    return Card(
      child: ListTile(
        title: Text(resource.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusChip(label: resource.resourceType.label),
                if (resource.isPinned) const AppStatusChip(label: 'Pinned'),
                if (host != null) AppStatusChip(label: host),
              ],
            ),
            if (resource.description != null &&
                resource.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                resource.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (resource.url != null && resource.url!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                resource.url!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        isThreeLine: true,
        onTap: () => _edit(context),
        trailing: PopupMenuButton<_ResourceAction>(
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (context) => [
            if (resource.url != null && resource.url!.trim().isNotEmpty)
              const PopupMenuItem(
                value: _ResourceAction.open,
                child: Text('Open link'),
              ),
            PopupMenuItem(
              value: _ResourceAction.pinToggle,
              child: Text(resource.isPinned ? 'Unpin' : 'Pin'),
            ),
            const PopupMenuItem(
              value: _ResourceAction.edit,
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: _ResourceAction.delete,
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ResourceAction action,
  ) async {
    try {
      switch (action) {
        case _ResourceAction.open:
          final opened = await ref
              .read(resourceLinkServiceProvider)
              .openUrl(resource.url);
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The link could not be opened safely.')),
            );
          }
          break;
        case _ResourceAction.pinToggle:
          await ref
              .read(resourcesActionControllerProvider.notifier)
              .setPinned(resource.id, !resource.isPinned);
          break;
        case _ResourceAction.edit:
          await _edit(context);
          break;
        case _ResourceAction.delete:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Delete resource?',
            message: 'This resource will be removed permanently.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (confirmed == true) {
            await ref
                .read(resourcesActionControllerProvider.notifier)
                .deleteResource(resource.id);
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
        fallbackTitle: 'Resource action failed',
        fallbackMessage: 'The resource could not be updated.',
      );
    }
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditResourceScreen(
          entityType: resource.entityType,
          entityId: resource.entityId,
          initialResource: resource,
        ),
      ),
    );
  }
}

enum _NoteAction { pinToggle, edit, delete }

enum _ResourceAction { open, pinToggle, edit, delete }
