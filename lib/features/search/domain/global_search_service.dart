import 'search_models.dart';

class GlobalSearchService {
  const GlobalSearchService();

  List<GlobalSearchResult> search(GlobalSearchData data, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final results = <GlobalSearchResult>[];
    for (final record in data.records) {
      final score = _scoreRecord(record, normalizedQuery);
      if (score <= 0) {
        continue;
      }
      results.add(
        GlobalSearchResult(
          id: record.id,
          resultType: record.resultType,
          entityId: record.entityId,
          title: record.title,
          subtitle: record.subtitle,
          snippet: record.snippet,
          score: score,
          isArchived: record.isArchived,
          updatedAt: record.updatedAt,
          parentEntityType: record.parentEntityType,
          parentEntityId: record.parentEntityId,
          weekStart: record.weekStart,
        ),
      );
    }

    results.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) {
        return byScore;
      }
      if (left.isArchived != right.isArchived) {
        return left.isArchived ? 1 : -1;
      }
      final leftUpdated = left.updatedAt;
      final rightUpdated = right.updatedAt;
      if (leftUpdated != null && rightUpdated != null) {
        final byUpdated = rightUpdated.compareTo(leftUpdated);
        if (byUpdated != 0) {
          return byUpdated;
        }
      }
      return left.title.compareTo(right.title);
    });
    return results;
  }

  List<SearchSection> groupResults(List<GlobalSearchResult> results) {
    final grouped = <SearchResultType, List<GlobalSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.resultType, () => []).add(result);
    }
    final orderedTypes = SearchResultType.values;
    return orderedTypes
        .where((type) => grouped[type]?.isNotEmpty ?? false)
        .map(
          (type) => SearchSection(
            type: type,
            title: type.label,
            results: grouped[type]!,
          ),
        )
        .toList();
  }

  int _scoreRecord(SearchableRecord record, String query) {
    final title = record.title.toLowerCase();
    final subtitle = record.subtitle.toLowerCase();
    final snippet = record.snippet.toLowerCase();
    final terms = record.searchableTerms.map((term) => term.toLowerCase()).toList();

    var score = 0;
    if (title == query) {
      score += 2000;
    } else if (title.startsWith(query)) {
      score += 1400;
    } else if (title.contains(query)) {
      score += 900;
    }

    if (subtitle == query) {
      score += 900;
    } else if (subtitle.startsWith(query)) {
      score += 500;
    } else if (subtitle.contains(query)) {
      score += 250;
    }

    if (snippet.startsWith(query)) {
      score += 450;
    } else if (snippet.contains(query)) {
      score += 180;
    }

    for (final term in terms) {
      if (term == query) {
        score += 700;
        continue;
      }
      if (term.startsWith(query)) {
        score += 380;
      } else if (term.contains(query)) {
        score += 150;
      }
    }

    final termsInQuery = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    if (termsInQuery.isNotEmpty &&
        termsInQuery.every((term) {
          return title.contains(term) ||
              subtitle.contains(term) ||
              snippet.contains(term) ||
              terms.any((candidate) => candidate.contains(term));
        })) {
      score += 120;
    }

    if (record.isArchived) {
      score -= 40;
    }
    return score;
  }
}
