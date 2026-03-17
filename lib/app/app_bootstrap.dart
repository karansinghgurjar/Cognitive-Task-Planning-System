import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_brand.dart';
import '../core/navigation/app_navigation.dart';
import '../core/theme/app_theme.dart';
import 'startup_gate.dart';

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key, this.startupIssue});

  final Object? startupIssue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: AppBrand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: StartupGate(startupIssue: startupIssue),
    );
  }
}
