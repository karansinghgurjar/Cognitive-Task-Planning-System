import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_handler.dart';
import '../../models/knowledge_item.dart';
import '../../providers/knowledge_providers.dart';

class KnowledgeEditorScreen extends ConsumerStatefulWidget {
  const KnowledgeEditorScreen({
    super.key,
    this.initialItem,
    this.initialLinks = const <EntityLink>[],
  });

  final KnowledgeItem? initialItem;
  final List<EntityLink> initialLinks;

  @override
  ConsumerState<KnowledgeEditorScreen> createState() =>
      _KnowledgeEditorScreenState();
}

class _KnowledgeEditorScreenState extends ConsumerState<KnowledgeEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  late final TextEditingController _sourceUrlController;
  late final TextEditingController _localFileController;
  late final TextEditingController _externalReferenceController;
  late KnowledgeItemType _type;
  late KnowledgeStatus _status;
  late KnowledgePriority _priority;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _tagsController = TextEditingController(text: item?.tags.join(', ') ?? '');
    _sourceUrlController = TextEditingController(text: item?.sourceUrl ?? '');
    _localFileController = TextEditingController(
      text: item?.localFilePath ?? '',
    );
    _externalReferenceController = TextEditingController(
      text: item?.externalReference ?? '',
    );
    _type = item?.type ?? KnowledgeItemType.note;
    _status = item?.status ?? KnowledgeStatus.inbox;
    _priority = item?.priority ?? KnowledgePriority.normal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _sourceUrlController.dispose();
    _localFileController.dispose();
    _externalReferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Knowledge Item' : 'New Knowledge Item'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Content'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<KnowledgeItemType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: KnowledgeItemType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.label));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<KnowledgeStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: KnowledgeStatus.values.map((status) {
              return DropdownMenuItem(value: status, child: Text(status.label));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<KnowledgePriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: KnowledgePriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sourceUrlController,
            decoration: const InputDecoration(labelText: 'Source URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _localFileController,
            decoration: const InputDecoration(labelText: 'Local File Path'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _externalReferenceController,
            decoration: const InputDecoration(labelText: 'External Reference'),
          ),
          if (widget.initialLinks.isNotEmpty ||
              (widget.initialItem?.links.isNotEmpty ?? false)) ...[
            const SizedBox(height: 16),
            Text(
              'Links',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.initialItem?.links ?? widget.initialLinks).map((
                link,
              ) {
                final text = link.relationLabel?.trim().isNotEmpty == true
                    ? '${link.entityType.label}: ${link.relationLabel}'
                    : link.entityType.label;
                return Chip(label: Text(text));
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ErrorHandler.showSnackBar(
        context,
        StateError('Add a title or some content before saving.'),
        fallbackTitle: 'Knowledge item is empty',
        fallbackMessage: 'Add a title or some content before saving.',
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialItem;
    final item = KnowledgeItem(
      id: existing?.id ?? ref.read(knowledgeUuidProvider).v4(),
      title: title.isEmpty ? 'Untitled' : title,
      content: content.isEmpty ? null : content,
      type: _type,
      status: _status,
      priority: _priority,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      dueReviewAt: existing?.dueReviewAt,
      lastReviewedAt: existing?.lastReviewedAt,
      reviewCount: existing?.reviewCount ?? 0,
      reviewIntervalDays: existing?.reviewIntervalDays,
      tags: _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      sourceUrl: _sourceUrlController.text.trim().isEmpty
          ? null
          : _sourceUrlController.text.trim(),
      localFilePath: _localFileController.text.trim().isEmpty
          ? null
          : _localFileController.text.trim(),
      externalReference: _externalReferenceController.text.trim().isEmpty
          ? null
          : _externalReferenceController.text.trim(),
      links: existing?.links ?? widget.initialLinks,
    );

    try {
      final controller = ref.read(knowledgeActionControllerProvider.notifier);
      if (existing == null) {
        await controller.addItem(item);
      } else {
        await controller.updateItem(item);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Save failed',
        fallbackMessage: 'The knowledge item could not be saved.',
      );
    }
  }
}
