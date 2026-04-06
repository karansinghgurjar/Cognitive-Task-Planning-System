import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/quick_capture/data/quick_capture_repository.dart';
import 'package:study_flow/features/quick_capture/models/quick_capture_item.dart';
import 'package:study_flow/features/quick_capture/providers/quick_capture_providers.dart';

void main() {
  test(
    'unprocessed capture count provider reflects current inbox size',
    () async {
      final repository = _FakeQuickCaptureRepository(
        initialItems: [
          QuickCaptureItem(
            id: 'capture-1',
            rawText: 'Revise Java OOP',
            createdAt: DateTime(2026, 4, 6, 9),
          ),
          QuickCaptureItem(
            id: 'capture-2',
            rawText: 'Idea for a new dashboard',
            createdAt: DateTime(2026, 4, 6, 10),
            isProcessed: true,
            processedAt: DateTime(2026, 4, 6, 10, 5),
            processedEntityType: QuickCaptureProcessedEntityType.note,
          ),
          QuickCaptureItem(
            id: 'capture-3',
            rawText: 'Prepare DSA arrays',
            createdAt: DateTime(2026, 4, 6, 11),
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          quickCaptureRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(() async {
        await repository.dispose();
        container.dispose();
      });

      await container.read(watchUnprocessedCapturesProvider.future);
      final countAsync = container.read(unprocessedCaptureCountProvider);

      expect(countAsync.value, 2);
    },
  );

  test(
    'quick capture action controller classifies and persists captures',
    () async {
      final repository = _FakeQuickCaptureRepository();
      final container = ProviderContainer(
        overrides: [
          quickCaptureRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(() async {
        await repository.dispose();
        container.dispose();
      });

      await container
          .read(quickCaptureActionControllerProvider.notifier)
          .addCaptureFromText('Revise Java OOP');

      expect(repository.items, hasLength(1));
      expect(repository.items.single.rawText, 'Revise Java OOP');
      expect(
        repository.items.single.suggestedType,
        QuickCaptureSuggestedType.task,
      );
    },
  );

  test(
    'mark processed updates item state and removes it from unprocessed stream',
    () async {
      final repository = _FakeQuickCaptureRepository(
        initialItems: [
          QuickCaptureItem(
            id: 'capture-1',
            rawText: 'Learn REST APIs',
            createdAt: DateTime(2026, 4, 6, 9),
            suggestedType: QuickCaptureSuggestedType.goal,
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          quickCaptureRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(() async {
        await repository.dispose();
        container.dispose();
      });

      await container
          .read(quickCaptureActionControllerProvider.notifier)
          .markProcessed(
            'capture-1',
            linkedEntityId: 'goal-1',
            processedEntityType: QuickCaptureProcessedEntityType.goal,
          );

      final stored = repository.items.single;
      final unprocessed = await repository.getUnprocessedCaptures();

      expect(stored.isProcessed, isTrue);
      expect(stored.linkedEntityId, 'goal-1');
      expect(stored.processedEntityType, QuickCaptureProcessedEntityType.goal);
      expect(unprocessed, isEmpty);
    },
  );

  test(
    'processed and archived items do not appear in unprocessed inbox',
    () async {
      final repository = _FakeQuickCaptureRepository(
        initialItems: [
          QuickCaptureItem(
            id: 'active',
            rawText: 'Fix sync issue',
            createdAt: DateTime(2026, 4, 6, 11),
          ),
          QuickCaptureItem(
            id: 'processed',
            rawText: 'Learn Flutter',
            createdAt: DateTime(2026, 4, 6, 10),
            isProcessed: true,
            processedAt: DateTime(2026, 4, 6, 10, 10),
            processedEntityType: QuickCaptureProcessedEntityType.goal,
          ),
          QuickCaptureItem(
            id: 'archived',
            rawText: 'Old thought',
            createdAt: DateTime(2026, 4, 6, 9),
            isArchived: true,
          ),
        ],
      );

      final unprocessed = await repository.getUnprocessedCaptures();
      expect(unprocessed.map((item) => item.id).toList(), ['active']);
    },
  );

  test('unprocessed count updates after item is processed', () async {
    final repository = _FakeQuickCaptureRepository(
      initialItems: [
        QuickCaptureItem(
          id: 'capture-1',
          rawText: 'Revise Java OOP',
          createdAt: DateTime(2026, 4, 6, 9),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        quickCaptureRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(() async {
      await repository.dispose();
      container.dispose();
    });

    await container.read(watchUnprocessedCapturesProvider.future);
    expect(container.read(unprocessedCaptureCountProvider).value, 1);

    await container
        .read(quickCaptureActionControllerProvider.notifier)
        .markProcessed(
          'capture-1',
          processedEntityType: QuickCaptureProcessedEntityType.note,
        );

    await container.read(watchUnprocessedCapturesProvider.future);
    expect(container.read(unprocessedCaptureCountProvider).value, 0);
  });
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
  Future<void> updateCapture(QuickCaptureItem item) async {
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      return;
    }
    items[index] = item;
    _emit();
  }

  @override
  Future<void> deleteCapture(String id) async {
    items.removeWhere((item) => item.id == id);
    _emit();
  }

  @override
  Future<List<QuickCaptureItem>> getAllCaptures() async {
    final captures = List<QuickCaptureItem>.from(items);
    captures.sort(_compare);
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
