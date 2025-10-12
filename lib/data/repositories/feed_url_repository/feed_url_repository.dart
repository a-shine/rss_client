import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';

abstract class FeedUrlRepository {
  Future<Result<List<FeedUrl>>> getFeedUrls();
  Future<Result<void>> addFeedUrl(FeedUrl feedUrl);
  Future<Result<void>> removeFeedUrl(String id);
  Future<Result<void>> updateFeedUrl(FeedUrl feedUrl);
  Future<Result<bool>> urlExists(String url);
}
