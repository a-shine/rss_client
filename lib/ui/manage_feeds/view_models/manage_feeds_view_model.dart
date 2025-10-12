import 'package:flutter/foundation.dart';
import 'package:rss_client/utils/command.dart';

import '../../../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';

class AddFeedForm {
  const AddFeedForm({this.url = '', this.name = ''});

  final String url;
  final String name;
}

class ManageFeedsViewModel extends ChangeNotifier {
  ManageFeedsViewModel(this._feedUrlRepository) {
    load = Command0<void>(_load)..execute();
    addFeed = Command1<void, AddFeedForm>(_addFeedUrl);
    removeFeed = Command1<void, String>(_removeFeedUrl);
  }

  // Dependencies
  final FeedUrlRepository _feedUrlRepository;

  // Commands
  late Command0<void> load;
  late Command1<void, AddFeedForm> addFeed;
  late Command1<void, String> removeFeed;

  // State
  final List<FeedUrl> _feedUrls = [];
  List<FeedUrl> get feedUrls => _feedUrls;

  /// Load all feed URLs from storage
  Future<Result<void>> _load() async {
    final result = await _feedUrlRepository.getFeedUrls();
    switch (result) {
      case Ok():
        _feedUrls
          ..clear()
          ..addAll(result.value);
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }

  /// Add a new feed URL
  Future<Result<void>> _addFeedUrl(AddFeedForm form) async {
    try {
      // // Check if URL already exists
      // if (await _feedUrlRepository.urlExists(form.url)) {
      //   _error = 'This feed URL already exists';
      //   notifyListeners();
      //   return false;
      // }

      final feedUrl = FeedUrl(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: form.url,
        name: form.name,
      );

      final result = await _feedUrlRepository.addFeedUrl(feedUrl);

      switch (result) {
        case Error():
          return Result.error(result.error);
        case Ok():
          break; // Continue to reload the list
      }
      await _load(); // Refresh the list

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to add feed URL: $e'));
    }
  }

  /// Remove a feed URL
  Future<Result<void>> _removeFeedUrl(String id) async {
    try {
      final result = await _feedUrlRepository.removeFeedUrl(id);

      switch (result) {
        case Error():
          return Result.error(
            Exception('Failed to remove feed URL: ${result.error}'),
          );
        case Ok():
          break; // Continue to reload the list
      }
      await _load(); // Refresh the list
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to remove feed URL: $e'));
    }
  }
}
