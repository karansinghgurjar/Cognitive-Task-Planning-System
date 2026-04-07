import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/notes/domain/resource_url_validator.dart';

void main() {
  group('ResourceUrlValidator', () {
    test('accepts empty url as optional input', () {
      expect(ResourceUrlValidator.validateOptionalUrl('   '), isNull);
      expect(ResourceUrlValidator.parseLaunchableUrl('   '), isNull);
    });

    test('rejects malformed or unsupported urls', () {
      expect(
        ResourceUrlValidator.validateOptionalUrl('example.com/resource'),
        isNotNull,
      );
      expect(
        ResourceUrlValidator.validateOptionalUrl('ftp://example.com/file'),
        isNotNull,
      );
      expect(ResourceUrlValidator.parseLaunchableUrl('notaurl'), isNull);
    });

    test('parses http and https urls safely', () {
      final uri = ResourceUrlValidator.parseLaunchableUrl(
        'https://github.com/example/repo',
      );

      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(ResourceUrlValidator.hostLabel(uri.toString()), 'github.com');
    });
  });
}
