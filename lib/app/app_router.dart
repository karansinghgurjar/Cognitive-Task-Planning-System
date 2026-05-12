import 'package:flutter/material.dart';

import '../features/analytics/presentation/analytics_dashboard_screen.dart';
import '../features/backup/presentation/backup_restore_screen.dart';
import '../features/demo_data/presentation/demo_data_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/knowledge/presentation/screens/knowledge_dashboard_screen.dart';
import '../features/maintenance/presentation/data_maintenance_screen.dart';
import '../features/planner/presentation/planner_hub_screen.dart';
import '../features/planning_assistant/presentation/screens/planning_assistant_screen.dart';
import '../features/review/presentation/weekly_review_screen.dart';
import '../features/routines/presentation/routines_screen.dart';
import '../features/settings/presentation/settings_home_screen.dart';
import '../features/sync/presentation/sync_status_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/timetable/presentation/timetable_screen.dart';

class AppRouter {
  const AppRouter._();

  static Future<void> openSettings(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsHomeScreen()));
  }

  static Future<void> openSyncStatus(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SyncStatusScreen()),
    );
  }

  static Future<void> openKnowledgeDashboard(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const KnowledgeDashboardScreen()),
    );
  }

  static Future<void> openPlanningAssistant(
    BuildContext context, {
    String? initialPrompt,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanningAssistantScreen(initialPrompt: initialPrompt),
      ),
    );
  }

  static Future<void> openPlannerHub(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PlannerHubScreen()));
  }

  static Future<void> openTasks(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TasksScreen()),
    );
  }

  static Future<void> openGoals(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GoalsScreen()),
    );
  }

  static Future<void> openRoutines(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RoutinesScreen()),
    );
  }

  static Future<void> openWeeklyReview(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WeeklyReviewScreen()),
    );
  }

  static Future<void> openTimetable(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TimetableScreen()),
    );
  }

  static Future<void> openAnalytics(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AnalyticsDashboardScreen()),
    );
  }

  static Future<void> openBackupRestore(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BackupRestoreScreen()),
    );
  }

  static Future<void> openDemoData(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DemoDataScreen()),
    );
  }

  static Future<void> openMaintenance(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DataMaintenanceScreen()),
    );
  }
}
