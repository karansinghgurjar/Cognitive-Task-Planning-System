import 'package:flutter/material.dart';

import 'app_error.dart';

class ErrorHandler {
  const ErrorHandler._();

  static AppError mapError(
    Object error, {
    String fallbackTitle = 'Something went wrong',
    String fallbackMessage =
        'Try again. If the issue persists, restart the app and verify your local data.',
  }) {
    final text = error.toString();
    if (text.contains('already in progress')) {
      return const AppError(
        title: 'Action already running',
        message:
            'Please wait for the current action to finish before trying again.',
      );
    }
    if (error is FormatException) {
      return AppError(
        title: 'Invalid file or data',
        message: 'The provided file is invalid or unsupported.',
        details: text,
      );
    }
    if (text.contains('SocketException') || text.contains('network')) {
      return const AppError(
        title: 'Network unavailable',
        message:
            'This action needs a network connection. Your local data is still safe.',
      );
    }
    if (text.contains('permission')) {
      return const AppError(
        title: 'Permission required',
        message:
            'The requested permission was denied. You can continue using the app, but that feature will stay limited until access is granted.',
      );
    }
    if (text.contains('Could not open the selected backup file') ||
        text.contains('Could not save the selected file') ||
        text.contains('file picker')) {
      return AppError(
        title: 'File operation failed',
        message:
            'The file could not be opened or saved. Check the selected location and try again.',
        details: text,
      );
    }
    if (text.contains('backup') || text.contains('restore')) {
      return AppError(
        title: 'Backup action failed',
        message:
            'The backup or restore operation could not be completed safely.',
        details: text,
      );
    }
    if (text.contains('sync')) {
      return AppError(
        title: 'Sync failed',
        message:
            'Your data is still stored locally. Sign in again or retry sync when connectivity is stable.',
        details: text,
      );
    }
    return AppError(
      title: fallbackTitle,
      message: fallbackMessage,
      details: text,
    );
  }

  static void showSnackBar(
    BuildContext context,
    Object error, {
    String fallbackTitle = 'Action failed',
    String fallbackMessage = 'Please try again.',
  }) {
    final appError = mapError(
      error,
      fallbackTitle: fallbackTitle,
      fallbackMessage: fallbackMessage,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(appError.message)));
  }
}
