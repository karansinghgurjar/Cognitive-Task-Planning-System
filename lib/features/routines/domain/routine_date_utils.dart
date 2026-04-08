DateTime normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isSameDate(DateTime left, DateTime right) {
  final normalizedLeft = normalizeDate(left);
  final normalizedRight = normalizeDate(right);
  return normalizedLeft.year == normalizedRight.year &&
      normalizedLeft.month == normalizedRight.month &&
      normalizedLeft.day == normalizedRight.day;
}

int daysBetween(DateTime start, DateTime end) {
  return normalizeDate(end).difference(normalizeDate(start)).inDays;
}

int weeksBetween(DateTime start, DateTime end) {
  return daysBetween(start, end) ~/ 7;
}

int monthsBetween(DateTime start, DateTime end) {
  final normalizedStart = normalizeDate(start);
  final normalizedEnd = normalizeDate(end);
  return ((normalizedEnd.year - normalizedStart.year) * 12) +
      normalizedEnd.month -
      normalizedStart.month;
}

DateTime? tryCreateDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  final candidate = DateTime(year, month, day);
  if (candidate.year != year ||
      candidate.month != month ||
      candidate.day != day) {
    return null;
  }
  return candidate;
}

DateTime composeDateAndMinute(DateTime date, int minuteOfDay) {
  final normalized = normalizeDate(date);
  final hours = minuteOfDay ~/ 60;
  final minutes = minuteOfDay % 60;
  return DateTime(
    normalized.year,
    normalized.month,
    normalized.day,
    hours,
    minutes,
  );
}

String buildOccurrenceKey(String routineId, DateTime occurrenceDate) {
  final date = normalizeDate(occurrenceDate);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$routineId|${date.year}$month$day';
}
