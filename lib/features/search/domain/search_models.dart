import '../../notes/models/entity_note.dart';

enum SearchResultType { task, goal, note, capture, weeklyReview }

extension SearchResultTypeX on SearchResultType {
  String get label {
    switch (this) {
      case SearchResultType.task:
        return 'Tasks';
      case SearchResultType.goal:
        return 'Goals';
      case SearchResultType.note:
        return 'Notes';
      case SearchResultType.capture:
        return 'Quick Captures';
      case SearchResultType.weeklyReview:
        return 'Weekly Reviews';
    }
  }
}

class SearchQueryContext {
  const SearchQueryContext({required this.query});

  final String query;

  String get normalizedQuery => query.trim().toLowerCase();
}

class SearchSnippet {
  const SearchSnippet({
    required this.primaryText,
    required this.searchableText,
  });

  final String primaryText;
  final String searchableText;
}

class SearchableRecord {
  const SearchableRecord({
    required this.id,
    required this.resultType,
    required this.entityId,
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.searchableTerms,
    required this.updatedAt,
    this.isArchived = false,
    this.parentEntityType,
    this.parentEntityId,
    this.weekStart,
  });

  final String id;
  final SearchResultType resultType;
  final String entityId;
  final String title;
  final String subtitle;
  final String snippet;
  final List<String> searchableTerms;
  final DateTime? updatedAt;
  final bool isArchived;
  final EntityAttachmentType? parentEntityType;
  final String? parentEntityId;
  final DateTime? weekStart;
}

class GlobalSearchData {
  const GlobalSearchData({required this.records});

  final List<SearchableRecord> records;
}

class GlobalSearchResult {
  const GlobalSearchResult({
    required this.id,
    required this.resultType,
    required this.entityId,
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.score,
    this.isArchived = false,
    this.updatedAt,
    this.parentEntityType,
    this.parentEntityId,
    this.weekStart,
  });

  final String id;
  final SearchResultType resultType;
  final String entityId;
  final String title;
  final String subtitle;
  final String snippet;
  final int score;
  final bool isArchived;
  final DateTime? updatedAt;
  final EntityAttachmentType? parentEntityType;
  final String? parentEntityId;
  final DateTime? weekStart;
}

class SearchSection {
  const SearchSection({
    required this.type,
    required this.title,
    required this.results,
  });

  final SearchResultType type;
  final String title;
  final List<GlobalSearchResult> results;
}
