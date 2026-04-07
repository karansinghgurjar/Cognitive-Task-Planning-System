import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../domain/resource_url_validator.dart';
import '../models/entity_note.dart';
import '../models/entity_resource.dart';
import '../providers/notes_providers.dart';

class AddEditResourceScreen extends ConsumerStatefulWidget {
  const AddEditResourceScreen({
    required this.entityType,
    required this.entityId,
    super.key,
    this.initialResource,
  });

  final EntityAttachmentType entityType;
  final String entityId;
  final EntityResource? initialResource;

  bool get isEditing => initialResource != null;

  @override
  ConsumerState<AddEditResourceScreen> createState() =>
      _AddEditResourceScreenState();
}

class _AddEditResourceScreenState extends ConsumerState<AddEditResourceScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  late EntityResourceType _resourceType;
  bool _isPinned = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialResource?.title ?? '';
    _urlController.text = widget.initialResource?.url ?? '';
    _descriptionController.text = widget.initialResource?.description ?? '';
    _resourceType =
        widget.initialResource?.resourceType ?? EntityResourceType.link;
    _isPinned = widget.initialResource?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Resource' : 'Add Resource'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 24 + bottomInset),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) =>
                  ResourceUrlValidator.validateOptionalUrl(value ?? ''),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EntityResourceType>(
              initialValue: _resourceType,
              decoration: const InputDecoration(
                labelText: 'Resource Type',
                border: OutlineInputBorder(),
              ),
              items: EntityResourceType.values.map((value) {
                return DropdownMenuItem(value: value, child: Text(value.label));
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _resourceType = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin resource'),
              subtitle: const Text('Pinned resources stay at the top.'),
              value: _isPinned,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _isPinned = value;
                      });
                    },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Resource'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      final now = DateTime.now();
      final url = _normalizeOptional(_urlController.text);
      final description = _normalizeOptional(_descriptionController.text);
      final existing = widget.initialResource;
      final resource = existing == null
          ? EntityResource(
              id: _uuid.v4(),
              entityType: widget.entityType,
              entityId: widget.entityId,
              title: _titleController.text.trim(),
              url: url,
              description: description,
              resourceType: _resourceType,
              createdAt: now,
              updatedAt: now,
              isPinned: _isPinned,
            )
          : existing.copyWith(
              title: _titleController.text.trim(),
              url: url,
              clearUrl: url == null,
              description: description,
              clearDescription: description == null,
              resourceType: _resourceType,
              updatedAt: now,
              isPinned: _isPinned,
            );

      final controller = ref.read(resourcesActionControllerProvider.notifier);
      if (existing == null) {
        await controller.addResource(resource);
      } else {
        await controller.updateResource(resource);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Resource save failed',
        fallbackMessage: 'The resource could not be saved.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _normalizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
