import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_bootstrap.dart';
import 'core/background/background_worker.dart';
import 'core/notifications/notification_coordinator.dart';
import 'features/sync/data/auth_sync_service.dart';
import 'features/sync/presentation/sync_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupIssue;
  try {
    await initializeSyncBackend();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'study_flow',
        context: ErrorDescription('during startup sync initialization'),
      ),
    );
    startupIssue = error;
  }
  runApp(ProviderScope(child: StudyFlowApp(startupIssue: startupIssue)));
}

class StudyFlowApp extends ConsumerStatefulWidget {
  const StudyFlowApp({super.key, this.startupIssue});

  final Object? startupIssue;

  @override
  ConsumerState<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends ConsumerState<StudyFlowApp> {
  bool _backgroundInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBackgroundWorker();
    });
  }

  Future<void> _initializeBackgroundWorker() async {
    if (_backgroundInitialized) {
      return;
    }
    _backgroundInitialized = true;
    try {
      await BackgroundWorker().initialize();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during background worker initialization'),
        ),
      );
      _backgroundInitialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationCoordinator(
      child: SyncCoordinator(
        child: AppBootstrap(startupIssue: widget.startupIssue),
      ),
    );
  }
}
