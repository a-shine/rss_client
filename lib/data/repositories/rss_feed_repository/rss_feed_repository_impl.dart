import '../../../domain/models/feed.dart';
import '../../../domain/models/feed_item.dart';
import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';
import '../../services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import '../../services/rss_feed_http_service/rss_feed_http_service.dart';
import 'rss_feed_repository.dart';

class RssFeedRepositoryImpl implements RssFeedRepository {
  final RssFeedHttpService _service;
  final FeedUrlLocalStorageService _feedUrlService;

  RssFeedRepositoryImpl(this._service, this._feedUrlService);

  @override
  Future<Result<List<Feed>>> fetchAllFeeds() async {
    try {
      final feedUrlsResult = await _feedUrlService.getFeedUrls();

      switch (feedUrlsResult) {
        case Error():
          return Result.error(feedUrlsResult.error);
        case Ok():
          final feedUrls = feedUrlsResult.value;

          if (feedUrls.isEmpty) {
            return Result.ok([]);
          }

          final List<Feed> feeds = [];

          for (final feedUrl in feedUrls) {
            final feedResult = await fetchFeedByUrl(feedUrl);
            switch (feedResult) {
              case Ok():
                feeds.add(feedResult.value);
              case Error():
                // Continue with other feeds if one fails
                // You might want to log this error
                print(
                  'Error fetching feed ${feedUrl.name}: ${feedResult.error}',
                );
            }
          }

          return Result.ok(feeds);
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch all feeds: $e'));
    }
  }

  @override
  Future<Result<Feed>> fetchFeedByUrl(FeedUrl feedUrl) async {
    try {
      final rssFeedResult = await _service.fetchRssFeed(feedUrl.url);

      switch (rssFeedResult) {
        case Error():
          return Result.error(rssFeedResult.error);
        case Ok():
          final rssFeed = rssFeedResult.value;

          // Map service model (RssFeed) to domain model (Feed)
          final items = rssFeed.items.map((item) {
            DateTime? pubDate;
            if (item.pubDate != null) {
              try {
                pubDate = DateTime.parse(item.pubDate!);
              } catch (e) {
                pubDate = null;
              }
            }

            return FeedItem(
              title: item.title ?? 'No Title',
              description: item.description,
              link: item.link,
              pubDate: pubDate,
            );
          }).toList();

          return Result.ok(
            Feed(
              feedUrlId: feedUrl.id,
              title: rssFeed.title ?? feedUrl.name,
              description: rssFeed.description,
              items: items,
            ),
          );
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch feed by URL: $e'));
    }
  }
}
