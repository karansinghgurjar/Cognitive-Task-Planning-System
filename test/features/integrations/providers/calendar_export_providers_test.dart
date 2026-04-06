import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/integrations/data/calendar_export_repository.dart';
import 'package:study_flow/features/integrations/data/calendar_file_export_service.dart';
import 'package:study_flow/features/integrations/models/calendar_export_options.dart';
import 'package:study_flow/features/integrations/providers/calendar_export_providers.dart';

void main() {
  test(
    'returns friendly result and skips save when no sessions match',
    () async {
      final fileService = _FakeCalendarFileExportService();
      final container = ProviderContainer(
        overrides: [
          calendarExportRepositoryProvider.overrideWith(
            (ref) async => CalendarExportRepository(
              loadSessionsInRange: (_, _) async => const [],
              loadTasks: () async => const [],
              loadGoals: () async => const [],
            ),
          ),
          calendarFileExportServiceProvider.overrideWith((ref) => fileService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(calendarExportActionControllerProvider.notifier)
          .exportCalendar(
            CalendarExportOptions.next7Days(now: DateTime(2026, 4, 7)),
          );

      expect(result.success, isFalse);
      expect(
        result.message,
        'No planned sessions matched the selected export filters.',
      );
      expect(fileService.saveCalls, 0);
    },
  );
}

class _FakeCalendarFileExportService extends CalendarFileExportService {
  int saveCalls = 0;

  @override
  Future<ExportResult> saveIcsFile({
    required String content,
    required String suggestedName,
  }) async {
    saveCalls++;
    return const ExportResult(
      success: true,
      filePath: 'ignored.ics',
      bytesWritten: 1,
      message: 'saved',
    );
  }
}
