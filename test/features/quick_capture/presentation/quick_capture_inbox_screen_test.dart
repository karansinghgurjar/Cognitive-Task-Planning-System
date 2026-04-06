import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/quick_capture/data/quick_capture_repository.dart';
import 'package:study_flow/features/quick_capture/models/quick_capture_item.dart';
import 'package:study_flow/features/quick_capture/presentation/quick_capture_inbox_screen.dart';
import 'package:study_flow/features/quick_capture/providers/quick_capture_providers.dart';

void main() {
  testWidgets('mark as note processes an inbox item and clears it from Inbox', (
    tester,
  ) async {
    final repository = _FakeQuickCaptureRepository(
      initialItems: [
        QuickCaptureItem(
          id: 'capture-1',
          rawText: 'Remember to revisit chapter summary',
          createdAt: DateTime(2026, 4, 7, 9),
          suggestedType: QuickCaptureSuggestedType.note,
        ),
      ],
    );

    await _pumpInboxScreen(tester, repository);

    expect(find.text('Remember to revisit chapter summary'), findsOneWidget);

    await tester.tap(find.text('Mark as Note'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox is clear'), findsOneWidget);
    expect(repository.items.single.isProcessed, isTrue);
    expect(
      repository.items.single.processedEntityType,
      QuickCaptureProcessedEntityType.note,
    );
  });

  testWidgets('edit text updates the capture content from the overflow menu', (
    tester,
  ) async {
    final repository = _FakeQuickCaptureRepository(
      initialItems: [
        QuickCaptureItem(
          id: 'capture-1',
          rawText: 'Read OS notes',
          createdAt: DateTime(2026, 4, 7, 10),
          suggestedType: QuickCaptureSuggestedType.task,
        ),
      ],
    );

    await _pumpInboxScreen(tester, repository);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit text'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Read DBMS notes');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Read DBMS notes'), findsOneWidget);
    expect(repository.items.single.rawText, 'Read DBMS notes');
  });

  testWidgets('delete removes the capture after confirmation', (tester) async {
    final repository = _FakeQuickCaptureRepository(
      initialItems: [
        QuickCaptureItem(
          id: 'capture-1',
          rawText: 'Delete this capture',
          createdAt: DateTime(2026, 4, 7, 11),
        ),
      ],
    );

    await _pumpInboxScreen(tester, repository);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(find.text('Inbox is clear'), findsOneWidget);
  });

  testWidgets('bulk action marks note captures as processed only', (
    tester,
  ) async {
    final repository = _FakeQuickCaptureRepository(
      initialItems: [
        QuickCaptureItem(
          id: 'note-1',
          rawText: 'Idea for weekly reflection template',
          createdAt: DateTime(2026, 4, 7, 12),
          suggestedType: QuickCaptureSuggestedType.note,
        ),
        QuickCaptureItem(
          id: 'task-1',
          rawText: 'Finish algorithm sheet',
          createdAt: DateTime(2026, 4, 7, 11),
          suggestedType: QuickCaptureSuggestedType.task,
        ),
      ],
    );

    await _pumpInboxScreen(tester, repository);

    await tester.tap(find.byIcon(Icons.done_all_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark all notes as processed (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Idea for weekly reflection template'), findsNothing);
    expect(find.text('Finish algorithm sheet'), findsOneWidget);

    final note = repository.items.firstWhere((item) => item.id == 'note-1');
    final task = repository.items.firstWhere((item) => item.id == 'task-1');
    expect(note.isProcessed, isTrue);
    expect(task.isProcessed, isFalse);
  });
}

Future<void> _pumpInboxScreen(
  WidgetTester tester,
  _FakeQuickCaptureRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quickCaptureRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: const MaterialApp(home: QuickCaptureInboxScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeQuickCaptureRepository implements QuickCaptureRepository {
  _FakeQuickCaptureRepository({List<QuickCaptureItem>? initialItems})
    : items = List<QuickCaptureItem>.from(initialItems ?? const []);

  final List<QuickCaptureItem> items;
  final _controller = StreamController<List<QuickCaptureItem>>.broadcast();

  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> addCapture(QuickCaptureItem item) async {
    items.add(item);
    _emit();
  }

  @override
  Future<void> deleteCapture(String id) async {
    items.removeWhere((item) => item.id == id);
    _emit();
  }

  @override
  Future<List<QuickCaptureItem>> getAllCaptures() async {
    final captures = List<QuickCaptureItem>.from(items)..sort(_compare);
    return captures;
  }

  @override
  Future<List<QuickCaptureItem>> getUnprocessedCaptures() async {
    final captures =
        items.where((item) => !item.isProcessed && !item.isArchived).toList()
          ..sort(_compare);
    return captures;
  }

  @override
  Future<void> markProcessed(
    String id, {
    String? linkedEntityId,
    QuickCaptureProcessedEntityType? processedEntityType,
  }) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final now = DateTime.now();
    items[index] = items[index].copyWith(
      isProcessed: true,
      processedAt: now,
      linkedEntityId: linkedEntityId,
      processedEntityType: processedEntityType,
      updatedAt: now,
    );
    _emit();
  }

  @override
  Future<void> updateCapture(QuickCaptureItem item) async {
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      return;
    }

    items[index] = item;
    _emit();
  }

  @override
  Stream<List<QuickCaptureItem>> watchAllCaptures() async* {
    yield await getAllCaptures();
    yield* _controller.stream;
  }

  @override
  Stream<List<QuickCaptureItem>> watchUnprocessedCaptures() async* {
    yield await getUnprocessedCaptures();
    yield* _controller.stream.asyncMap((_) => getUnprocessedCaptures());
  }

  int _compare(QuickCaptureItem left, QuickCaptureItem right) {
    return (right.updatedAt ?? right.createdAt).compareTo(
      left.updatedAt ?? left.createdAt,
    );
  }

  void _emit() {
    _controller.add(List<QuickCaptureItem>.from(items)..sort(_compare));
  }
}
