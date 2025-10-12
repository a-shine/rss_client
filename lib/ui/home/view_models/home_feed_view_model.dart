import 'package:flutter/foundation.dart';
import 'package:rss_client/utils/command.dart';

import '../../../data/repositories/article_repository/article_repository.dart';
import '../../../data/repositories/rss_feed_repository/rss_feed_repository.dart';
import '../../../domain/models/article.dart';
import '../../../domain/models/feed.dart';
import '../../../utils/result.dart';

class HomeFeedViewModel extends ChangeNotifier {
  HomeFeedViewModel({
    required RssFeedRepository rssFeedRepository,
    required ArticleRepository articleRepository,
  }) : _repository = rssFeedRepository,
       _articleRepository = articleRepository {
    load = Command0<void>(_load)..execute();
    parseArticle = Command1<Article, String>(_parseArticle);
  }

  // Dependencies
  final RssFeedRepository _repository;
  final ArticleRepository _articleRepository;

  // Commands
  late Command0<void> load;
  late Command1<Article, String> parseArticle;

  // State
  List<Feed> _feeds = [];
  List<Feed> get feeds => _feeds;
  bool get hasFeeds => _feeds.isNotEmpty;

  /// Load all feeds from all configured URLs
  Future<Result<void>> _load() async {
    final result = await _repository.fetchAllFeeds();
    switch (result) {
      case Ok():
        _feeds = result.value;
        return Result.ok(null);
      case Error():
        _feeds = [];
        return Result.error(result.error);
    }
  }

  Future<Result<Article>> _parseArticle(String url) async {
    return await _articleRepository.fetchAndParseArticle(url);
  }
}
