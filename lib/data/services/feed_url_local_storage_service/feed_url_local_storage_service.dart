import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';

class FeedUrlLocalStorageService {
  static const String _feedUrlsKey = 'feed_urls';

  final SharedPreferences _prefs;

  FeedUrlLocalStorageService(this._prefs);

  /// Get all saved feed URLs
  Future<Result<List<FeedUrl>>> getFeedUrls() async {
    try {
      final String? jsonString = _prefs.getString(_feedUrlsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return Result.ok([]);
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final feedUrls = jsonList
          .map((json) => FeedUrl.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.ok(feedUrls);
    } catch (e) {
      return Result.error(Exception('Failed to get feed URLs: $e'));
    }
  }

  /// Add a new feed URL
  Future<Result<void>> addFeedUrl(FeedUrl feedUrl) async {
    try {
      final urlsResult = await getFeedUrls();
      switch (urlsResult) {
        case Error():
          return Result.error(urlsResult.error);
        case Ok():
          final urls = urlsResult.value;
          urls.add(feedUrl);
          return await _saveFeedUrls(urls);
      }
    } catch (e) {
      return Result.error(Exception('Failed to add feed URL: $e'));
    }
  }

  /// Remove a feed URL by ID
  Future<Result<void>> removeFeedUrl(String id) async {
    try {
      final urlsResult = await getFeedUrls();
      switch (urlsResult) {
        case Error():
          return Result.error(urlsResult.error);
        case Ok():
          final urls = urlsResult.value;
          urls.removeWhere((url) => url.id == id);
          return await _saveFeedUrls(urls);
      }
    } catch (e) {
      return Result.error(Exception('Failed to remove feed URL: $e'));
    }
  }

  /// Update an existing feed URL
  Future<Result<void>> updateFeedUrl(FeedUrl feedUrl) async {
    try {
      final urlsResult = await getFeedUrls();
      switch (urlsResult) {
        case Error():
          return Result.error(urlsResult.error);
        case Ok():
          final urls = urlsResult.value;
          final index = urls.indexWhere((url) => url.id == feedUrl.id);
          if (index != -1) {
            urls[index] = feedUrl;
            return await _saveFeedUrls(urls);
          }
          return Result.ok(null);
      }
    } catch (e) {
      return Result.error(Exception('Failed to update feed URL: $e'));
    }
  }

  /// Check if a URL already exists
  Future<Result<bool>> urlExists(String url) async {
    try {
      final urlsResult = await getFeedUrls();
      switch (urlsResult) {
        case Error():
          return Result.error(urlsResult.error);
        case Ok():
          final urls = urlsResult.value;
          return Result.ok(urls.any((feedUrl) => feedUrl.url == url));
      }
    } catch (e) {
      return Result.error(Exception('Failed to check if URL exists: $e'));
    }
  }

  /// Save the list of feed URLs
  Future<Result<void>> _saveFeedUrls(List<FeedUrl> urls) async {
    try {
      final jsonList = urls.map((url) => url.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_feedUrlsKey, jsonString);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to save feed URLs: $e'));
    }
  }
}
