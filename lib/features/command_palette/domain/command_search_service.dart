import 'command_models.dart';

class CommandSearchService {
  const CommandSearchService();

  List<CommandMatchResult> search(String query, List<AppCommand> commands) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      final sorted = List<AppCommand>.from(commands)
        ..sort((left, right) {
          final byPriority = right.priority.compareTo(left.priority);
          if (byPriority != 0) {
            return byPriority;
          }
          final byEnabled = (right.isEnabled ? 1 : 0) - (left.isEnabled ? 1 : 0);
          if (byEnabled != 0) {
            return byEnabled;
          }
          return left.title.compareTo(right.title);
        });
      return sorted
          .map((command) => CommandMatchResult(
                command: command,
                score: command.priority * 100,
              ))
          .toList();
    }

    final results = <CommandMatchResult>[];
    for (final command in commands) {
      final score = _scoreCommand(normalizedQuery, command);
      if (score <= 0) {
        continue;
      }
      results.add(CommandMatchResult(command: command, score: score));
    }

    results.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) {
        return byScore;
      }
      final byPriority = right.command.priority.compareTo(left.command.priority);
      if (byPriority != 0) {
        return byPriority;
      }
      if (left.command.isEnabled != right.command.isEnabled) {
        return left.command.isEnabled ? -1 : 1;
      }
      return left.command.title.compareTo(right.command.title);
    });
    return results;
  }

  int _scoreCommand(String query, AppCommand command) {
    final title = command.title.toLowerCase();
    final subtitle = command.subtitle?.toLowerCase();
    final keywords = command.keywords.map((keyword) => keyword.toLowerCase()).toList();

    var score = 0;
    if (title.startsWith(query)) {
      score += 1000;
    } else if (title.contains(query)) {
      score += 700;
    }

    if (subtitle != null) {
      if (subtitle.startsWith(query)) {
        score += 400;
      } else if (subtitle.contains(query)) {
        score += 250;
      }
    }

    for (final keyword in keywords) {
      if (keyword.startsWith(query)) {
        score += 350;
        break;
      }
      if (keyword.contains(query)) {
        score += 200;
      }
    }

    final queryTerms = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    if (queryTerms.isNotEmpty &&
        queryTerms.every((term) =>
            title.contains(term) ||
            (subtitle?.contains(term) ?? false) ||
            keywords.any((keyword) => keyword.contains(term)))) {
      score += 150;
    }

    if (!command.isEnabled) {
      score -= 50;
    }
    return score;
  }
}
