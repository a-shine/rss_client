import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';

import '../../../utils/result.dart';

class ParsedFeed {
  ParsedFeed({this.rssFeed, this.atomFeed})
    : assert(rssFeed != null || atomFeed != null);

  RssFeed? rssFeed;
  AtomFeed? atomFeed;
}

class RssFeedHttpService {
  RssFeedHttpService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetch any RSS or Atom feed from the given URL (auto-detects format)
  Future<Result<ParsedFeed>> fetchFeed(String feedUrl) async {
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

    // Auto-detect feed type and parse accordingly
    try {
      if (bodyString.contains('<rss') || bodyString.contains('<channel')) {
        // It's an RSS feed
        final rssFeed = RssFeed.parse(bodyString);
        return Result.ok(ParsedFeed(rssFeed: rssFeed));
      } else if (bodyString.contains('<feed') &&
          bodyString.contains('xmlns="http://www.w3.org/2005/Atom"')) {
        // It's an Atom feed
        final atomFeed = AtomFeed.parse(bodyString);
        return Result.ok(ParsedFeed(atomFeed: atomFeed));
      } else {
        return Result.error(Exception('Unknown or invalid feed format'));
      }
    } catch (e) {
      return Result.error(Exception('Failed to parse feed: $e'));
    }
  }
}
