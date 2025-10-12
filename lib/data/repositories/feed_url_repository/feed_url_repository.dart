import '../../../domain/models/feed_url.dart';

abstract class FeedUrlRepository {
  Future<List<FeedUrl>> getFeedUrls();
  Future<void> addFeedUrl(FeedUrl feedUrl);
  Future<void> removeFeedUrl(String id);
  Future<void> updateFeedUrl(FeedUrl feedUrl);
  Future<bool> urlExists(String url);
}
