import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../models/entity_note.dart';
import '../providers/notes_providers.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  const AddEditNoteScreen({
    required this.entityType,
    required this.entityId,
    super.key,
    this.initialNote,
  });

  final EntityAttachmentType entityType;
  final String entityId;
  final EntityNote? initialNote;

  bool get isEditing => initialNote != null;

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialNote?.title ?? '';
    _contentController.text = widget.initialNote?.content ?? '';
    _isPinned = widget.initialNote?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'Add Note'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 6,
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Content is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin note'),
              subtitle: const Text('Pinned notes stay at the top.'),
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
              label: Text(_isSaving ? 'Saving...' : 'Save Note'),
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
      final title = _normalizeOptionalText(_titleController.text);
      final existing = widget.initialNote;
      final note = existing == null
          ? EntityNote(
              id: _uuid.v4(),
              entityType: widget.entityType,
              entityId: widget.entityId,
              title: title,
              content: _contentController.text.trim(),
              createdAt: now,
              updatedAt: now,
              isPinned: _isPinned,
            )
          : existing.copyWith(
              title: title,
              clearTitle: title == null,
              content: _contentController.text.trim(),
              updatedAt: now,
              isPinned: _isPinned,
            );

      final controller = ref.read(notesActionControllerProvider.notifier);
      if (existing == null) {
        await controller.addNote(note);
      } else {
        await controller.updateNote(note);
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
        fallbackTitle: 'Note save failed',
        fallbackMessage: 'The note could not be saved.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _normalizeOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
