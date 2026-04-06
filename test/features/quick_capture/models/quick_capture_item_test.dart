import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/quick_capture/models/quick_capture_item.dart';

void main() {
  test('quick capture item defaults to inbox-friendly unprocessed state', () {
    final createdAt = DateTime(2026, 4, 6, 9, 30);
    final item = QuickCaptureItem(
      id: 'capture-1',
      rawText: 'Revise Java OOP',
      createdAt: createdAt,
    );

    expect(item.updatedAt, createdAt);
    expect(item.suggestedType, QuickCaptureSuggestedType.unknown);
    expect(item.isProcessed, isFalse);
    expect(item.processedAt, isNull);
    expect(item.linkedEntityId, isNull);
    expect(item.processedEntityType, isNull);
    expect(item.isArchived, isFalse);
  });

  test('copyWith preserves identity and supports processing transitions', () {
    final original = QuickCaptureItem(
      id: 'capture-2',
      rawText: 'Prepare DSA arrays',
      createdAt: DateTime(2026, 4, 6, 10),
    )..isarId = 42;
    final processedAt = DateTime(2026, 4, 6, 12);

    final updated = original.copyWith(
      suggestedType: QuickCaptureSuggestedType.task,
      isProcessed: true,
      processedAt: processedAt,
      linkedEntityId: 'task-1',
      processedEntityType: QuickCaptureProcessedEntityType.task,
      isArchived: true,
      updatedAt: processedAt,
    );

    expect(updated.isarId, 42);
    expect(updated.suggestedType, QuickCaptureSuggestedType.task);
    expect(updated.isProcessed, isTrue);
    expect(updated.processedAt, processedAt);
    expect(updated.linkedEntityId, 'task-1');
    expect(updated.processedEntityType, QuickCaptureProcessedEntityType.task);
    expect(updated.isArchived, isTrue);
    expect(updated.updatedAt, processedAt);
  });
}
