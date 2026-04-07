import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/backup_models.dart';

class FileExportService {
  const FileExportService();

  Future<ExportResult> saveJsonFile({
    required String content,
    required String suggestedName,
  }) {
    return _saveTextFile(
      content: content,
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON Files', extensions: ['json']),
      ],
    );
  }

  Future<ExportResult> saveCsvFile({
    required String content,
    required String suggestedName,
  }) {
    return _saveTextFile(
      content: content,
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV Files', extensions: ['csv']),
      ],
    );
  }

  Future<ExportResult> saveTextFile({
    required String content,
    required String suggestedName,
  }) {
    return _saveTextFile(
      content: content,
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Text Files', extensions: ['txt', 'json']),
      ],
    );
  }

  Future<LoadedFile?> pickJsonFile() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'JSON Files', extensions: ['json']),
        ],
      );
      if (file == null) {
        return null;
      }

      final content = await file.readAsString();
      return LoadedFile(path: file.path, content: content);
    } catch (error) {
      throw StateError(
        'Could not open the selected backup file. ${error.toString()}',
      );
    }
  }

  Future<ExportResult> _saveTextFile({
    required String content,
    required String suggestedName,
    required List<XTypeGroup> acceptedTypeGroups,
  }) async {
    try {
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: acceptedTypeGroups,
      );
      if (location == null) {
        return const ExportResult(
          success: false,
          filePath: null,
          bytesWritten: 0,
          message: 'Save cancelled.',
        );
      }

      final bytes = Uint8List.fromList(utf8.encode(content));
      final file = XFile.fromData(bytes, name: suggestedName);
      await file.saveTo(location.path);

      return ExportResult(
        success: true,
        filePath: location.path,
        bytesWritten: bytes.length,
        message: 'File saved successfully.',
      );
    } catch (error) {
      if (!kIsWeb && Platform.isAndroid) {
        return _saveToAndroidDocuments(
          content: content,
          suggestedName: suggestedName,
        );
      }
      throw StateError('Could not save the selected file. ${error.toString()}');
    }
  }

  Future<ExportResult> _saveToAndroidDocuments({
    required String content,
    required String suggestedName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}${Platform.pathSeparator}$suggestedName';
      final bytes = utf8.encode(content);
      await File(path).writeAsBytes(bytes, flush: true);
      return ExportResult(
        success: true,
        filePath: path,
        bytesWritten: bytes.length,
        message:
            'File saved to app documents because the system save picker was unavailable on this device.',
      );
    } catch (error) {
      throw StateError(
        'Could not save the file on this device. ${error.toString()}',
      );
    }
  }
}

class LoadedFile {
  const LoadedFile({required this.path, required this.content});

  final String path;
  final String content;
}
