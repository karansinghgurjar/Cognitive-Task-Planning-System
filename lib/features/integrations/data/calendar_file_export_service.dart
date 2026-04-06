import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../backup/domain/backup_models.dart';

class CalendarFileExportService {
  const CalendarFileExportService();

  Future<ExportResult> saveIcsFile({
    required String content,
    required String suggestedName,
  }) async {
    final fileName = suggestedName.toLowerCase().endsWith('.ics')
        ? suggestedName
        : '$suggestedName.ics';

    try {
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Calendar Files', extensions: ['ics']),
        ],
      );
      if (location == null) {
        return const ExportResult(
          success: false,
          filePath: null,
          bytesWritten: 0,
          message: 'Calendar export cancelled.',
        );
      }

      return _saveToPath(path: location.path, content: content, name: fileName);
    } catch (error) {
      if (!kIsWeb && Platform.isAndroid) {
        return _saveToAndroidDocuments(fileName: fileName, content: content);
      }
      throw StateError('Could not save the calendar file. ${error.toString()}');
    }
  }

  Future<ExportResult> _saveToPath({
    required String path,
    required String content,
    required String name,
  }) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(content));
      final file = XFile.fromData(bytes, name: name, mimeType: 'text/calendar');
      await file.saveTo(path);
      return ExportResult(
        success: true,
        filePath: path,
        bytesWritten: bytes.length,
        message: 'Calendar file saved successfully.',
      );
    } catch (error) {
      throw StateError(
        'Could not save the selected calendar file. ${error.toString()}',
      );
    }
  }

  Future<ExportResult> _saveToAndroidDocuments({
    required String fileName,
    required String content,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}${Platform.pathSeparator}$fileName';
      final bytes = utf8.encode(content);
      await File(path).writeAsBytes(bytes, flush: true);
      return ExportResult(
        success: true,
        filePath: path,
        bytesWritten: bytes.length,
        message:
            'Calendar file saved to app documents because the system save picker was unavailable on this device.',
        warnings: const [
          'This export uses a local .ics file, not live calendar sync.',
        ],
      );
    } catch (error) {
      throw StateError(
        'Could not save the calendar file on this device. ${error.toString()}',
      );
    }
  }
}
