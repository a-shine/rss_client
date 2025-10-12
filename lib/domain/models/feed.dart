import 'feed_item.dart';

class Feed {
  final String feedUrlId;
  final String title;
  final String? description;
  final List<FeedItem> items;

  Feed({
    required this.feedUrlId,
    required this.title,
    this.description,
    required this.items,
  });
}
