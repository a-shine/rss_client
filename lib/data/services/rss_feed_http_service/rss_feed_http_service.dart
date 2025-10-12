import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';

import '../../../utils/result.dart';

class RssFeedHttpService {
  RssFeedHttpService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetch any RSS feed from the given URL
  Future<Result<RssFeed>> fetchRssFeed(String feedUrl) async {
    String bodyString;

    if (kIsWeb) {
      // Use corsproxy.io for web - more reliable CORS proxy
      final targetUrl = Uri.encodeComponent(feedUrl);
      final url = 'https://corsproxy.io/?$targetUrl';
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        bodyString = response.body;
      } else {
        return Result.error(
          Exception('Failed to load RSS feed: ${response.statusCode}'),
        );
      }
    } else {
      // Direct fetch for mobile/desktop
      final response = await _client.get(Uri.parse(feedUrl));

      if (response.statusCode == 200) {
        bodyString = response.body;
      } else {
        return Result.error(
          Exception('Failed to load RSS feed: ${response.statusCode}'),
        );
      }
    }

    final channel = RssFeed.parse(bodyString);
    return Result.ok(channel);
  }
}
