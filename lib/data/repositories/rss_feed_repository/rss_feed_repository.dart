import '../../../domain/models/feed.dart';
import '../../../domain/models/feed_url.dart';

abstract class RssFeedRepository {
  Future<List<Feed>> fetchAllFeeds();
  Future<Feed> fetchFeedByUrl(FeedUrl feedUrl);
}
