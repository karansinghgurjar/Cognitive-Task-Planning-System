import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_providers.dart';
import '../data/quick_capture_repository.dart';
import '../domain/quick_capture_parser_service.dart';
import '../models/quick_capture_item.dart';

final quickCaptureParserServiceProvider = Provider<QuickCaptureParserService>((ref) {
  return const QuickCaptureParserService();
});

final quickCaptureRepositoryProvider = FutureProvider<QuickCaptureRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return QuickCaptureRepository(isar);
});

final watchAllCapturesProvider = StreamProvider<List<QuickCaptureItem>>((ref) async* {
  final repository = await ref.watch(quickCaptureRepositoryProvider.future);
  yield* repository.watchAllCaptures();
});

final watchUnprocessedCapturesProvider = StreamProvider<List<QuickCaptureItem>>((ref) async* {
  final repository = await ref.watch(quickCaptureRepositoryProvider.future);
  yield* repository.watchUnprocessedCaptures();
});

final unprocessedCaptureCountProvider = Provider<AsyncValue<int>>((ref) {
  final capturesAsync = ref.watch(watchUnprocessedCapturesProvider);
  return capturesAsync.whenData((captures) => captures.length);
});

final quickCaptureActionControllerProvider =
    AsyncNotifierProvider<QuickCaptureActionController, void>(
      QuickCaptureActionController.new,
    );

class QuickCaptureActionController extends AsyncNotifier<void> {
  static const _uuid = Uuid();

  @override
  void build() {}

  Future<void> addCapture(QuickCaptureItem item) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(quickCaptureRepositoryProvider.future);
      await repository.addCapture(item);
    });
  }

  Future<void> addCaptureFromText(String rawText) async {
    _ensureIdle();
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      throw StateError('Capture text cannot be empty.');
    }

    await _run(() async {
      final repository = await ref.read(quickCaptureRepositoryProvider.future);
      final parser = ref.read(quickCaptureParserServiceProvider);
      final now = DateTime.now();
      await repository.addCapture(
        QuickCaptureItem(
          id: _uuid.v4(),
          rawText: trimmed,
          createdAt: now,
          updatedAt: now,
          suggestedType: parser.classify(trimmed),
        ),
      );
    });
  }

  Future<void> updateCapture(QuickCaptureItem item) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(quickCaptureRepositoryProvider.future);
      final parser = ref.read(quickCaptureParserServiceProvider);
      await repository.updateCapture(
        item.copyWith(
          suggestedType: parser.classify(item.rawText),
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> deleteCapture(String id) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(quickCaptureRepositoryProvider.future);
      await repository.deleteCapture(id);
    });
  }

  Future<void> markProcessed(
    String id, {
    String? linkedEntityId,
    QuickCaptureProcessedEntityType? processedEntityType,
  }) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(quickCaptureRepositoryProvider.future);
      await repository.markProcessed(
        id,
        linkedEntityId: linkedEntityId,
        processedEntityType: processedEntityType,
      );
    });
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another quick capture action is already in progress.');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
