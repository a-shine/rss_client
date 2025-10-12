import 'package:flutter/foundation.dart';

import '../../../data/repositories/rss_feed_repository/rss_feed_repository.dart';
import '../../../data/services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import '../../../domain/models/feed.dart';
import '../../../domain/models/feed_url.dart';

class HomeFeedViewModel extends ChangeNotifier {
  final RssFeedRepository _repository;
  final FeedUrlLocalStorageService _feedUrlService;

  HomeFeedViewModel(this._repository, this._feedUrlService);

  List<Feed> _feeds = [];
  List<FeedUrl> _feedUrls = [];
  bool _isLoading = false;
  String? _error;

  List<Feed> get feeds => _feeds;
  List<FeedUrl> get feedUrls => _feedUrls;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFeeds => _feeds.isNotEmpty;
  bool get hasFeedUrls => _feedUrls.isNotEmpty;

  /// Load all feed URLs from storage
  Future<void> loadFeedUrls() async {
    try {
      _feedUrls = await _feedUrlService.getFeedUrls();
      notifyListeners();
    } catch (e) {
      print('Error loading feed URLs: $e');
    }
  }

  /// Load all feeds from all configured URLs
  Future<void> loadAllFeeds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await loadFeedUrls();
      _feeds = await _repository.fetchAllFeeds();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _feeds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadAllFeeds();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
