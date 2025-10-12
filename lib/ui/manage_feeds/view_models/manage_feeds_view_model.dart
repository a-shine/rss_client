import 'package:flutter/foundation.dart';

import '../../../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../../../domain/models/feed_url.dart';

class ManageFeedsViewModel extends ChangeNotifier {
  final FeedUrlRepository _feedUrlRepository;

  ManageFeedsViewModel(this._feedUrlRepository);

  List<FeedUrl> _feedUrls = [];
  String? _error;

  List<FeedUrl> get feedUrls => _feedUrls;
  String? get error => _error;

  /// Load all feed URLs from storage
  Future<void> loadFeedUrls() async {
    try {
      _feedUrls = await _feedUrlRepository.getFeedUrls();
      notifyListeners();
    } catch (e) {
      print('Error loading feed URLs: $e');
      _error = 'Failed to load feeds: $e';
      notifyListeners();
    }
  }

  /// Add a new feed URL
  Future<bool> addFeedUrl(String url, String name) async {
    try {
      // Check if URL already exists
      if (await _feedUrlRepository.urlExists(url)) {
        _error = 'This feed URL already exists';
        notifyListeners();
        return false;
      }

      final feedUrl = FeedUrl(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: url,
        name: name,
      );

      await _feedUrlRepository.addFeedUrl(feedUrl);
      await loadFeedUrls();

      return true;
    } catch (e) {
      _error = 'Failed to add feed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove a feed URL
  Future<void> removeFeedUrl(String id) async {
    try {
      await _feedUrlRepository.removeFeedUrl(id);
      await loadFeedUrls();
    } catch (e) {
      _error = 'Failed to remove feed: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
