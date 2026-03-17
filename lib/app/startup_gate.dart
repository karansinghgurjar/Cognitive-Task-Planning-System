import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/error_handler.dart';
import '../core/widgets/app_error_state.dart';
import '../core/widgets/app_loading_indicator.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/providers/onboarding_providers.dart';
import '../features/sync/data/auth_sync_service.dart';
import 'home_shell.dart';

enum StartupDestination { onboarding, home }

class StartupDecisionService {
  const StartupDecisionService();

  StartupDestination resolve({
    required bool onboardingCompleted,
  }) {
    return onboardingCompleted
        ? StartupDestination.home
        : StartupDestination.onboarding;
  }
}

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key, this.startupIssue});

  final Object? startupIssue;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  Object? _startupIssue;
  bool _continuingOffline = false;

  @override
  void initState() {
    super.initState();
    _startupIssue = widget.startupIssue;
  }

  @override
  Widget build(BuildContext context) {
    if (_startupIssue != null && !_continuingOffline) {
      final mapped = ErrorHandler.mapError(
        _startupIssue!,
        fallbackTitle: 'Startup initialization failed',
        fallbackMessage:
            'Optional startup services could not be initialized. You can retry or continue offline.',
      );
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppErrorState(
                    title: mapped.title,
                    message: mapped.message,
                    onRetry: _retryStartupInitialization,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _continuingOffline = true;
                      });
                    },
                    icon: const Icon(Icons.cloud_off_rounded),
                    label: const Text('Continue Offline'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final onboardingAsync = ref.watch(onboardingStateProvider);
    const decisionService = StartupDecisionService();

    return onboardingAsync.when(
      data: (state) {
        final destination = decisionService.resolve(
          onboardingCompleted: state.isCompleted,
        );
        switch (destination) {
          case StartupDestination.onboarding:
            return const OnboardingScreen();
          case StartupDestination.home:
            return const HomeShell();
        }
      },
      loading: () => const Scaffold(
        body: AppLoadingIndicator(label: 'Preparing your workspace...'),
      ),
      error: (error, _) => Scaffold(
        body: AppErrorState(
          title: 'Could not start the app',
          message:
              'The local onboarding state could not be loaded safely. Try again.',
          onRetry: () => ref.invalidate(onboardingStateProvider),
        ),
      ),
    );
  }

  Future<void> _retryStartupInitialization() async {
    try {
      await initializeSyncBackend();
      if (mounted) {
        setState(() {
          _startupIssue = null;
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during startup retry'),
        ),
      );
      if (mounted) {
        setState(() {
          _startupIssue = error;
        });
      }
    }
  }
}
