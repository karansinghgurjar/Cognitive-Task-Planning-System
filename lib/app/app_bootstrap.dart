import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_brand.dart';
import '../core/navigation/app_navigation.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/models/notification_preferences.dart';
import '../features/settings/providers/settings_providers.dart';
import 'startup_gate.dart';

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key, this.startupIssue});

  final Object? startupIssue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(appThemePreferenceProvider);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: AppBrand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (themePreference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
      home: StartupGate(startupIssue: startupIssue),
    );
  }
}
