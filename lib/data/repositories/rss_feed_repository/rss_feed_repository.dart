import '../../../domain/models/feed.dart';
import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';

abstract class RssFeedRepository {
  Future<Result<List<Feed>>> fetchAllFeeds();
  Future<Result<Feed>> fetchFeedByUrl(FeedUrl feedUrl);
}
