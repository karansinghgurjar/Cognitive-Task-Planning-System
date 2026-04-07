import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/command_palette/domain/command_models.dart';
import 'package:study_flow/features/command_palette/domain/command_search_service.dart';

void main() {
  group('CommandSearchService', () {
    const service = CommandSearchService();
    const commands = [
      AppCommand(
        id: 'quick_capture',
        title: 'Quick Capture',
        subtitle: 'Capture an item quickly',
        keywords: ['capture', 'brain dump'],
        category: CommandCategory.taskActions,
        icon: Icons.bolt_rounded,
        priority: 100,
      ),
      AppCommand(
        id: 'open_capture_inbox',
        title: 'Open Capture Inbox',
        subtitle: 'Review captured items',
        keywords: ['inbox', 'capture inbox'],
        category: CommandCategory.taskActions,
        icon: Icons.inbox_rounded,
        priority: 80,
      ),
      AppCommand(
        id: 'open_weekly_review',
        title: 'Open Weekly Review',
        subtitle: 'Review the week',
        keywords: ['review', 'reflection'],
        category: CommandCategory.review,
        icon: Icons.rate_review_outlined,
        priority: 70,
      ),
    ];

    test('matches case-insensitively', () {
      final results = service.search('QUICK', commands);
      expect(results.first.command.id, 'quick_capture');
    });

    test('prefers title prefix matches over keyword matches', () {
      final results = service.search('capture', commands);
      expect(results.first.command.id, 'quick_capture');
      expect(results[1].command.id, 'open_capture_inbox');
    });

    test('returns stable priority ordering when query is empty', () {
      final results = service.search('', commands);
      expect(
        results.map((item) => item.command.id).toList(),
        ['quick_capture', 'open_capture_inbox', 'open_weekly_review'],
      );
    });

    test('returns empty list when nothing matches', () {
      final results = service.search('nonexistent', commands);
      expect(results, isEmpty);
    });
  });
}
