import 'package:flutter/material.dart';

import '../widgets/app_error_state.dart';
import 'error_handler.dart';

class ErrorBoundaryWidget extends StatelessWidget {
  const ErrorBoundaryWidget({
    required this.error,
    super.key,
    this.onRetry,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final mapped = ErrorHandler.mapError(error);
    return AppErrorState(
      title: mapped.title,
      message: mapped.message,
      onRetry: onRetry,
    );
  }
}
