import '../../goals/models/learning_goal.dart';
import 'ai_planning_models.dart';

class GoalPromptParserService {
  const GoalPromptParserService();

  static const _stopWords = {
    'a',
    'an',
    'and',
    'app',
    'before',
    'build',
    'complete',
    'development',
    'exam',
    'finish',
    'for',
    'from',
    'in',
    'learn',
    'my',
    'of',
    'on',
    'paper',
    'prepare',
    'project',
    'study',
    'submission',
    'the',
    'to',
    'unit',
    'with',
  };

  ParsedGoalPrompt parse(String input, {DateTime? now}) {
    final trimmed = input.trim();
    final normalized = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final topicTokens = _extractTopicTokens(normalized);
    final inferredGoalType = inferGoalType(
      normalized,
      topicTokens: topicTokens,
    );
    final timeframeDaysHint = _extractTimeframeDays(normalized);

    return ParsedGoalPrompt(
      originalPrompt: trimmed,
      normalizedPrompt: normalized,
      titleCandidate: _buildTitleCandidate(
        trimmed,
        topicTokens,
        inferredGoalType,
      ),
      inferredGoalType: inferredGoalType,
      keywords: topicTokens,
      topicTokens: topicTokens,
      isRevision: _containsAny(normalized, const [
        'revise',
        'revision',
        'review',
      ]),
      isFromScratch: _containsAny(normalized, const [
        'from scratch',
        'beginner',
        'start from zero',
      ]),
      isAdvanced: _containsAny(normalized, const [
        'advanced',
        'deep',
        'expert',
      ]),
      isExam: _containsAny(normalized, const [
        'exam',
        'test',
        'unit',
        'semester',
      ]),
      isInterview: _containsAny(normalized, const [
        'interview',
        'placement',
        'product-based',
      ]),
      isProject: _containsAny(normalized, const [
        'project',
        'build',
        'paper',
        'submission',
        'prototype',
      ]),
      isUrgent: _containsAny(normalized, const [
        'urgent',
        'soon',
        'asap',
        'immediately',
      ]),
      deadlineHint: _extractDeadlineHint(normalized, now: now),
      timeframeDaysHint: timeframeDaysHint,
      summary: _buildSummary(normalized, timeframeDaysHint),
    );
  }

  GoalType inferGoalType(
    String normalizedPrompt, {
    List<String> topicTokens = const [],
  }) {
    if (_containsAny(normalizedPrompt, const [
      'project',
      'build',
      'paper',
      'prototype',
      'submission',
    ])) {
      return GoalType.project;
    }
    if (_containsAny(normalizedPrompt, const [
      'exam',
      'interview',
      'placement',
      'semester',
      'unit',
    ])) {
      return GoalType.examPrep;
    }
    if (_containsAny(normalizedPrompt, const [
      'work',
      'office',
      'client',
      'deliverable',
    ])) {
      return GoalType.work;
    }
    if (topicTokens.any(
      (token) => const {
        'flutter',
        'java',
        'dsa',
        'cv',
        'ml',
        'coding',
      }.contains(token),
    )) {
      return GoalType.learning;
    }
    return GoalType.learning;
  }

  List<String> _extractTopicTokens(String normalizedPrompt) {
    final matches = RegExp(r'[a-z0-9\+\-]+').allMatches(normalizedPrompt);
    final tokens = <String>[];
    for (final match in matches) {
      final token = match.group(0)!;
      if (_stopWords.contains(token) || token.length < 2) {
        continue;
      }
      if (!tokens.contains(token)) {
        tokens.add(token);
      }
    }
    return tokens;
  }

  String _buildTitleCandidate(
    String originalPrompt,
    List<String> topicTokens,
    GoalType goalType,
  ) {
    if (topicTokens.isEmpty) {
      return _toTitleCase(originalPrompt);
    }

    if (topicTokens.contains('flutter')) {
      return 'Learn Flutter';
    }
    if (topicTokens.contains('java') && topicTokens.contains('dsa')) {
      return 'Java and DSA Preparation';
    }
    if (topicTokens.contains('dsa')) {
      return 'DSA Preparation';
    }
    if (topicTokens.contains('cv')) {
      return 'Computer Vision Study Plan';
    }
    if (goalType == GoalType.project) {
      return _toTitleCase(
        originalPrompt.replaceAll(
          RegExp(r'^(finish|build)\s+', caseSensitive: false),
          '',
        ),
      );
    }

    return _toTitleCase(topicTokens.take(4).join(' '));
  }

  int? _extractTimeframeDays(String normalizedPrompt) {
    final match = RegExp(
      r'(\d+)\s*(day|days|week|weeks|month|months)',
    ).firstMatch(normalizedPrompt);
    if (match == null) {
      return null;
    }
    final value = int.tryParse(match.group(1)!);
    final unit = match.group(2)!;
    if (value == null) {
      return null;
    }
    if (unit.startsWith('day')) {
      return value;
    }
    if (unit.startsWith('week')) {
      return value * 7;
    }
    return value * 30;
  }

  DateTime? _extractDeadlineHint(String normalizedPrompt, {DateTime? now}) {
    final base = now ?? DateTime.now();
    final timeframeDays = _extractTimeframeDays(normalizedPrompt);
    if (timeframeDays != null) {
      return DateTime(
        base.year,
        base.month,
        base.day,
      ).add(Duration(days: timeframeDays));
    }
    if (normalizedPrompt.contains('tomorrow')) {
      return DateTime(base.year, base.month, base.day + 1);
    }
    return null;
  }

  String _buildSummary(String normalizedPrompt, int? timeframeDaysHint) {
    final scope = timeframeDaysHint == null
        ? 'no explicit timeframe'
        : '$timeframeDaysHint-day horizon';
    return 'Parsed as "$normalizedPrompt" with $scope.';
  }

  bool _containsAny(String input, List<String> needles) {
    for (final needle in needles) {
      if (input.contains(needle)) {
        return true;
      }
    }
    return false;
  }

  String _toTitleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
