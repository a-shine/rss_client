import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/models/feed_url.dart';

class FeedUrlLocalStorageService {
  static const String _feedUrlsKey = 'feed_urls';

  final SharedPreferences _prefs;

  FeedUrlLocalStorageService(this._prefs);

  /// Get all saved feed URLs
  Future<List<FeedUrl>> getFeedUrls() async {
    final String? jsonString = _prefs.getString(_feedUrlsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => FeedUrl.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Add a new feed URL
  Future<void> addFeedUrl(FeedUrl feedUrl) async {
    final urls = await getFeedUrls();
    urls.add(feedUrl);
    await _saveFeedUrls(urls);
  }

  /// Remove a feed URL by ID
  Future<void> removeFeedUrl(String id) async {
    final urls = await getFeedUrls();
    urls.removeWhere((url) => url.id == id);
    await _saveFeedUrls(urls);
  }

  /// Update an existing feed URL
  Future<void> updateFeedUrl(FeedUrl feedUrl) async {
    final urls = await getFeedUrls();
    final index = urls.indexWhere((url) => url.id == feedUrl.id);
    if (index != -1) {
      urls[index] = feedUrl;
      await _saveFeedUrls(urls);
    }
  }

  /// Check if a URL already exists
  Future<bool> urlExists(String url) async {
    final urls = await getFeedUrls();
    return urls.any((feedUrl) => feedUrl.url == url);
  }

  /// Save the list of feed URLs
  Future<void> _saveFeedUrls(List<FeedUrl> urls) async {
    final jsonList = urls.map((url) => url.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_feedUrlsKey, jsonString);
  }
}
