enum RoutineType { study, health, review, project, custom }

enum RoutineRepeatType {
  daily,
  weekdays,
  selectedWeekdays,
  weekly,
  monthly,
}

enum RoutineOccurrenceStatus {
  pending,
  completed,
  skipped,
  missed,
}

extension RoutineTypeX on RoutineType {
  String get label {
    switch (this) {
      case RoutineType.study:
        return 'Study';
      case RoutineType.health:
        return 'Health';
      case RoutineType.review:
        return 'Review';
      case RoutineType.project:
        return 'Project';
      case RoutineType.custom:
        return 'Custom';
    }
  }

  String get defaultCategoryTag {
    switch (this) {
      case RoutineType.study:
        return 'Study';
      case RoutineType.health:
        return 'Health';
      case RoutineType.review:
        return 'Review';
      case RoutineType.project:
        return 'Project';
      case RoutineType.custom:
        return 'Routine';
    }
  }
}

extension RoutineRepeatTypeX on RoutineRepeatType {
  String get label {
    switch (this) {
      case RoutineRepeatType.daily:
        return 'Daily';
      case RoutineRepeatType.weekdays:
        return 'Weekdays';
      case RoutineRepeatType.selectedWeekdays:
        return 'Specific Days';
      case RoutineRepeatType.weekly:
        return 'Weekly';
      case RoutineRepeatType.monthly:
        return 'Monthly';
    }
  }
}

extension RoutineOccurrenceStatusX on RoutineOccurrenceStatus {
  String get label {
    switch (this) {
      case RoutineOccurrenceStatus.pending:
        return 'Pending';
      case RoutineOccurrenceStatus.completed:
        return 'Completed';
      case RoutineOccurrenceStatus.skipped:
        return 'Skipped';
      case RoutineOccurrenceStatus.missed:
        return 'Missed';
    }
  }
}
