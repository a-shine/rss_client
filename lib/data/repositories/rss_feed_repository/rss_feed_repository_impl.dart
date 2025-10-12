import '../../../domain/models/feed.dart';
import '../../../domain/models/feed_item.dart';
import '../../../domain/models/feed_url.dart';
import '../../services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import '../../services/rss_feed_http_service/rss_feed_http_service.dart';
import 'rss_feed_repository.dart';

class RssFeedRepositoryImpl implements RssFeedRepository {
  final RssFeedHttpService _service;
  final FeedUrlLocalStorageService _feedUrlService;

  RssFeedRepositoryImpl(this._service, this._feedUrlService);

  @override
  Future<List<Feed>> fetchAllFeeds() async {
    final feedUrls = await _feedUrlService.getFeedUrls();

    if (feedUrls.isEmpty) {
      return [];
    }

    final List<Feed> feeds = [];

    for (final feedUrl in feedUrls) {
      try {
        final feed = await fetchFeedByUrl(feedUrl);
        feeds.add(feed);
      } catch (e) {
        // Continue with other feeds if one fails
        // You might want to log this error
        print('Error fetching feed ${feedUrl.name}: $e');
      }
    }

    return feeds;
  }

  @override
  Future<Feed> fetchFeedByUrl(FeedUrl feedUrl) async {
    final rssFeed = await _service.fetchRssFeed(feedUrl.url);

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

    return Feed(
      feedUrlId: feedUrl.id,
      title: rssFeed.title ?? feedUrl.name,
      description: rssFeed.description,
      items: items,
    );
  }
}
