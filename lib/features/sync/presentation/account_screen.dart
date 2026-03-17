import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../providers/sync_providers.dart';
import 'sign_in_screen.dart';
import 'sync_status_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(syncAccountProvider);
    final actionState = ref.watch(syncActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Account')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final breakpoint = ResponsiveLayout.breakpointForWidth(
            constraints.maxWidth,
          );
          final padding = ResponsiveLayout.pagePadding(breakpoint);
          return ResponsiveContent(
            child: accountAsync.when(
              data: (account) {
                return ListView(
                  padding: padding,
                  children: [
                    AppSectionHeader(
                      title: 'Sync Account',
                      description:
                          'Manage your personal cross-device account and sign-in state.',
                    ),
                    if (actionState.isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                    ] else
                      const SizedBox(height: 16),
                    if (!account.isConfigured)
                      const AppEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Sync backend not configured',
                        message:
                            'Set Supabase configuration before using personal cross-device sync.',
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.isSignedIn
                                    ? account.email ?? 'Signed in'
                                    : 'No sync account is signed in on this device.',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                account.isSignedIn
                                    ? 'This device can push and pull personal data changes across your other signed-in devices.'
                                    : 'Sign in to enable your personal sync queue, bootstrap decisions, and cross-device updates.',
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  if (account.isSignedIn)
                                    FilledButton.icon(
                                      onPressed: actionState.isLoading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const SyncStatusScreen(),
                                                ),
                                              );
                                            },
                                      icon: const Icon(Icons.sync_rounded),
                                      label: const Text('Open Sync Status'),
                                    )
                                  else
                                    FilledButton.icon(
                                      onPressed: actionState.isLoading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const SignInScreen(),
                                                ),
                                              );
                                            },
                                      icon: const Icon(Icons.login_rounded),
                                      label: const Text('Sign In'),
                                    ),
                                  if (account.isSignedIn)
                                    OutlinedButton.icon(
                                      onPressed: actionState.isLoading
                                          ? null
                                          : () => _confirmSignOut(context, ref),
                                      icon: const Icon(Icons.logout_rounded),
                                      label: const Text('Sign Out'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading sync account...'),
              error: (error, _) => ErrorBoundaryWidget(error: error),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final summary = ref.read(syncStatusSummaryProvider).valueOrNull;
    final shouldSignOut = await AppConfirmationDialog.show(
      context,
      title: 'Sign out of sync?',
      message: summary != null && summary.pendingCount > 0
          ? 'There are pending local changes. Sign out only if you are comfortable leaving them unsynced on this device.'
          : 'This device will stop syncing until you sign in again.',
      confirmLabel: 'Sign Out',
    );
    if (!shouldSignOut || !context.mounted) {
      return;
    }

    try {
      await ref.read(syncActionControllerProvider.notifier).signOut();
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Sign out failed',
          fallbackMessage: 'The device could not sign out cleanly.',
        );
      }
    }
  }
}
