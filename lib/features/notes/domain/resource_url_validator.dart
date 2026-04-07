class ResourceUrlValidator {
  const ResourceUrlValidator._();

  static String? validateOptionalUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a valid http or https URL.';
    }
    if (uri.host.trim().isEmpty) {
      return 'Enter a valid http or https URL.';
    }
    return null;
  }

  static Uri? parseLaunchableUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (validateOptionalUrl(trimmed) != null) {
      return null;
    }
    return Uri.parse(trimmed);
  }

  static String? hostLabel(String? value) {
    final uri = parseLaunchableUrl(value);
    if (uri == null) {
      return null;
    }
    return uri.host;
  }
}
