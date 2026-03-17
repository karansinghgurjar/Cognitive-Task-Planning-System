import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_brand.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data == null
              ? 'Unavailable'
              : '${snapshot.data!.version} (${snapshot.data!.buildNumber})';
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                AppBrand.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A personal planning workspace for tasks, goals, schedules, focus sessions, analytics, and cross-device continuity.',
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Version'),
                subtitle: Text(version),
              ),
              const Divider(height: 32),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Storage and sync'),
                subtitle: Text(
                  'Local Isar storage remains the source of truth on each device. Sync and backup are safety layers, not replacements for keeping a recent export.',
                ),
              ),
              const Divider(height: 32),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Release caution'),
                subtitle: Text(
                  'Before updating or reinstalling, create a backup. If you use sync, confirm that pending local changes have been uploaded before signing out or changing devices.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
