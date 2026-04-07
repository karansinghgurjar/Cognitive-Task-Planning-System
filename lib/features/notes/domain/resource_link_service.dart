import 'package:url_launcher/url_launcher.dart';

import 'resource_url_validator.dart';

class ResourceLinkService {
  const ResourceLinkService();

  Future<bool> openUrl(String? value) async {
    final uri = ResourceUrlValidator.parseLaunchableUrl(value);
    if (uri == null) {
      return false;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
