import 'package:flutter/material.dart';

import '../features/settings/presentation/settings_home_screen.dart';

class AppRouter {
  const AppRouter._();

  static Future<void> openSettings(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsHomeScreen()),
    );
  }
}
